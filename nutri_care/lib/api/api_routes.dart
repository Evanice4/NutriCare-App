//// API routes for the application
/// All endpoints follow camelCase naming convention
/// This file contains all the API routes and endpoint configurations
/// for the NutriCare application.
library;

class ApiRoutes {
  // Base URLs
  static const String baseUrl = 'https://nutricare-app.firebaseapp.com';
  static const String apiVersion = 'v1';
  static const String apiBase = '$baseUrl/api/$apiVersion';

  // Firestore Collections
  static const String usersCollection = 'users';
  static const String guidesCollection = 'guides';
  static const String recipesCollection = 'recipes';
  static const String alertsCollection = 'alerts';
  static const String categoriesCollection = 'categories';
  static const String commentsCollection = 'comments';
  static const String ratingsCollection = 'ratings';

  // Authentication Endpoints
  static const String login = '$apiBase/auth/login';
  static const String register = '$apiBase/auth/register';
  static const String logout = '$apiBase/auth/logout';
  static const String refreshToken = '$apiBase/auth/refresh';
  static const String forgotPassword = '$apiBase/auth/forgot-password';
  static const String resetPassword = '$apiBase/auth/reset-password';
  static const String verifyEmail = '$apiBase/auth/verify-email';
  static const String profile = '$apiBase/auth/profile';
  static const String updateProfile = '$apiBase/auth/profile/update';
  static const String deleteAccount = '$apiBase/auth/account/delete';

  // User Management Endpoints
  static const String users = '$apiBase/users';
  static String getUserById(String userId) => '$users/$userId';
  static const String getCreators = '$users/creators';
  static const String getMembers = '$users/members';
  static const String getPendingUsers = '$users/pending';
  static String verifyUser(String userId) => '$users/$userId/verify';
  static String blockUser(String userId) => '$users/$userId/block';
  static String unblockUser(String userId) => '$users/$userId/unblock';

  // Nutrition Guides Endpoints
  static const String guides = '$apiBase/guides';
  static String getGuideById(String guideId) => '$guides/$guideId';
  static const String createGuide = '$guides/create';
  static String editGuide(String guideId) => '$guides/$guideId/update';
  static String deleteGuide(String guideId) => '$guides/$guideId/delete';
  static const String searchGuides = '$guides/search';
  static String getGuidesByCreator(String creatorId) =>
      '$guides/creator/$creatorId';
  static String getGuidesByCategory(String category) =>
      '$guides/category/$category';
  static const String getFeaturedGuides = '$guides/featured';
  static const String getLatestGuides = '$guides/latest';
  static const String getPopularGuides = '$guides/popular';

  // Recipes Endpoints
  static const String recipes = '$apiBase/recipes';
  static String getRecipeById(String recipeId) => '$recipes/$recipeId';
  static const String createRecipe = '$recipes/create';
  static String editRecipe(String recipeId) => '$recipes/$recipeId/update';
  static String deleteRecipe(String recipeId) => '$recipes/$recipeId/delete';
  static const String searchRecipes = '$recipes/search';
  static String getRecipesByCreator(String creatorId) =>
      '$recipes/creator/$creatorId';
  static String getRecipesByCategory(String category) =>
      '$recipes/category/$category';
  static const String getFeaturedRecipes = '$recipes/featured';
  static const String getLatestRecipes = '$recipes/latest';
  static const String getPopularRecipes = '$recipes/popular';
  static String getRecipeIngredients(String recipeId) =>
      '$recipes/$recipeId/ingredients';
  static String getRecipeNutrition(String recipeId) =>
      '$recipes/$recipeId/nutrition';

  // Health Alerts Endpoints
  static const String alerts = '$apiBase/alerts';
  static String getAlertById(String alertId) => '$alerts/$alertId';
  static const String createAlert = '$alerts/create';
  static String editAlert(String alertId) => '$alerts/$alertId/update';
  static String deleteAlert(String alertId) => '$alerts/$alertId/delete';
  static const String searchAlerts = '$alerts/search';
  static String getAlertsByCreator(String creatorId) =>
      '$alerts/creator/$creatorId';
  static const String getActiveAlerts = '$alerts/active';
  static const String getUrgentAlerts = '$alerts/urgent';
  static const String getLatestAlerts = '$alerts/latest';

