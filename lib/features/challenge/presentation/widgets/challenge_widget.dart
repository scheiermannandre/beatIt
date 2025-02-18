import 'package:beat_it/core/core.dart';
import 'package:beat_it/features/challenge/challenge.dart';
import 'package:beat_it/foundation/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

/// A widget that displays a challenge progress with a grid of boxes.
/// The grid layout adapts based on the number of boxes:
/// - For ≤ 30 boxes: Horizontal layout with automatic row wrapping
/// - For > 30 boxes: Vertical layout with horizontal scrolling
class ChallengeWidget extends ConsumerStatefulWidget {
  const ChallengeWidget({
    required this.challengeId,
    this.isArchived = false,
    super.key,
  });

  final String challengeId;
  final bool isArchived;
  @override
  ConsumerState<ChallengeWidget> createState() => _ChallengeWidgetState();
}

class _ChallengeWidgetState extends ConsumerState<ChallengeWidget> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; // Keep widget alive when scrolled away

  String _formatDate(DateTime date, BuildContext context) {
    return DateFormat.yMMMd(Localizations.localeOf(context).languageCode).format(date);
  }

  String _getStatusEmoji(ChallengeModel challengeModel) {
    // Check if challenge is completed successfully
    final completedDays = challengeModel.days.where((day) => day.isCompleted).length;
    if (completedDays == challengeModel.targetDays) {
      return ' 🎉 '; // Success
    } else

    // Check if challenge was broken (grace days spent)
    if (challengeModel.areGraceDaysSpent) {
      return ' ❌ '; // Failed
    } else {
      return ' 🗑️ '; // Archived/Deleted
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required by AutomaticKeepAliveClientMixin

    final challengeAsyncValue = ref.watch(challengeViewModelProvider(widget.challengeId));

    return challengeAsyncValue.whenWithData(
      (challenge) {
        return Card(
          margin: EdgeInsets.zero,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => context.pushChallenge(id: widget.challengeId, isArchived: widget.isArchived),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: _ChallengeTitle(
                          challengeModel: challenge,
                          challengeId: widget.challengeId,
                        ),
                      ),
                      if (!widget.isArchived)
                        CheckButton(
                          challengeId: widget.challengeId,
                          date: DateTime.now(),
                        )
                      else
                        Container(
                          width: 40,
                          height: 40,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _getStatusEmoji(challenge),
                            style: const TextStyle(fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                        ),
                    ],
                  ),
                  _BoxesGrid(challengeModel: challenge),
                  const SizedBox(height: 8),
                  Text(
                    '${_formatDate(challenge.startDate, context)} - '
                    '${_formatDate(
                      challenge.startDate.add(
                        Duration(days: challenge.targetDays - 1),
                      ),
                      context,
                    )}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BoxesGrid extends StatelessWidget {
  const _BoxesGrid({required this.challengeModel});

  final ChallengeModel challengeModel;

  @override
  Widget build(BuildContext context) {
    const boxSize = 12.0;
    const spacing = 2.0;
    const minSpacing = 1.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (challengeModel.targetDays <= 30) {
          const columns = 7;
          final rows = (challengeModel.targetDays / columns).ceil();
          final availableWidth = constraints.maxWidth / columns;
          final actualSpacing = availableWidth < (boxSize + spacing) ? minSpacing : spacing;

          final gridWidth = (columns * boxSize) + ((columns - 1) * actualSpacing);
          final gridHeight = (rows * boxSize) + ((rows - 1) * actualSpacing);

          return SizedBox(
            width: gridWidth.clamp(0, constraints.maxWidth),
            height: gridHeight,
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: actualSpacing,
                mainAxisSpacing: actualSpacing,
                mainAxisExtent: boxSize,
              ),
              itemCount: challengeModel.targetDays,
              itemBuilder: (context, index) {
                final date = challengeModel.startDate.add(Duration(days: index));
                return _Box(
                  status: challengeModel.days
                      .firstWhere(
                        (day) => day.date.withoutTime == date.withoutTime,
                        orElse: () => DayModel(date: date, status: DayStatus.none),
                      )
                      .status,
                );
              },
            ),
          );
        }

        const rows = 7;
        final availableHeight = constraints.maxHeight / rows;
        final actualSpacing = availableHeight < (boxSize + spacing) ? minSpacing : spacing;
        final gridHeight = (rows * boxSize) + ((rows - 1) * actualSpacing);

        return SizedBox(
          height: gridHeight.clamp(0, constraints.maxHeight),
          child: GridView.builder(
            scrollDirection: Axis.horizontal,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: rows,
              crossAxisSpacing: actualSpacing,
              mainAxisSpacing: actualSpacing,
              mainAxisExtent: boxSize,
            ),
            itemCount: challengeModel.targetDays,
            itemBuilder: (context, index) {
              final date = challengeModel.startDate.add(Duration(days: index));
              return SizedBox(
                width: boxSize,
                height: boxSize,
                child: _Box(
                  status: challengeModel.days
                      .firstWhere(
                        (day) => day.date.withoutTime == date.withoutTime,
                        orElse: () => DayModel(date: date, status: DayStatus.none),
                      )
                      .status,
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _Box extends StatelessWidget {
  const _Box({required this.status});

  final DayStatus status;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    const boxSize = 12.0;

    Color getColor() {
      switch (status) {
        case DayStatus.completed:
          return colorScheme.primary;
        case DayStatus.skipped:
          return colorScheme.error;
        case DayStatus.none:
          return colorScheme.primary.withCustomOpacity(.5);
      }
    }

    return Container(
      width: boxSize,
      height: boxSize,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: getColor(),
        borderRadius: BorderRadius.circular(4),
      ),
      child: status == DayStatus.skipped ? const Icon(Icons.close, color: Colors.white, size: boxSize) : null,
    );
  }
}

class _ChallengeTitle extends StatelessWidget {
  const _ChallengeTitle({
    required this.challengeModel,
    required this.challengeId,
  });

  final ChallengeModel challengeModel;
  final String challengeId;

  @override
  Widget build(BuildContext context) {
    final completedChallenges = challengeModel.days.where((day) => day.isCompleted).length;
    final progress = challengeModel.targetDays > 0 ? completedChallenges / challengeModel.targetDays : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          challengeModel.title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        AnimatedProgressIndicator(
          progress: progress,
          challengeId: challengeId,
        ),
      ],
    );
  }
}
