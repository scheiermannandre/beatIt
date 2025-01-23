import 'package:flutter/material.dart';

class ContentWithBottomSection extends StatelessWidget {
  const ContentWithBottomSection({
    required this.content,
    required this.bottomSection,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
    super.key,
  });

  final Widget content;
  final Widget bottomSection;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: padding,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      content,
                      const Spacer(),
                      bottomSection,
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
