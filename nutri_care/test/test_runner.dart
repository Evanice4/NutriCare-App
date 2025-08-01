import 'package:flutter_test/flutter_test.dart';

// Import all test files
import 'unit/theme_bloc_test.dart' as theme_bloc_tests;
import 'unit/user_bloc_test.dart' as user_bloc_tests;
import 'unit/content_service_test.dart' as content_service_tests;
import 'widget/theme_toggle_test.dart' as theme_toggle_tests;
import 'widget/phone_auth_screen_test.dart' as phone_auth_tests;
import 'widget/search_filter_test.dart' as search_filter_tests;
import 'bloc_test.dart' as navigation_bloc_tests;
import 'search_bloc_test.dart' as search_bloc_tests;

void main() {
  group('NutriCare App Test Suite', () {
    group('Unit Tests', () {
      group('BLoC Tests', () {
        theme_bloc_tests.main();
        user_bloc_tests.main();
        navigation_bloc_tests.main();
        search_bloc_tests.main();
      });

      group('Service Tests', () {
        content_service_tests.main();
      });
    });

    group('Widget Tests', () {
      theme_toggle_tests.main();
      phone_auth_tests.main();
      search_filter_tests.main();
    });
  });
}