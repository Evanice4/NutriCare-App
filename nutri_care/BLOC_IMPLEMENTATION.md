# BLoC State Management Implementation

## Overview
This document outlines the BLoC (Business Logic Component) pattern implementation in the NutriCare app, along with the UI updates to match the Figma design specifications.

## BLoC Architecture

### 1. Navigation BLoC (`lib/bloc/navigation/`)
- **Purpose**: Manages bottom navigation tab state
- **Events**: `NavigateToTab(int tabIndex)`
- **States**: `NavigationState(int currentIndex)`
- **Usage**: Handles tab switching in the main home screen

### 2. User BLoC (`lib/bloc/user/`)
- **Purpose**: Manages user authentication and profile state
- **Events**: 
  - `LoadUserProfile(String uid)`
  - `SignOutUser()`
  - `UpdateUserProfile(Map<String, dynamic> updates)`
- **States**: 
  - `UserInitial`
  - `UserLoading`
  - `UserLoaded(UserProfile user)`
  - `UserError(String message)`
  - `UserSignedOut`

### 3. Content BLoC (`lib/bloc/content/`)
- **Purpose**: Manages guides, recipes, and alerts data
- **Events**: 
  - `LoadGuides()`
  - `LoadRecipes()`
  - `LoadAlerts()`
  - `RefreshContent()`
- **States**: 
  - `ContentInitial`
  - `ContentLoading`
  - `ContentLoaded(List<Guide> guides, List<Recipe> recipes, List<HealthAlert> alerts)`
  - `ContentError(String message)`

## UI Color Updates (Figma Design)

### Color Scheme Implementation
- **Home Screen Background**: Green (#01923B)
- **Guides/Recipes/Alerts Background**: Yellow (#CBC615)
- **Bottom Navigation Background**: Yellow (#CBC615)
- **Colors defined in**: `lib/constants/colors.dart`

### Screen Updates
1. **HomeScreen**: Green background for home tab, yellow for other tabs
2. **GuidesScreen**: Yellow background with white text
3. **RecipesScreen**: Yellow background with white text
4. **AlertsScreen**: Yellow background with white text
5. **Bottom Navigation**: Yellow background with black selected items

## Key Benefits

### Scalability
- Centralized state management
- Clear separation of business logic from UI
- Easy to add new features and states

### Testability
- BLoC components are easily testable
- Mock data can be injected for testing
- State changes are predictable

### Maintainability
- Single source of truth for each state
- Reactive programming model
- Clear data flow patterns

## Integration Points

### Main App Setup
```dart
MultiBlocProvider(
  providers: [
    BlocProvider<NavigationBloc>(create: (context) => NavigationBloc()),
    BlocProvider<UserBloc>(create: (context) => UserBloc()),
    BlocProvider<ContentBloc>(create: (context) => ContentBloc()),
  ],
  child: MaterialApp(...)
)
```

### Screen Usage
- Screens use `BlocBuilder` and `BlocListener` widgets
- Events are dispatched using `context.read<BlocType>().add(Event())`
- State changes trigger UI rebuilds automatically

### Content Refresh
- Creating new guides/recipes triggers content refresh
- Real-time updates through BLoC state management
- Optimistic UI updates for better user experience

## Testing
- Basic BLoC tests implemented in `test/bloc_test.dart`
- Uses `bloc_test` package for comprehensive testing
- Tests cover state transitions and event handling

## Future Enhancements
- Add caching layer for offline support
- Implement optimistic updates
- Add more granular loading states
- Implement real-time data synchronization