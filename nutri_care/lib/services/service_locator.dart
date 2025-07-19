import '../api/auth_api.dart';
import '../api/firestore_content_api.dart';
import '../api/http_api_client.dart';

/// Service Locator for managing API instances
/// This provides a centralized way to access API services throughout the app
class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  // API instances
  late final AuthApi _authApi;
  late final FirestoreContentApi _contentApi;
  late final HttpApiClient _httpClient;

  // Initialize services
  void initialize() {
    _authApi = AuthApi();
    _contentApi = FirestoreContentApi();
    _httpClient = HttpApiClient();
  }

  // Service getters
  AuthApi get authApi => _authApi;
  FirestoreContentApi get contentApi => _contentApi;
  HttpApiClient get httpClient => _httpClient;

  // Dispose all services
  void dispose() {
    _httpClient.dispose();
  }
}

// Global service locator instance
final serviceLocator = ServiceLocator();
