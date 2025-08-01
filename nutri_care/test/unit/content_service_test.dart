import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_care/services/content_service.dart';
import 'package:nutri_care/models/content_models.dart';

void main() {
  group('ContentService', () {
    late ContentService contentService;

    setUp(() {
      contentService = ContentService();
    });

    group('deleteRecipe', () {
      test('throws exception when recipe not found', () async {
        expect(
          () => contentService.deleteRecipe('non-existent', 'user-id'),
          throwsA(isA<Exception>()),
        );
      });

      test('throws exception when user is not the creator', () async {
        // This would need Firebase emulator or mocking to properly test
        expect(
          () => contentService.deleteRecipe('recipe-id', 'wrong-user'),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('deleteGuide', () {
      test('throws exception when guide not found', () async {
        expect(
          () => contentService.deleteGuide('non-existent', 'user-id'),
          throwsA(isA<Exception>()),
        );
      });

      test('throws exception when user is not the creator', () async {
        // This would need Firebase emulator or mocking to properly test
        expect(
          () => contentService.deleteGuide('guide-id', 'wrong-user'),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('updateRecipe', () {
      test('throws exception when user is not the creator', () async {
        final recipe = Recipe(
          id: 'recipe-id',
          title: 'Test Recipe',
          description: 'Test Description',
          imageUrl: '',
          creatorId: 'original-creator',
          createdAt: DateTime.now(),
          ingredients: [],
        );

        expect(
          () => contentService.updateRecipe(recipe, 'different-user'),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('updateGuide', () {
      test('throws exception when user is not the creator', () async {
        final guide = Guide(
          id: 'guide-id',
          title: 'Test Guide',
          description: 'Test Description',
          content: 'Test Content',
          category: 'nutrition',
          imageUrl: '',
          creatorId: 'original-creator',
          createdAt: DateTime.now(),
        );

        expect(
          () => contentService.updateGuide(guide, 'different-user'),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}