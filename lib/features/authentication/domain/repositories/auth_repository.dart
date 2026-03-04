import '../entities/user_entity.dart';

abstract class AuthRepository {
  Stream<UserEntity?> get authStateChanges;
  Future<UserEntity?> signInWithEmailAndPassword(String email, String password);
  Future<void> signOut();
  UserEntity? get currentUser;
}
