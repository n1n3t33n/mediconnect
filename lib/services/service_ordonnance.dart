import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../modeles/modele_ordonnance.dart';

/// Persiste les ordonnances numériques et permet de les retrouver côté patient
/// (réception) comme côté médecin (émission), ou pour une consultation donnée.
class ServiceOrdonnance {
  static const String _cle = 'mediconnect_ordonnances';

  SharedPreferences? _prefsCache;
  Future<SharedPreferences> get _prefs async =>
      _prefsCache ??= await SharedPreferences.getInstance();

  Future<List<Ordonnance>> _charger() async {
    final prefs = await _prefs;
    final brut = prefs.getString(_cle);
    if (brut == null) return [];
    return (jsonDecode(brut) as List)
        .map((e) => Ordonnance.depuisJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> _sauvegarder(List<Ordonnance> ordonnances) async {
    final prefs = await _prefs;
    await prefs.setString(
      _cle,
      jsonEncode(ordonnances.map((o) => o.versJson()).toList()),
    );
  }

  /// Enregistre une nouvelle ordonnance.
  Future<Ordonnance> creerOrdonnance(Ordonnance ordonnance) async {
    final ordonnances = await _charger();
    ordonnances.add(ordonnance);
    await _sauvegarder(ordonnances);
    return ordonnance;
  }

  /// Ordonnance rattachée à une consultation, ou `null` s'il n'y en a pas.
  Future<Ordonnance?> ordonnancePourConsultation(String consultationId) async {
    final ordonnances = await _charger();
    for (final o in ordonnances) {
      if (o.consultationId == consultationId) return o;
    }
    return null;
  }

  Future<List<Ordonnance>> ordonnancesPatient(String patientId) async {
    final ordonnances = await _charger();
    return ordonnances.where((o) => o.patientId == patientId).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<List<Ordonnance>> ordonnancesMedecin(String medecinId) async {
    final ordonnances = await _charger();
    return ordonnances.where((o) => o.medecinId == medecinId).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }
}
