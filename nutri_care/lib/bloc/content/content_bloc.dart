import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/content_models.dart';
import '../../services/content_service.dart';
import 'content_event.dart';
import 'content_state.dart';

class ContentBloc extends Bloc<ContentEvent, ContentState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ContentService _contentService = ContentService();

  ContentBloc() : super(ContentInitial()) {
    on<LoadGuides>(_onLoadGuides);
    on<LoadRecipes>(_onLoadRecipes);
    on<LoadAlerts>(_onLoadAlerts);
    on<RefreshContent>(_onRefreshContent);
    on<DeleteRecipe>(_onDeleteRecipe);
    on<DeleteGuide>(_onDeleteGuide);
    on<UpdateRecipe>(_onUpdateRecipe);
    on<UpdateGuide>(_onUpdateGuide);
  }

  Future<void> _onLoadGuides(
    LoadGuides event,
    Emitter<ContentState> emit,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('guides')
          .orderBy('createdAt', descending: true)
          .get();

      final guides = snapshot.docs
          .map((doc) => Guide.fromMap(doc.data(), doc.id))
          .toList();

      if (state is ContentLoaded) {
        emit((state as ContentLoaded).copyWith(guides: guides));
      } else {
        emit(ContentLoaded(guides: guides));
      }
    } catch (e) {
      emit(ContentError(e.toString()));
    }
  }

  Future<void> _onLoadRecipes(
    LoadRecipes event,
    Emitter<ContentState> emit,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('recipes')
          .orderBy('createdAt', descending: true)
          .get();

      final recipes = snapshot.docs
          .map((doc) => Recipe.fromMap(doc.id, doc.data()))
          .toList();

      if (state is ContentLoaded) {
        emit((state as ContentLoaded).copyWith(recipes: recipes));
      } else {
        emit(ContentLoaded(recipes: recipes));
      }
    } catch (e) {
      emit(ContentError(e.toString()));
    }
  }

  Future<void> _onLoadAlerts(
    LoadAlerts event,
    Emitter<ContentState> emit,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('alerts')
          .orderBy('createdAt', descending: true)
          .get();

      final alerts = snapshot.docs
          .map((doc) => HealthAlert.fromMap(doc.id, doc.data()))
          .toList();

      if (state is ContentLoaded) {
        emit((state as ContentLoaded).copyWith(alerts: alerts));
      } else {
        emit(ContentLoaded(alerts: alerts));
      }
    } catch (e) {
      emit(ContentError(e.toString()));
    }
  }

  Future<void> _onRefreshContent(
    RefreshContent event,
    Emitter<ContentState> emit,
  ) async {
    emit(ContentLoading());
    add(LoadGuides());
    add(LoadRecipes());
    add(LoadAlerts());
  }

  Future<void> _onDeleteRecipe(
    DeleteRecipe event,
    Emitter<ContentState> emit,
  ) async {
    try {
      await _contentService.deleteRecipe(event.recipeId, event.currentUserId);
      add(LoadRecipes());
    } catch (e) {
      emit(ContentError(e.toString()));
    }
  }

  Future<void> _onDeleteGuide(
    DeleteGuide event,
    Emitter<ContentState> emit,
  ) async {
    try {
      await _contentService.deleteGuide(event.guideId, event.currentUserId);
      add(LoadGuides());
    } catch (e) {
      emit(ContentError(e.toString()));
    }
  }

  Future<void> _onUpdateRecipe(
    UpdateRecipe event,
    Emitter<ContentState> emit,
  ) async {
    try {
      await _contentService.updateRecipe(event.recipe, event.currentUserId);
      add(LoadRecipes());
    } catch (e) {
      emit(ContentError(e.toString()));
    }
  }

  Future<void> _onUpdateGuide(
    UpdateGuide event,
    Emitter<ContentState> emit,
  ) async {
    try {
      await _contentService.updateGuide(event.guide, event.currentUserId);
      add(LoadGuides());
    } catch (e) {
      emit(ContentError(e.toString()));
    }
  }
}