import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:persona_mirror/core/models/scenario.dart';
import 'package:persona_mirror/features/scenario/repositories/scenario_repository.dart';

// Repository provider
final scenarioRepositoryProvider = Provider<ScenarioRepository>((ref) {
  return ScenarioRepository(Supabase.instance.client);
});

// Kullanıcının kendi senaryoları
final scenariosProvider = FutureProvider<List<Scenario>>((ref) async {
  final repository = ref.read(scenarioRepositoryProvider);
  return repository.getScenarios();
});

// Hazır şablonlar
final templatesProvider = FutureProvider<List<Scenario>>((ref) async {
  final repository = ref.read(scenarioRepositoryProvider);
  return repository.getTemplates();
});

// Kullanıcı istatistikleri
final statsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repository = ref.read(scenarioRepositoryProvider);
  return repository.getStats();
});