  // Categories Endpoints
  static const String categories = '$apiBase/categories';
  static String getCategoryById(String categoryId) => '$categories/$categoryId';
  static const String getGuideCategories = '$categories/guides';
  static const String getRecipeCategories = '$categories/recipes';
  static const String getAlertCategories = '$categories/alerts';

  // Comments and Ratings Endpoints
  static const String comments = '$apiBase/comments';
  static String getCommentsByContent(String contentType, String contentId) =>
      '$comments/$contentType/$contentId';
  static String createComment(String contentType, String contentId) =>
      '$comments/$contentType/$contentId/create';
  static String editComment(String commentId) => '$comments/$commentId/update';
  static String deleteComment(String commentId) =>
      '$comments/$commentId/delete';
  static String getCommentsByUser(String userId) => '$comments/user/$userId';

  static const String ratings = '$apiBase/ratings';
  static String getRatingsByContent(String contentType, String contentId) =>
      '$ratings/$contentType/$contentId';
  static String createRating(String contentType, String contentId) =>
      '$ratings/$contentType/$contentId/create';
  static String editRating(String ratingId) => '$ratings/$ratingId/update';
  static String deleteRating(String ratingId) => '$ratings/$ratingId/delete';
  static String getRatingsByUser(String userId) => '$ratings/user/$userId';

  // Media/File Upload Endpoints
  static const String media = '$apiBase/media';
  static const String uploadMedia = '$media/upload';
  static const String deleteMedia = '$media/delete';
  static String getMediaById(String mediaId) => '$media/$mediaId';
  static const String getImages = '$media/images';
  static const String getDocuments = '$media/documents';
  static const String getCertificates = '$media/certificates';

  // Admin Endpoints
  static const String admin = '$apiBase/admin';
  static const String getAdminDashboard = '$admin/dashboard';
  static const String getAdminUsers = '$admin/users';
  static const String getAdminContent = '$admin/content';
  static const String getAdminReports = '$admin/reports';
  static const String getAdminAnalytics = '$admin/analytics';
  static const String getAdminSettings = '$admin/settings';
  static String verifyCreator(String userId) => '$admin/verify-creator/$userId';
  static String suspendUser(String userId) => '$admin/suspend-user/$userId';
  static String deleteContent(String contentType, String contentId) =>
      '$admin/delete-content/$contentType/$contentId';

  // Notification Endpoints
  static const String notifications = '$apiBase/notifications';
  static String getNotificationsByUser(String userId) =>
      '$notifications/user/$userId';
  static String markNotificationAsRead(String notificationId) =>
      '$notifications/$notificationId/read';
  static String markAllNotificationsAsRead(String userId) =>
      '$notifications/user/$userId/read-all';
  static const String sendNotification = '$notifications/send';
  static const String broadcastNotification = '$notifications/broadcast';

  // Search and Filter Endpoints
  static const String search = '$apiBase/search';
  static const String getGlobalSearch = '$search/global';
  static const String searchGuidesEndpoint = '$search/guides';
  static const String searchRecipesEndpoint = '$search/recipes';
  static const String searchAlertsEndpoint = '$search/alerts';
  static const String searchUsers = '$search/users';
  static const String getSearchSuggestions = '$search/suggestions';
  static const String getSearchFilters = '$search/filters';

  // Analytics Endpoints
  static const String analytics = '$apiBase/analytics';
  static const String getAnalyticsViews = '$analytics/views';
  static const String getAnalyticsEngagement = '$analytics/engagement';
  static const String getUserActivity = '$analytics/user-activity';
  static const String getContentPerformance = '$analytics/content-performance';
  static String trackView(String contentType, String contentId) =>
      '$analytics/track-view/$contentType/$contentId';
  static String trackEngagement(
    String contentType,
    String contentId,
    String action,
  ) => '$analytics/track-engagement/$contentType/$contentId/$action';

  // Utility Methods
  static String buildQuery(String baseUrl, Map<String, dynamic> queryParams) {
    if (queryParams.isEmpty) return baseUrl;

    final query = queryParams.entries
        .where((entry) => entry.value != null)
        .map(
          (entry) =>
              '${entry.key}=${Uri.encodeComponent(entry.value.toString())}',
        )
        .join('&');

    return '$baseUrl?$query';
  }

  static Map<String, String> getDefaultHeaders() {
    return {'Content-Type': 'application/json', 'Accept': 'application/json'};
  }

  static Map<String, String> getAuthHeaders(String token) {
    return {...getDefaultHeaders(), 'Authorization': 'Bearer $token'};
  }
}
