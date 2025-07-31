import 'package:flutter_bloc/flutter_bloc.dart';
import '../content/content_bloc.dart';
import '../content/content_state.dart';
import '../../models/content_models.dart';
import 'search_event.dart';
import 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final ContentBloc contentBloc;

  SearchBloc({required this.contentBloc}) : super(SearchInitial()) {
    on<SearchGuides>(_onSearchGuides);
    on<SearchRecipes>(_onSearchRecipes);
    on<SearchAlerts>(_onSearchAlerts);
    on<ClearSearch>(_onClearSearch);
  }

  void _onSearchGuides(SearchGuides event, Emitter<SearchState> emit) {
    if (contentBloc.state is ContentLoaded) {
      final content = contentBloc.state as ContentLoaded;
      final filteredGuides = _filterGuides(content.guides, event.query, event.category);
      emit(SearchResults(guides: filteredGuides, query: event.query));
    }
  }

  void _onSearchRecipes(SearchRecipes event, Emitter<SearchState> emit) {
    if (contentBloc.state is ContentLoaded) {
      final content = contentBloc.state as ContentLoaded;
      final filteredRecipes = _filterRecipes(content.recipes, event.query);
      emit(SearchResults(recipes: filteredRecipes, query: event.query));
    }
  }

  void _onSearchAlerts(SearchAlerts event, Emitter<SearchState> emit) {
    if (contentBloc.state is ContentLoaded) {
      final content = contentBloc.state as ContentLoaded;
      final filteredAlerts = _filterAlerts(content.alerts, event.query);
      emit(SearchResults(alerts: filteredAlerts, query: event.query));
    }
  }

  void _onClearSearch(ClearSearch event, Emitter<SearchState> emit) {
    emit(SearchInitial());
  }

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

  List<Recipe> _filterRecipes(List<Recipe> recipes, String query) {
    return recipes.where((recipe) {
      return query.isEmpty ||
          recipe.title.toLowerCase().contains(query.toLowerCase()) ||
          recipe.description.toLowerCase().contains(query.toLowerCase()) ||
          recipe.ingredients.any((ingredient) =>
              ingredient.name.toLowerCase().contains(query.toLowerCase()));
    }).toList();
  }

  List<HealthAlert> _filterAlerts(List<HealthAlert> alerts, String query) {
    return alerts.where((alert) {
      return query.isEmpty ||
          alert.title.toLowerCase().contains(query.toLowerCase()) ||
          alert.description.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }
}