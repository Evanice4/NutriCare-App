# NutriCare App - System Architecture

## 🏗️ Clean Architecture Layers with BLoC Pattern

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

### **Pattern Used: BLoC (Business Logic Component) + Firebase Integration**

```
┌─────────────────────────────────────────────────────────────┐
│                    BLOC ARCHITECTURE LAYERS                        │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│  📱 PRESENTATION LAYER (UI)                              │
├─────────────────────────────────────────────────────────────┤
│  • BlocBuilder<ThemeBloc, ThemeState>                     │
│  • BlocBuilder<UserBloc, UserState>                       │
│  • BlocBuilder<ContentBloc, ContentState>                 │
│  • BlocBuilder<SearchBloc, SearchState>                   │
│  • BlocBuilder<NavigationBloc, NavigationState>           │
└─────────────────────────────────────────────────────────────┘
                              ↕️
┌─────────────────────────────────────────────────────────────┐
│                    BLOC LAYER                              │
├─────────────────────────────────────────────────────────────┤
│  🎯 ThemeBloc (Theme Management)                        │
│  👤 UserBloc (Authentication & Profile)                 │
│  📝 ContentBloc (Recipes, Guides, Alerts)               │
│  🔍 SearchBloc (Search & Filter)                        │
│  🧭 NavigationBloc (Bottom Navigation)                  │
└─────────────────────────────────────────────────────────────┘
                              ↕️
┌─────────────────────────────────────────────────────────────┐
│                 SERVICE LAYER                              │
├─────────────────────────────────────────────────────────────┤
│  🔌 AuthApi (Firebase Authentication)                  │
│  📄 ContentService (CRUD Operations)                    │
│  🌐 FirestoreContentApi (Database)                     │
│  📡 HttpApiClient (HTTP Requests)                      │
└─────────────────────────────────────────────────────────────┘
```

### **BLoC Event Flow:**

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

## 🧪 Testing Architecture

### **Test Coverage Structure**

```
┌─────────────────────────────────────────────────────────────┐
│                    TESTING PYRAMID                         │
└─────────────────────────────────────────────────────────────┘

                    🔺 Integration Tests
                   /                    \
                  /   App Flow Tests     \
                 /   Authentication      \
                /   Navigation Tests      \
               /_________________________\
              /                           \
             /        Widget Tests         \
            /   Theme Toggle, Search UI    \
           /   Phone Auth, Filter Chips    \
          /________________________________\
         /                                  \
        /            Unit Tests              \
       /   BLoC Tests, Service Tests         \
      /   ThemeBloc, UserBloc, ContentBloc   \
     /____________________________________\
```

### **Test Categories:**

1. **Unit Tests** (`test/unit/`)
   - BLoC state management tests
   - Service layer tests
   - Model validation tests

2. **Widget Tests** (`test/widget/`)
   - UI component behavior
   - User interaction testing
   - Theme switching validation

3. **Integration Tests** (`test/integration/`)
   - Complete user flows
   - Authentication workflows
   - Navigation testing

4. **Mock Services** (`test/mocks/`)
   - MockAuthApi for authentication testing
   - MockContentService for data operations
   - Firebase emulator integration

## 📋 Future Enhancements

1. **Offline Support**: Implement local caching with Hive/SQLite
2. **Performance**: Add pagination and lazy loading
3. **Analytics**: Firebase Analytics integration
4. **Push Notifications**: FCM implementation
5. **Accessibility**: Enhanced screen reader support