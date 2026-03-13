import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/region.dart';
import '../models/language.dart';
import '../models/category.dart';
import '../models/concept.dart';
import '../services/supabase_service.dart';

// Selected region
final selectedRegionProvider = StateProvider<Region?>((ref) => null);

// Selected language
final selectedLanguageProvider = StateProvider<Language?>((ref) => null);

// User level: beginner, intermediate, native
final userLevelProvider = StateProvider<String>((ref) => 'beginner');

// Regions list
final regionsProvider = FutureProvider<List<Region>>((ref) async {
  return SupabaseService.getRegions();
});

// Languages for selected region
final languagesProvider = FutureProvider<List<Language>>((ref) async {
  final region = ref.watch(selectedRegionProvider);
  if (region == null) return [];
  return SupabaseService.getLanguages(regionId: region.id);
});

// All categories
final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  return SupabaseService.getCategories();
});

// Concepts for a specific category and language
final conceptsProvider = FutureProvider.family<List<Concept>, String>((ref, categoryId) async {
  final language = ref.watch(selectedLanguageProvider);
  if (language == null) return [];
  return SupabaseService.getConcepts(languageId: language.id, categoryId: categoryId);
});

// Concept counts per category for current language
final conceptCountsProvider = FutureProvider<Map<String, int>>((ref) async {
  final language = ref.watch(selectedLanguageProvider);
  if (language == null) return {};
  return SupabaseService.getConceptCounts(language.id);
});

// User progress tracking (local)
final userProgressProvider = StateProvider<Map<String, Map<String, dynamic>>>((ref) => {});
