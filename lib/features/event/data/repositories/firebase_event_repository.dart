import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/event_entity.dart';
import '../../domain/repositories/event_repository.dart';

part 'firebase_event_repository.g.dart';

class FirebaseEventRepository implements EventRepository {
  final FirebaseFirestore _firestore;

  FirebaseEventRepository(this._firestore);

  CollectionReference get _eventsCollection => _firestore.collection('events');

  @override
  Stream<List<EventEntity>> watchEvents() {
    return _eventsCollection
        .orderBy('startDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        if (data['startDate'] is Timestamp) {
          data['startDate'] = (data['startDate'] as Timestamp).toDate().toIso8601String();
        }
        if (data['endDate'] is Timestamp) {
          data['endDate'] = (data['endDate'] as Timestamp).toDate().toIso8601String();
        }
        return EventEntity.fromJson(data);
      }).toList();
    });
  }

  @override
  Future<List<EventEntity>> getRecentEvents() async {
    final snapshot = await _eventsCollection
        .orderBy('startDate', descending: true) // Changed from 'date' to 'startDate'
        .limit(10)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      if (data['startDate'] is Timestamp) {
        data['startDate'] = (data['startDate'] as Timestamp).toDate().toIso8601String();
      }
      if (data['endDate'] is Timestamp) {
        data['endDate'] = (data['endDate'] as Timestamp).toDate().toIso8601String();
      }
      return EventEntity.fromJson(data);
    }).toList();
  }

  @override
  Future<void> createEvent(EventEntity event) async {
    final docRef = _eventsCollection.doc();
    final eventWithId = event.copyWith(id: docRef.id);
    // Convert to JSON and explicitly serialize nested items list
    final json = eventWithId.toJson();
    json['items'] = event.items.map((e) => e.toJson()).toList();
    await docRef.set(json);
  }

  @override
  Future<void> updateEvent(EventEntity event) async {
    final json = event.toJson();
    json['items'] = event.items.map((e) => e.toJson()).toList();
    await _eventsCollection.doc(event.id).update(json);
  }

  @override
  Future<void> toggleEventCompletion(String eventId, bool isCompleted) async {
    await _eventsCollection.doc(eventId).update({'isCompleted': isCompleted});
  }

  @override
  Future<void> deleteEvent(String eventId) async {
    await _eventsCollection.doc(eventId).delete();
  }
}

@riverpod
EventRepository eventRepository(Ref ref) {
  // Use FirebaseFirestore.instance directly or inject it
  return FirebaseEventRepository(FirebaseFirestore.instance);
}

@riverpod
Stream<List<EventEntity>> eventsStream(Ref ref) {
  return ref.watch(eventRepositoryProvider).watchEvents();
}
