import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/region.dart';
import '../models/language.dart';
import '../models/category.dart';
import '../models/concept.dart';

class SupabaseService {
  static SupabaseClient get _client => Supabase.instance.client;

  // Regions
  static Future<List<Region>> getRegions() async {
    final response = await _client.from('regions').select();
    return (response as List).map((e) => Region.fromJson(e)).toList();
  }

  static Future<Region> getRegion(String id) async {
    final response = await _client.from('regions').select().eq('id', id).single();
    return Region.fromJson(response);
  }

  // Languages
  static Future<List<Language>> getLanguages({String? regionId}) async {
    var query = _client.from('languages').select();
    if (regionId != null) {
      query = query.eq('region_id', regionId);
    }
    final response = await query;
    return (response as List).map((e) => Language.fromJson(e)).toList();
  }

  static Future<Language> getLanguage(String id) async {
    final response = await _client.from('languages').select().eq('id', id).single();
    return Language.fromJson(response);
  }

  // Categories
  static Future<List<Category>> getCategories() async {
    final response = await _client.from('categories').select();
    return (response as List).map((e) => Category.fromJson(e)).toList();
  }

  // Concepts
  static Future<List<Concept>> getConcepts({
    required String languageId,
    String? categoryId,
  }) async {
    var query = _client.from('concepts').select().eq('language_id', languageId);
    if (categoryId != null) {
      query = query.eq('category_id', categoryId);
    }
    final response = await query;
    return (response as List).map((e) => Concept.fromJson(e)).toList();
  }

  static Future<Concept> getConcept(String id) async {
    final response = await _client.from('concepts').select().eq('id', id).single();
    return Concept.fromJson(response);
  }

  // Concept count per category for a language
  static Future<Map<String, int>> getConceptCounts(String languageId) async {
    final response = await _client
        .from('concepts')
        .select('category_id')
        .eq('language_id', languageId);
    final counts = <String, int>{};
    for (final row in response as List) {
      final catId = row['category_id'] as String;
      counts[catId] = (counts[catId] ?? 0) + 1;
    }
    return counts;
  }

  // Contributions
  static Future<void> submitContribution({
    required String languageId,
    String? conceptId,
    required String contributorType,
    String? audioUrl,
    String? word,
    String? translation,
  }) async {
    await _client.from('contributions').insert({
      'language_id': languageId,
      'concept_id': conceptId,
      'contributor_type': contributorType,
      'audio_url': audioUrl,
      'word': word,
      'translation': translation,
    });
  }

  // Reports
  static Future<void> submitReport({
    required String conceptId,
    required String reportType,
  }) async {
    await _client.from('reports').insert({
      'concept_id': conceptId,
      'report_type': reportType,
    });
  }

  // User Progress
  static Future<void> saveProgress({
    required String userId,
    required String conceptId,
    required int score,
    required int attempts,
  }) async {
    await _client.from('user_progress').upsert(
      {
        'user_id': userId,
        'concept_id': conceptId,
        'score': score,
        'attempts': attempts,
        'last_practiced': DateTime.now().toIso8601String(),
      },
      onConflict: 'user_id,concept_id',
    );
  }
}
