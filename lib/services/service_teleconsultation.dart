import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../modeles/modele_consultation.dart';

/// Persiste les consultations (sessions de téléconsultation) et leur synthèse.
///
/// Sert d'historique consultable par le patient et le médecin.
class ServiceTeleconsultation {
  static const String _cle = 'mediconnect_consultations';

  SharedPreferences? _prefsCache;
  Future<SharedPreferences> get _prefs async =>
      _prefsCache ??= await SharedPreferences.getInstance();

  Future<List<Consultation>> _charger() async {
    final prefs = await _prefs;
    final brut = prefs.getString(_cle);
    if (brut == null) return [];
    return (jsonDecode(brut) as List)
        .map((e) => Consultation.depuisJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> _sauvegarder(List<Consultation> consultations) async {
    final prefs = await _prefs;
    await prefs.setString(
      _cle,
      jsonEncode(consultations.map((c) => c.versJson()).toList()),
    );
  }

  /// Enregistre une consultation démarrée (statut en cours).
  Future<Consultation> creerConsultation(Consultation consultation) async {
    final consultations = await _charger();
    consultations.add(consultation);
    await _sauvegarder(consultations);
    return consultation;
  }

  /// Termine une consultation : met à jour la durée et, éventuellement, la
  /// synthèse.
  Future<Consultation?> terminerConsultation(
    String id, {
    required int dureeSecondes,
    String? synthese,
  }) async {
    final consultations = await _charger();
    final index = consultations.indexWhere((c) => c.id == id);
    if (index == -1) return null;
    consultations[index] = consultations[index].copierAvec(
      statut: StatutConsultation.terminee,
      dureeSecondes: dureeSecondes,
      synthese: synthese,
    );
    await _sauvegarder(consultations);
    return consultations[index];
  }

  /// Enregistre / met à jour la synthèse rédigée par le médecin.
  Future<Consultation?> enregistrerSynthese(String id, String synthese) async {
    final consultations = await _charger();
    final index = consultations.indexWhere((c) => c.id == id);
    if (index == -1) return null;
    consultations[index] = consultations[index].copierAvec(
      statut: StatutConsultation.terminee,
      synthese: synthese,
    );
    await _sauvegarder(consultations);
    return consultations[index];
  }

  Future<List<Consultation>> historiquePatient(String patientId) async {
    final consultations = await _charger();
    return consultations.where((c) => c.patientId == patientId).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<List<Consultation>> historiqueMedecin(String medecinId) async {
    final consultations = await _charger();
    return consultations.where((c) => c.medecinId == medecinId).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }
}
