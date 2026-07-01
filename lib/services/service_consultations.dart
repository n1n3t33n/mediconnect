import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../modeles/modele_demande_consultation.dart';

/// Persiste les demandes de consultation (mise en relation immédiate ou
/// créneau réservé) via [SharedPreferences].
///
/// Ces demandes seront consultées côté médecin (espace médecin, Étape 9) et
/// dans l'historique du patient.
class ServiceConsultations {
  static const String _cle = 'mediconnect_demandes';

  SharedPreferences? _prefsCache;
  Future<SharedPreferences> get _prefs async =>
      _prefsCache ??= await SharedPreferences.getInstance();

  Future<List<DemandeConsultation>> toutesLesDemandes() async {
    final prefs = await _prefs;
    final brut = prefs.getString(_cle);
    if (brut == null) return [];
    return (jsonDecode(brut) as List)
        .map((e) => DemandeConsultation.depuisJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> _sauvegarder(List<DemandeConsultation> demandes) async {
    final prefs = await _prefs;
    await prefs.setString(
      _cle,
      jsonEncode(demandes.map((d) => d.versJson()).toList()),
    );
  }

  Future<DemandeConsultation> creer(DemandeConsultation demande) async {
    final demandes = await toutesLesDemandes();
    demandes.add(demande);
    await _sauvegarder(demandes);
    return demande;
  }

  Future<List<DemandeConsultation>> demandesDuPatient(String patientId) async {
    final demandes = await toutesLesDemandes();
    return demandes.where((d) => d.patientId == patientId).toList()
      ..sort((a, b) => b.dateCreation.compareTo(a.dateCreation));
  }

  Future<List<DemandeConsultation>> demandesDuMedecin(String medecinId) async {
    final demandes = await toutesLesDemandes();
    return demandes.where((d) => d.medecinId == medecinId).toList()
      ..sort((a, b) => b.dateCreation.compareTo(a.dateCreation));
  }
}
