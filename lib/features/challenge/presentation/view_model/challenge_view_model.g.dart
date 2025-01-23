// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'challenge_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$challengeViewModelHash() =>
    r'71c74c74f97e83acec065900fdc2475fa75e56e9';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$ChallengeViewModel
    extends BuildlessAutoDisposeAsyncNotifier<ChallengeModel> {
  late final String challengeId;

  FutureOr<ChallengeModel> build(
    String challengeId,
  );
}

/// See also [ChallengeViewModel].
@ProviderFor(ChallengeViewModel)
const challengeViewModelProvider = ChallengeViewModelFamily();

/// See also [ChallengeViewModel].
class ChallengeViewModelFamily extends Family<AsyncValue<ChallengeModel>> {
  /// See also [ChallengeViewModel].
  const ChallengeViewModelFamily();

  /// See also [ChallengeViewModel].
  ChallengeViewModelProvider call(
    String challengeId,
  ) {
    return ChallengeViewModelProvider(
      challengeId,
    );
  }

  @override
  ChallengeViewModelProvider getProviderOverride(
    covariant ChallengeViewModelProvider provider,
  ) {
    return call(
      provider.challengeId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'challengeViewModelProvider';
}

/// See also [ChallengeViewModel].
class ChallengeViewModelProvider extends AutoDisposeAsyncNotifierProviderImpl<
    ChallengeViewModel, ChallengeModel> {
  /// See also [ChallengeViewModel].
  ChallengeViewModelProvider(
    String challengeId,
  ) : this._internal(
          () => ChallengeViewModel()..challengeId = challengeId,
          from: challengeViewModelProvider,
          name: r'challengeViewModelProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$challengeViewModelHash,
          dependencies: ChallengeViewModelFamily._dependencies,
          allTransitiveDependencies:
              ChallengeViewModelFamily._allTransitiveDependencies,
          challengeId: challengeId,
        );

  ChallengeViewModelProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.challengeId,
  }) : super.internal();

  final String challengeId;

  @override
  FutureOr<ChallengeModel> runNotifierBuild(
    covariant ChallengeViewModel notifier,
  ) {
    return notifier.build(
      challengeId,
    );
  }

  @override
  Override overrideWith(ChallengeViewModel Function() create) {
    return ProviderOverride(
      origin: this,
      override: ChallengeViewModelProvider._internal(
        () => create()..challengeId = challengeId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        challengeId: challengeId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<ChallengeViewModel, ChallengeModel>
      createElement() {
    return _ChallengeViewModelProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ChallengeViewModelProvider &&
        other.challengeId == challengeId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, challengeId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ChallengeViewModelRef
    on AutoDisposeAsyncNotifierProviderRef<ChallengeModel> {
  /// The parameter `challengeId` of this provider.
  String get challengeId;
}

class _ChallengeViewModelProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<ChallengeViewModel,
        ChallengeModel> with ChallengeViewModelRef {
  _ChallengeViewModelProviderElement(super.provider);

  @override
  String get challengeId => (origin as ChallengeViewModelProvider).challengeId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
