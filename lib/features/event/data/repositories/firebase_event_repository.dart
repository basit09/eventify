import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/event_entity.dart';
import '../../domain/repositories/event_repository.dart';
import '../../../category/data/repositories/firebase_category_repository.dart';

part 'firebase_event_repository.g.dart';

class FirebaseEventRepository implements EventRepository {
  final FirebaseFirestore _firestore;

  FirebaseEventRepository(this._firestore);

  CollectionReference get _eventsCollection => _firestore.collection('events');

  /// Normalises a raw Firestore document map so it can be passed to
  /// [EventEntity.fromJson] safely, even for events created before the
  /// `setupDate`, `contactPerson`, and `contactPhone` fields were added.
  Map<String, dynamic> _normalise(Map<String, dynamic> data, String docId) {
    data['id'] = docId;

    // Convert Timestamps → ISO-8601 strings for freezed / json_serializable
    for (final field in ['startDate', 'endDate']) {
      if (data[field] is Timestamp) {
        data[field] = (data[field] as Timestamp).toDate().toIso8601String();
      }
    }

    // setupDate is now a plain String. Backward-compat: old Timestamp docs
    // get converted to a readable date string; missing field falls back to ''.
    if (data['setupDate'] is Timestamp) {
      final dt = (data['setupDate'] as Timestamp).toDate();
      data['setupDate'] =
          '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    }
    data['setupDate'] ??= '';

    return data;
  }

  @override
  Stream<List<EventEntity>> watchEvents() {
    return _eventsCollection
        .orderBy('startDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => EventEntity.fromJson(
                _normalise(doc.data() as Map<String, dynamic>, doc.id)))
            .toList());
  }

  @override
  Future<List<EventEntity>> getRecentEvents() async {
    final snapshot = await _eventsCollection
        .orderBy('startDate', descending: true)
        .limit(10)
        .get();

    return snapshot.docs
        .map((doc) => EventEntity.fromJson(
            _normalise(doc.data() as Map<String, dynamic>, doc.id)))
        .toList();
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

@Riverpod(keepAlive: true)
EventRepository eventRepository(Ref ref) {
  return FirebaseEventRepository(ref.watch(firebaseFirestoreProvider));
}

@Riverpod(keepAlive: true)
Stream<List<EventEntity>> eventsStream(Ref ref) {
  return ref.watch(eventRepositoryProvider).watchEvents();
}
