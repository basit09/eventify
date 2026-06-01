import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/event_entity.dart';
import '../../domain/entities/event_category_item.dart';
import '../../data/repositories/firebase_event_repository.dart';
import '../../../authentication/data/repositories/firebase_auth_repository.dart';

part 'create_event_controller.g.dart';

@riverpod
class CreateEventController extends _$CreateEventController {
  @override
  AsyncValue<void> build() {
    return const AsyncData(null);
  }

  Future<void> createEvent({
    required String name,
    required DateTime startDate,
    required DateTime endDate,
    required String address,
    required DateTime setupDate,
    required List<EventCategoryItem> items,
    String? contactPerson,
    String? contactPhone,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final user = ref.read(authRepositoryProvider).currentUser;
      if (user == null) throw Exception('User not logged in');

      final event = EventEntity(
        id: '',
        name: name,
        startDate: startDate,
        endDate: endDate,
        address: address,
        setupDate: setupDate,
        contactPerson: contactPerson?.isNotEmpty == true ? contactPerson : null,
        contactPhone: contactPhone?.isNotEmpty == true ? contactPhone : null,
        creatorId: user.id,
        items: items,
      );

      await ref.read(eventRepositoryProvider).createEvent(event);
    });
  }
}

// Controller specifically for managing the form's dynamic list of categories
@riverpod
class EventFormItems extends _$EventFormItems {
  @override
  List<EventCategoryItem> build() {
    return [];
  }

  void addItem(EventCategoryItem item) {
    state = [...state, item];
  }

  void removeItem(String itemId) {
    state = state.where((item) => item.id != itemId).toList();
  }

  void updateItem(EventCategoryItem updatedItem) {
    state = state.map((item) => item.id == updatedItem.id ? updatedItem : item).toList();
  }
}
