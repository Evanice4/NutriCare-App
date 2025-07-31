# NutriCare App - Architecture Snapshot

## 🏗️ Clean Architecture Layers

```
┌─────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                       │
├─────────────────────────────────────────────────────────────┤
│  📱 UI Components (Screens & Widgets)                      │
│  • HomeScreen, LoginScreen, RegistrationScreen             │
│  • GuidesScreen, RecipesScreen, AlertsScreen               │
│  • AuthWrapper (State Management)                          │
│  • Custom Widgets (_QuickLinkCard, _DidYouKnowCard)       │
└─────────────────────────────────────────────────────────────┘
                              ↕️
┌─────────────────────────────────────────────────────────────┐
│                    DOMAIN LAYER                            │
├─────────────────────────────────────────────────────────────┤
│  🎯 Business Logic & Models                                │
│  • UserProfile (User entity)                              │
│  • Recipe, Guide, NutritionGuide (Content entities)       │
│  • HealthAlert, Ingredient (Supporting entities)          │
│  • AuthResult (Value objects)                             │
└─────────────────────────────────────────────────────────────┘
                              ↕️
┌─────────────────────────────────────────────────────────────┐
│                    DATA LAYER                              │
├─────────────────────────────────────────────────────────────┤
│  🔌 API Services & Data Sources                           │
│  • AuthApi (Firebase Authentication)                      │
│  • FirestoreContentApi (Cloud Firestore)                 │
│  • HttpApiClient (HTTP requests)                          │
│  • ServiceLocator (Dependency Injection)                  │
└─────────────────────────────────────────────────────────────┘
                              ↕️
┌─────────────────────────────────────────────────────────────┐
│                 EXTERNAL SERVICES                          │
├─────────────────────────────────────────────────────────────┤
│  ☁️ Firebase Services                                      │
│  • Firebase Auth (User authentication)                    │
│  • Cloud Firestore (NoSQL database)                      │
│  • Firebase Storage (File storage)                        │
└─────────────────────────────────────────────────────────────┘
```

## 🔄 State Management Pattern

### **Pattern Used: StatefulWidget + StreamBuilder (Firebase Reactive)**

```
┌─────────────────────────────────────────────────────────────┐
│                 STATE MANAGEMENT FLOW                      │
└─────────────────────────────────────────────────────────────┘

Firebase Auth State Changes
           ↓
    AuthWrapper (StreamBuilder)
           ↓
   ┌─────────────────┐    ┌─────────────────┐
   │   Authenticated │    │ Not Authenticated│
   │   HomeScreen    │    │   LoginScreen    │
   └─────────────────┘    └─────────────────┘
           ↓
   StatefulWidget State Management
           ↓
   ┌─────────────────────────────────────────┐
   │  Local State (setState)                 │
   │  • _currentIndex (navigation)           │
   │  • _loading (async operations)          │
   │  • _currentUser (user profile)          │
   │  • Form states (_emailController, etc.) │
   └─────────────────────────────────────────┘
           ↓
   Firebase Streams (Real-time updates)
   • guidesStream()
   • recipesStream()  
   • alertsStream()
```

### **Key State Management Components:**

1. **AuthWrapper**: Central authentication state management
2. **StatefulWidget**: Local component state (forms, navigation)
3. **StreamBuilder**: Real-time data from Firebase
4. **ServiceLocator**: Dependency injection pattern

## 📊 Miniature Entity Relationship Diagram (ERD)

```
┌─────────────────────────────────────────────────────────────┐
│                    NUTRICARE DATABASE SCHEMA               │
└─────────────────────────────────────────────────────────────┘

┌─────────────────┐         ┌─────────────────┐
│     USERS       │         │     GUIDES      │
├─────────────────┤         ├─────────────────┤
│ uid (PK)        │◄────────┤ id (PK)         │
│ email           │    1:N  │ title           │
│ displayName     │         │ description     │
│ userType        │         │ content         │
│ role            │         │ category        │
│ isVerified      │         │ imageUrl        │
│ certificateUrl  │         │ creatorId (FK)  │
│ createdAt       │         │ createdAt       │
│ lastLoginAt     │         └─────────────────┘
│ isActive        │
└─────────────────┘
        │
        │ 1:N
        ▼
┌─────────────────┐         ┌─────────────────┐
│    RECIPES      │         │   INGREDIENTS   │
├─────────────────┤         ├─────────────────┤
│ id (PK)         │◄────────┤ recipeId (FK)   │
│ title           │    1:N  │ name            │
│ description     │         │ amount          │
│ imageUrl        │         └─────────────────┘
│ creatorId (FK)  │
│ createdAt       │
│ ingredients[]   │
└─────────────────┘
        ▲
        │ 1:N
        │
┌─────────────────┐
│  HEALTH_ALERTS  │
├─────────────────┤
│ id (PK)         │
│ title           │
│ description     │
│ creatorId (FK)  │
│ createdAt       │
└─────────────────┘

RELATIONSHIPS:
• Users (1) ──── (N) Guides
• Users (1) ──── (N) Recipes  
• Users (1) ──── (N) HealthAlerts
• Recipes (1) ──── (N) Ingredients
```

## 🔧 Architecture Patterns & Principles

### **1. Dependency Injection**
```dart
// ServiceLocator pattern for centralized service management
class ServiceLocator {
  late final AuthApi _authApi;
  late final FirestoreContentApi _contentApi;
  late final HttpApiClient _httpClient;
}
```

### **2. Repository Pattern (Implicit)**
```dart
// API classes act as repositories
class AuthApi {
  Future<AuthResult> loginWithEmailAndPassword();
  Future<UserProfile?> getUserProfile();
}

class FirestoreContentApi {
  Stream<List<Recipe>> recipesStream();
  Future<String> createRecipe(Recipe recipe);
}
```

### **3. Model-View Pattern**
```dart
// Models represent domain entities
class UserProfile {
  final String uid;
  final String email;
  final String userType;
  // Business logic methods
}

// Views handle UI presentation
class HomeScreen extends StatefulWidget {
  // UI logic and state management
}
```

## 📱 Key Features & Components

### **Authentication Flow**
- Firebase Authentication integration
- Role-based access (Member/Creator)
- Profile verification system
- Password reset functionality

### **Content Management**
- CRUD operations for Guides, Recipes, Alerts
- Real-time data synchronization
- Image upload support
- Creator-specific content filtering

### **Navigation Structure**
- Bottom navigation with 4 main sections
- Route-based navigation system
- Authentication-aware routing

### **Data Persistence**
- Cloud Firestore for real-time data
- Firebase Storage for media files
- Local state management for UI

## 🚀 Technology Stack

- **Frontend**: Flutter (Dart)
- **Backend**: Firebase (BaaS)
- **Database**: Cloud Firestore (NoSQL)
- **Authentication**: Firebase Auth
- **Storage**: Firebase Storage
- **State Management**: StatefulWidget + Streams
- **Architecture**: Clean Architecture principles

## 📋 Future Enhancements

1. **State Management**: Migrate to BLoC/Cubit for complex state
2. **Offline Support**: Implement local caching
3. **Testing**: Add unit and integration tests
4. **Performance**: Implement pagination and lazy loading
5. **Analytics**: Add Firebase Analytics integration