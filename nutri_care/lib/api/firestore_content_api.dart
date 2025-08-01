import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/content_models.dart';

class FirestoreContentApi {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Nutrition Guides
  Future<String> createGuide(NutritionGuide guide) async {
    final doc = await _db.collection('guides').add(guide.toMap());
    return doc.id;
  }

  Future<void> updateGuide(String id, NutritionGuide guide) async {
    await _db.collection('guides').doc(id).update(guide.toMap());
  }

  Future<void> deleteGuide(String id) async {
    await _db.collection('guides').doc(id).delete();
  }

  Future<NutritionGuide?> getGuide(String id) async {
    final doc = await _db.collection('guides').doc(id).get();
    if (!doc.exists) return null;
    return NutritionGuide.fromMap(doc.id, doc.data()!);
  }

  Stream<List<NutritionGuide>> guidesStream() {
    return _db
        .collection('guides')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => NutritionGuide.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  // Recipes
  Future<String> createRecipe(Recipe recipe) async {
    final doc = await _db.collection('recipes').add(recipe.toMap());
    
    // Create notification
    await _createNotification(
      title: 'New Recipe Added',
      message: 'New recipe "${recipe.title}" has been published',
      type: 'recipe_added',
      contentId: doc.id,
      creatorId: recipe.creatorId,
    );
    
    return doc.id;
  }

  Future<void> updateRecipe(String id, Recipe recipe) async {
    await _db.collection('recipes').doc(id).update(recipe.toMap());
  }

  Future<void> deleteRecipe(String id) async {
    await _db.collection('recipes').doc(id).delete();
  }

  Future<Recipe?> getRecipe(String id) async {
    final doc = await _db.collection('recipes').doc(id).get();
    if (!doc.exists) return null;
    return Recipe.fromMap(doc.id, doc.data()!);
  }

  Stream<List<Recipe>> recipesStream() {
    return _db
        .collection('recipes')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Recipe.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  // Health Alerts
  Future<String> createAlert(HealthAlert alert) async {
    final doc = await _db.collection('alerts').add(alert.toMap());
    return doc.id;
  }

  Future<void> updateAlert(String id, HealthAlert alert) async {
    await _db.collection('alerts').doc(id).update(alert.toMap());
  }

  Future<void> deleteAlert(String id) async {
    await _db.collection('alerts').doc(id).delete();
  }

  Future<HealthAlert?> getAlert(String id) async {
    final doc = await _db.collection('alerts').doc(id).get();
    if (!doc.exists) return null;
    return HealthAlert.fromMap(doc.id, doc.data()!);
  }

  Stream<List<HealthAlert>> alertsStream() {
    return _db
        .collection('alerts')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => HealthAlert.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  // Collection references for better organization
  CollectionReference get guidesCollection => _db.collection('guides');
  CollectionReference get recipesCollection => _db.collection('recipes');
  CollectionReference get alertsCollection => _db.collection('alerts');

  // Search methods
  Stream<List<NutritionGuide>> searchGuides(String searchTerm) {
    return _db
        .collection('guides')
        .where('title', isGreaterThanOrEqualTo: searchTerm)
        .where('title', isLessThanOrEqualTo: '$searchTerm\uf8ff')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => NutritionGuide.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Stream<List<Recipe>> searchRecipes(String searchTerm) {
    return _db
        .collection('recipes')
        .where('title', isGreaterThanOrEqualTo: searchTerm)
        .where('title', isLessThanOrEqualTo: '$searchTerm\uf8ff')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Recipe.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  // Get content by creator
  Stream<List<NutritionGuide>> getGuidesByCreator(String creatorId) {
    return _db
        .collection('guides')
        .where('creatorId', isEqualTo: creatorId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => NutritionGuide.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Stream<List<Recipe>> getRecipesByCreator(String creatorId) {
    return _db
        .collection('recipes')
        .where('creatorId', isEqualTo: creatorId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Recipe.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Stream<List<HealthAlert>> getAlertsByCreator(String creatorId) {
    return _db
        .collection('alerts')
        .where('creatorId', isEqualTo: creatorId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => HealthAlert.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  // New Guide methods (for the Guide model used in guides screen)
  Future<String> createNewGuide(Guide guide) async {
    final doc = await _db.collection('guides').add(guide.toMap());
    
    // Create notification
    await _createNotification(
      title: 'New Guide Added',
      message: 'New guide "${guide.title}" has been published',
      type: 'guide_added',
      contentId: doc.id,
      creatorId: guide.creatorId,
    );
    
    return doc.id;
  }

  Future<void> updateNewGuide(String id, Guide guide) async {
    await _db.collection('guides').doc(id).update(guide.toMap());
  }

  Future<Guide?> getNewGuide(String id) async {
    final doc = await _db.collection('guides').doc(id).get();
    if (!doc.exists) return null;
    return Guide.fromMap(doc.data()!, doc.id);
  }

  Stream<List<Guide>> newGuidesStream() {
    return _db
        .collection('guides')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Guide.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  // Notifications
  Future<void> _createNotification({
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
    
    await _db.collection('notifications').add(notification.toMap());
  }

  Stream<List<AppNotification>> notificationsStream() {
    return _db
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => AppNotification.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<void> deleteNotification(String notificationId) async {
    await _db.collection('notifications').doc(notificationId).delete();
  }
}
