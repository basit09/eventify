import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/repositories/firebase_event_repository.dart';

part 'home_controller.g.dart';

@Riverpod(keepAlive: true)
class HomeStats extends _$HomeStats {
  @override
  Map<String, int> build() {
    final eventsAsync = ref.watch(eventsStreamProvider);
    
    return eventsAsync.maybeWhen(
      data: (events) {
        final total = events.length;
        final upcoming = events.where((e) => !e.isCompleted && e.startDate.isAfter(DateTime.now())).length;
        final completed = events.where((e) => e.isCompleted).length;
        final past = total - upcoming - completed;
        
        return {
          'total': total,
          'upcoming': upcoming,
          'completed': completed,
          'past': past,
        };
      },
      orElse: () => {'total': 0, 'upcoming': 0, 'completed': 0, 'past': 0},
    );
  }
}
