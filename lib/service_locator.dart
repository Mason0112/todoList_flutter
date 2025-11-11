import 'package:get_it/get_it.dart';
import 'service/api_service.dart';
import 'service/auth_service.dart';
import 'service/todo_service.dart';

// Global service locator instance
final getIt = GetIt.instance;

/// Setup all services for dependency injection
/// Call this once at app startup in main()
void setupServiceLocator() {
  // Register ApiService as a singleton (one instance shared across app)
  getIt.registerLazySingleton<ApiService>(() => ApiService());

  // Register AuthService as a singleton, injecting ApiService dependency
  getIt.registerLazySingleton<AuthService>(
    () => AuthService(getIt<ApiService>()),
  );

  // Register TodoService as a singleton, injecting dependencies
  getIt.registerLazySingleton<TodoService>(
    () => TodoService(getIt<ApiService>(), getIt<AuthService>()),
  );
}
