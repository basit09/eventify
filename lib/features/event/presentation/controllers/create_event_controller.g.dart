// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_event_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CreateEventController)
final createEventControllerProvider = CreateEventControllerProvider._();

final class CreateEventControllerProvider
    extends $NotifierProvider<CreateEventController, AsyncValue<void>> {
  CreateEventControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createEventControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createEventControllerHash();

  @$internal
  @override
  CreateEventController create() => CreateEventController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$createEventControllerHash() =>
    r'6f297d080fa95afa3f6ef6eddb1c9ce1c66184fc';

abstract class _$CreateEventController extends $Notifier<AsyncValue<void>> {
  AsyncValue<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, AsyncValue<void>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, AsyncValue<void>>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(EventFormItems)
final eventFormItemsProvider = EventFormItemsProvider._();

final class EventFormItemsProvider
    extends $NotifierProvider<EventFormItems, List<EventCategoryItem>> {
  EventFormItemsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'eventFormItemsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$eventFormItemsHash();

  @$internal
  @override
  EventFormItems create() => EventFormItems();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<EventCategoryItem> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<EventCategoryItem>>(value),
    );
  }
}

String _$eventFormItemsHash() => r'c363767a7fa2f1c0b6238656f12965cd468de4e9';

abstract class _$EventFormItems extends $Notifier<List<EventCategoryItem>> {
  List<EventCategoryItem> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<List<EventCategoryItem>, List<EventCategoryItem>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<EventCategoryItem>, List<EventCategoryItem>>,
              List<EventCategoryItem>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
