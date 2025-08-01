# 🥗 NutriCare - Nutrition & Recipe Sharing App

[![Flutter](https://img.shields.io/badge/Flutter-3.8.1-blue.svg)](https://flutter.dev/)
[![Firebase](https://img.shields.io/badge/Firebase-BaaS-orange.svg)](https://firebase.google.com/)
[![BLoC](https://img.shields.io/badge/State%20Management-BLoC-green.svg)](https://bloclibrary.dev/)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

NutriCare is a comprehensive nutrition app where creators can share recipes and nutrition guides to promote healthy eating and fight malnutrition in children and adults. Built with Flutter and Firebase, it provides a seamless experience for both content creators and members seeking nutritional guidance.

## 📱 Features

### 🔐 Authentication
- **Email & Password Login/Registration**
- **Phone Number Authentication** with OTP verification
- **Role-based Access Control** (Member/Creator)
- **Profile Verification System** for creators
- **Password Reset Functionality**

### 🍳 Content Management
- **Recipe Sharing** with ingredients and instructions
- **Nutrition Guides** with detailed health information
- **Health Alerts** for important nutritional updates
- **Image Upload Support** for visual content
- **CRUD Operations** for content creators
- **Real-time Content Synchronization**

### 🎨 User Experience
- **Dark/Light Theme Toggle** with persistence
- **Intuitive Bottom Navigation**
- **Search & Filter Functionality**
- **Responsive Design** for all screen sizes
- **Offline-ready Architecture**

### 🔍 Search & Discovery
- **Global Content Search**
- **Category-based Filtering**
- **Real-time Search Results**
- **Content Type Filtering** (Recipes/Guides/Alerts)

## 🏗️ Architecture

NutriCare follows **Clean Architecture** principles with **BLoC Pattern** for state management:

```
📱 Presentation Layer (UI)
    ↕️
🧠 BLoC Layer (Business Logic)
    ↕️
🔧 Service Layer (Data Operations)
    ↕️
☁️ Firebase Backend (Data Storage)
```

### Key Components:
- **ThemeBloc**: Theme management and persistence
- **UserBloc**: Authentication and user profile management
- **ContentBloc**: Recipe, guide, and alert management
- **SearchBloc**: Search and filtering functionality
- **NavigationBloc**: Bottom navigation state management

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.8.1 or higher)
- Dart SDK (3.0.0 or higher)
- Firebase CLI
- Android Studio / VS Code
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/nutricare-app.git
   cd nutricare-app/nutri_care
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   ```bash
   # Install Firebase CLI
   npm install -g firebase-tools
   
   # Login to Firebase
   firebase login
   
   # Initialize Firebase in your project
   firebase init
   ```

4. **Configure Firebase**
   - Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/)
   - Enable Authentication (Email/Password and Phone)
   - Enable Cloud Firestore
   - Enable Firebase Storage
   - Download `google-services.json` and place it in `android/app/`
   - Download `GoogleService-Info.plist` and place it in `ios/Runner/`

5. **Run the app**
   ```bash
   # Debug mode
   flutter run
   
   # Release mode
   flutter run --release
   ```

## 🧪 Testing

NutriCare includes comprehensive testing coverage:

### Running Tests

```bash
# Run all tests
flutter test

# Run specific test categories
flutter test test/unit/
flutter test test/widget/
flutter test test/integration/

# Run tests with coverage
flutter test --coverage
```

### Test Structure
```
test/
├── unit/                 # Unit tests for BLoCs and services
│   ├── theme_bloc_test.dart
│   ├── user_bloc_test.dart
│   └── content_service_test.dart
├── widget/               # Widget tests for UI components
│   ├── theme_toggle_test.dart
│   ├── phone_auth_screen_test.dart
│   └── search_filter_test.dart
├── integration/          # Integration tests for complete flows
│   └── app_integration_test.dart
└── mocks/               # Mock services for testing
    ├── mock_auth_api.dart
    └── mock_content_service.dart
```

## 📁 Project Structure

```
lib/
├── api/                  # API services and HTTP clients
├── bloc/                 # BLoC state management
│   ├── content/         # Content management BLoC
│   ├── navigation/      # Navigation BLoC
│   ├── search/          # Search functionality BLoC
│   ├── theme/           # Theme management BLoC
│   └── user/            # User authentication BLoC
├── constants/           # App constants and colors
├── models/              # Data models and entities
├── screens/             # UI screens and pages
├── services/            # Business logic services
├── widgets/             # Reusable UI components
├── firebase_options.dart
├── main.dart
└── my_app.dart
```

## 🔧 Configuration

### Environment Variables
Create a `.env` file in the root directory:
```env
FIREBASE_API_KEY=your_api_key
FIREBASE_PROJECT_ID=your_project_id
FIREBASE_MESSAGING_SENDER_ID=your_sender_id
FIREBASE_APP_ID=your_app_id
```

### Firebase Rules
Update Firestore security rules:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own profile
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Anyone can read public content
    match /recipes/{recipeId} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.uid == resource.data.creatorId;
    }
    
    match /guides/{guideId} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.uid == resource.data.creatorId;
    }
  }
}
```

## 📊 Database Schema

### Users Collection
```json
{
  "uid": "string",
  "email": "string",
  "displayName": "string",
  "userType": "member|creator",
  "role": "user|admin",
  "isVerified": "boolean",
  "certificateUrl": "string",
  "createdAt": "timestamp",
  "lastLoginAt": "timestamp",
  "isActive": "boolean"
}
```

### Recipes Collection
```json
{
  "id": "string",
  "title": "string",
  "description": "string",
  "imageUrl": "string",
  "creatorId": "string",
  "createdAt": "timestamp",
  "ingredients": [
    {
      "name": "string",
      "amount": "string"
    }
  ]
}
```

### Guides Collection
```json
{
  "id": "string",
  "title": "string",
  "description": "string",
  "content": "string",
  "category": "string",
  "imageUrl": "string",
  "creatorId": "string",
  "createdAt": "timestamp"
}
```

## 🎯 Usage Examples

### Adding a New Recipe
```dart
// Create a new recipe
final recipe = Recipe(
  id: '',
  title: 'Healthy Smoothie',
  description: 'A nutritious breakfast smoothie',
  imageUrl: 'https://example.com/image.jpg',
  creatorId: currentUser.uid,
  createdAt: DateTime.now(),
  ingredients: [
    Ingredient(name: 'Banana', amount: '1 medium'),
    Ingredient(name: 'Spinach', amount: '1 cup'),
    Ingredient(name: 'Almond milk', amount: '1 cup'),
  ],
);

