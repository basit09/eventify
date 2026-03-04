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
        isAutoDispose: true,
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

String _$eventRepositoryHash() => r'eba5d56178dfc5d8e14905c1278ba676425d8321';

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
        isAutoDispose: true,
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

String _$eventsStreamHash() => r'e049898f8e2a8b9a4ae1c1342f5fed01b16c3e89';
