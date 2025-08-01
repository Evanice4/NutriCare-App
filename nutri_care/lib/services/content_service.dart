import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/content_models.dart';

class ContentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createNotification({
    required String title,
    required String message,
    required String type,
    required String contentId,
    required String creatorId,
  }) async {
    final notification = AppNotification(
      id: '',
      title: title,
      message: message,
      type: type,
      contentId: contentId,
      creatorId: creatorId,
      createdAt: DateTime.now(),
    );
    
    await _firestore.collection('notifications').add(notification.toMap());
  }

  Future<void> deleteRecipe(String recipeId, String currentUserId) async {
    final doc = await _firestore.collection('recipes').doc(recipeId).get();
    if (!doc.exists) throw Exception('Recipe not found');
    
    final recipe = Recipe.fromMap(recipeId, doc.data()!);
    if (recipe.creatorId != currentUserId) {
      throw Exception('You can only delete your own recipes');
    }
    
    await _firestore.collection('recipes').doc(recipeId).delete();
  }

  Future<void> deleteGuide(String guideId, String currentUserId) async {
    final doc = await _firestore.collection('guides').doc(guideId).get();
    if (!doc.exists) throw Exception('Guide not found');
    
    final guide = Guide.fromMap(doc.data()!, guideId);
    if (guide.creatorId != currentUserId) {
      throw Exception('You can only delete your own guides');
    }
    
    await _firestore.collection('guides').doc(guideId).delete();
  }

  Future<void> updateRecipe(Recipe recipe, String currentUserId) async {
    if (recipe.creatorId != currentUserId) {
      throw Exception('You can only update your own recipes');
    }
    
    await _firestore.collection('recipes').doc(recipe.id).update(recipe.toMap());
    
    await createNotification(
      title: 'Recipe Updated',
      message: 'Recipe "${recipe.title}" has been updated',
      type: 'recipe_updated',
      contentId: recipe.id,
      creatorId: recipe.creatorId,
    );
  }

  Future<void> updateGuide(Guide guide, String currentUserId) async {
    if (guide.creatorId != currentUserId) {
      throw Exception('You can only update your own guides');
    }
    
    await _firestore.collection('guides').doc(guide.id).update(guide.toMap());
    
    await createNotification(
      title: 'Guide Updated',
      message: 'Guide "${guide.title}" has been updated',
      type: 'guide_updated',
      contentId: guide.id,
      creatorId: guide.creatorId,
    );
  }
}