// Add to BLoC
context.read<ContentBloc>().add(CreateRecipe(recipe));
```

### Implementing Theme Toggle
```dart
// Theme toggle widget
BlocBuilder<ThemeBloc, ThemeState>(
  builder: (context, state) {
    return IconButton(
      icon: Icon(state.isDarkMode ? Icons.light_mode : Icons.dark_mode),
      onPressed: () => context.read<ThemeBloc>().add(ToggleTheme()),
    );
  },
)
```

### Search Implementation
```dart
// Search functionality
BlocBuilder<SearchBloc, SearchState>(
  builder: (context, state) {
    if (state is SearchLoaded) {
      return ListView.builder(
        itemCount: state.results.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(state.results[index].title),
            subtitle: Text(state.results[index].description),
          );
        },
      );
    }
    return CircularProgressIndicator();
  },
)
```

## 🤝 Contributing

We welcome contributions! Please follow these steps:

1. **Fork the repository**
2. **Create a feature branch** (`git checkout -b feature/amazing-feature`)
3. **Commit your changes** (`git commit -m 'Add amazing feature'`)
4. **Push to the branch** (`git push origin feature/amazing-feature`)
5. **Open a Pull Request**

### Development Guidelines
- Follow [Flutter Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Write tests for new features
- Update documentation as needed
- Use conventional commit messages

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👥 Team

- **Terry Iradukunda** - Lead Developer
- **ALU Mobile Development Team** - Contributors

## 📞 Support

For support and questions:
- 📧 Email: support@nutricare.app
- 🐛 Issues: [GitHub Issues](https://github.com/yourusername/nutricare-app/issues)
- 📖 Documentation: [Wiki](https://github.com/yourusername/nutricare-app/wiki)

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend services
- BLoC library for state management
- The open-source community for inspiration

---

**Made with ❤️ for better nutrition and healthier communities**