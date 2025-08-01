import 'package:nutri_care/services/content_service.dart';
import 'package:nutri_care/models/content_models.dart';

class MockContentService implements ContentService {
  bool _shouldSucceed = true;
  List<Recipe> _mockRecipes = [];
  List<Guide> _mockGuides = [];
  List<AppNotification> _mockNotifications = [];

  void setShouldSucceed(bool shouldSucceed) {
    _shouldSucceed = shouldSucceed;
  }

  void setMockRecipes(List<Recipe> recipes) {
    _mockRecipes = recipes;
  }

  void setMockGuides(List<Guide> guides) {
    _mockGuides = guides;
  }

  @override
  Future<void> createNotification({
    required String title,
    required String message,
    required String type,
    required String contentId,
    required String creatorId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 50));
    
    if (!_shouldSucceed) {
      throw Exception('Failed to create notification');
    }

    final notification = AppNotification(
      id: 'notification-${_mockNotifications.length + 1}',
      title: title,
      message: message,
      type: type,
      contentId: contentId,
      creatorId: creatorId,
      createdAt: DateTime.now(),
    );

    _mockNotifications.add(notification);
  }

  @override
  Future<void> deleteRecipe(String recipeId, String currentUserId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    
    if (!_shouldSucceed) {
      throw Exception('Failed to delete recipe');
    }

    final recipe = _mockRecipes.firstWhere(
      (r) => r.id == recipeId,
      orElse: () => throw Exception('Recipe not found'),
    );

    if (recipe.creatorId != currentUserId) {
      throw Exception('You can only delete your own recipes');
    }

    _mockRecipes.removeWhere((r) => r.id == recipeId);
  }

  @override
  Future<void> deleteGuide(String guideId, String currentUserId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    
    if (!_shouldSucceed) {
      throw Exception('Failed to delete guide');
    }

    final guide = _mockGuides.firstWhere(
      (g) => g.id == guideId,
      orElse: () => throw Exception('Guide not found'),
    );

    if (guide.creatorId != currentUserId) {
      throw Exception('You can only delete your own guides');
    }

    _mockGuides.removeWhere((g) => g.id == guideId);
  }

  @override
  Future<void> updateRecipe(Recipe recipe, String currentUserId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    
    if (!_shouldSucceed) {
      throw Exception('Failed to update recipe');
    }

    if (recipe.creatorId != currentUserId) {
      throw Exception('You can only update your own recipes');
    }

    final index = _mockRecipes.indexWhere((r) => r.id == recipe.id);
    if (index != -1) {
      _mockRecipes[index] = recipe;
    }

    await createNotification(
      title: 'Recipe Updated',
      message: 'Recipe "${recipe.title}" has been updated',
      type: 'recipe_updated',
      contentId: recipe.id,
      creatorId: recipe.creatorId,
    );
  }

  @override
  Future<void> updateGuide(Guide guide, String currentUserId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    
    if (!_shouldSucceed) {
      throw Exception('Failed to update guide');
    }

    if (guide.creatorId != currentUserId) {
      throw Exception('You can only update your own guides');
    }

    final index = _mockGuides.indexWhere((g) => g.id == guide.id);
    if (index != -1) {
      _mockGuides[index] = guide;
    }

    await createNotification(
      title: 'Guide Updated',
      message: 'Guide "${guide.title}" has been updated',
      type: 'guide_updated',
      contentId: guide.id,
      creatorId: guide.creatorId,
    );
  }

  // Additional helper methods for testing
  List<Recipe> getMockRecipes() => List.from(_mockRecipes);
  List<Guide> getMockGuides() => List.from(_mockGuides);
  List<AppNotification> getMockNotifications() => List.from(_mockNotifications);

  void clearMockData() {
    _mockRecipes.clear();
    _mockGuides.clear();
    _mockNotifications.clear();
  }
}