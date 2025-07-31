# Search and Filter Functionality Implementation

## Overview
This document outlines the search and filter functionality implementation across the Guides, Recipes, and Alerts screens in the NutriCare app.

## Search BLoC Architecture

### SearchBloc (`lib/bloc/search/`)
- **Purpose**: Manages search and filter operations across all content types
- **Events**: 
  - `SearchGuides(String query, String? category)` - Search guides with optional category filter
  - `SearchRecipes(String query)` - Search recipes by title, description, or ingredients
  - `SearchAlerts(String query)` - Search alerts by title or description
  - `ClearSearch()` - Clear search results and return to original content

- **States**: 
  - `SearchInitial` - No search performed
  - `SearchLoading` - Search in progress (future enhancement)
  - `SearchResults(List<Guide> guides, List<Recipe> recipes, List<HealthAlert> alerts, String query)` - Search results

## Screen-Specific Implementations

### 1. Guides Screen
**Search Features:**
- Text search across title, description, and content
- Category filter dropdown with predefined categories
- Real-time search as user types
- Clear search functionality

**Filter Categories:**
- General
- Weight Management
- Healthy Eating
- Supplements
- Meal Planning
- Special Diets
- Children's Nutrition

### 2. Recipes Screen
**Search Features:**
- Text search across title and description
- Ingredient-based search (searches through all ingredients)
- Real-time search as user types
- Clear search functionality

**Search Scope:**
- Recipe title
- Recipe description
- Individual ingredient names

### 3. Alerts Screen
**Search Features:**
- Text search across title and description
- Real-time search as user types
- Clear search functionality
- Date display for better context

**Search Scope:**
- Alert title
- Alert description

## Technical Implementation

### Search Logic
```dart
// Guides filtering with category support
List<Guide> _filterGuides(List<Guide> guides, String query, String? category) {
  return guides.where((guide) {
    final matchesQuery = query.isEmpty ||
        guide.title.toLowerCase().contains(query.toLowerCase()) ||
        guide.description.toLowerCase().contains(query.toLowerCase()) ||
        guide.content.toLowerCase().contains(query.toLowerCase());
    
    final matchesCategory = category == null || 
        category.isEmpty || 
        guide.category == category;
    
    return matchesQuery && matchesCategory;
  }).toList();
}

// Recipes filtering with ingredient search
List<Recipe> _filterRecipes(List<Recipe> recipes, String query) {
  return recipes.where((recipe) {
    return query.isEmpty ||
        recipe.title.toLowerCase().contains(query.toLowerCase()) ||
        recipe.description.toLowerCase().contains(query.toLowerCase()) ||
        recipe.ingredients.any((ingredient) =>
            ingredient.name.toLowerCase().contains(query.toLowerCase()));
  }).toList();
}
```

### UI Components
- **Search TextField**: Consistent design across all screens
- **Clear Button**: Appears when search text is present
- **Filter Dropdown**: Category filter for guides
- **Real-time Search**: Updates results as user types
- **Empty States**: Contextual messages when no results found

### State Management Integration
- SearchBloc depends on ContentBloc for data source
- Search results are separate from original content state
- Clearing search returns to original ContentBloc state
- Maintains search query in state for UI feedback

## User Experience Features

### Real-time Search
- No search button required
- Results update as user types
- Debounced to prevent excessive API calls (future enhancement)

### Visual Feedback
- Clear button visibility based on search text
- Search query preserved in state
- Consistent loading and error states

### Contextual Filtering
- **Guides**: Category-based filtering for targeted content discovery
- **Recipes**: Ingredient-based search for dietary requirements
- **Alerts**: Simple text search for quick information retrieval

## Performance Considerations

### Current Implementation
- Client-side filtering for fast response
- Minimal memory overhead
- Efficient string matching algorithms

### Future Enhancements
- Server-side search for large datasets
- Search result caching
- Advanced filtering options
- Search history and suggestions
- Fuzzy search capabilities

## Testing
- Basic SearchBloc tests implemented
- Tests cover state transitions and search clearing
- Future: Add comprehensive search logic tests

## Integration Points
- Integrated with existing BLoC architecture
- Maintains consistency with app's state management pattern
- Compatible with existing content loading and error handling