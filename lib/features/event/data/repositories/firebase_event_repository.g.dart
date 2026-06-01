// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'firebase_event_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(eventRepository)
final eventRepositoryProvider = EventRepositoryProvider._();

final class EventRepositoryProvider
    extends
        $FunctionalProvider<EventRepository, EventRepository, EventRepository>
    with $Provider<EventRepository> {
  EventRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'eventRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$eventRepositoryHash();

  @$internal
  @override
  $ProviderElement<EventRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  EventRepository create(Ref ref) {
    return eventRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EventRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EventRepository>(value),
    );
  }
}

String _$eventRepositoryHash() => r'ed0ca028c7fd6998369917784ea0ad0d6791289d';

@ProviderFor(eventsStream)
final eventsStreamProvider = EventsStreamProvider._();

final class EventsStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<EventEntity>>,
          List<EventEntity>,
          Stream<List<EventEntity>>
        >
    with
        $FutureModifier<List<EventEntity>>,
        $StreamProvider<List<EventEntity>> {
  EventsStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'eventsStreamProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$eventsStreamHash();

  @$internal
  @override
  $StreamProviderElement<List<EventEntity>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<EventEntity>> create(Ref ref) {
    return eventsStream(ref);
  }
}

String _$eventsStreamHash() => r'e8080ab8b497eb4acb46834f6f64fa6a6ed75932';
