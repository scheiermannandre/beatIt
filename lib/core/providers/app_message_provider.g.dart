// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_message_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$appMessageManagerHash() => r'3a6397f08e65c14dd68cd922402faf98a3775400';

/// See also [appMessageManager].
@ProviderFor(appMessageManager)
final appMessageManagerProvider = Provider<AppMessageManager>.internal(
  appMessageManager,
  name: r'appMessageManagerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$appMessageManagerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AppMessageManagerRef = ProviderRef<AppMessageManager>;
String _$appMessageNotifierHash() =>
    r'71d5afa737e35189d3c845a87df2f4cd6e259427';

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

abstract class _$AppMessageNotifier
    extends BuildlessAutoDisposeNotifier<MessageNotification?> {
  late final String id;

  MessageNotification? build(
    String id,
  );
}

/// See also [AppMessageNotifier].
@ProviderFor(AppMessageNotifier)
const appMessageNotifierProvider = AppMessageNotifierFamily();

/// See also [AppMessageNotifier].
class AppMessageNotifierFamily extends Family<MessageNotification?> {
  /// See also [AppMessageNotifier].
  const AppMessageNotifierFamily();

  /// See also [AppMessageNotifier].
  AppMessageNotifierProvider call(
    String id,
  ) {
    return AppMessageNotifierProvider(
      id,
    );
  }

  @override
  AppMessageNotifierProvider getProviderOverride(
    covariant AppMessageNotifierProvider provider,
  ) {
    return call(
      provider.id,
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
  String? get name => r'appMessageNotifierProvider';
}

/// See also [AppMessageNotifier].
class AppMessageNotifierProvider extends AutoDisposeNotifierProviderImpl<
    AppMessageNotifier, MessageNotification?> {
  /// See also [AppMessageNotifier].
  AppMessageNotifierProvider(
    String id,
  ) : this._internal(
          () => AppMessageNotifier()..id = id,
          from: appMessageNotifierProvider,
          name: r'appMessageNotifierProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$appMessageNotifierHash,
          dependencies: AppMessageNotifierFamily._dependencies,
          allTransitiveDependencies:
              AppMessageNotifierFamily._allTransitiveDependencies,
          id: id,
        );

  AppMessageNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final String id;

  @override
  MessageNotification? runNotifierBuild(
    covariant AppMessageNotifier notifier,
  ) {
    return notifier.build(
      id,
    );
  }

  @override
  Override overrideWith(AppMessageNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: AppMessageNotifierProvider._internal(
        () => create()..id = id,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<AppMessageNotifier, MessageNotification?>
      createElement() {
    return _AppMessageNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AppMessageNotifierProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin AppMessageNotifierRef
    on AutoDisposeNotifierProviderRef<MessageNotification?> {
  /// The parameter `id` of this provider.
  String get id;
}

class _AppMessageNotifierProviderElement
    extends AutoDisposeNotifierProviderElement<AppMessageNotifier,
        MessageNotification?> with AppMessageNotifierRef {
  _AppMessageNotifierProviderElement(super.provider);

  @override
  String get id => (origin as AppMessageNotifierProvider).id;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
