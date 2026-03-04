import '../entities/event_entity.dart';

abstract class EventRepository {
  Stream<List<EventEntity>> watchEvents();
  Future<List<EventEntity>> getRecentEvents();
  Future<void> createEvent(EventEntity event);
  Future<void> updateEvent(EventEntity event);
  Future<void> toggleEventCompletion(String eventId, bool isCompleted);
  Future<void> deleteEvent(String eventId);
}
