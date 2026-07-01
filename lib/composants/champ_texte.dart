import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Champ de saisie de texte standard de MediConnect.
///
/// Enveloppe un [TextFormField] et s'appuie sur le thème global
/// (`inputDecorationTheme`) pour l'apparence. Gère libellé, indication, icône,
/// masquage (mot de passe), type de clavier, filtres de saisie et validation.
class ChampTexte extends StatelessWidget {
  const ChampTexte({
    super.key,
    required this.libelle,
    this.indication,
    this.controleur,
    this.icone,
    this.estMotDePasse = false,
    this.typeClavier,
    this.formateurs,
    this.validateur,
    this.onChange,
  });

  final String libelle;
  final String? indication;
  final TextEditingController? controleur;
  final IconData? icone;
  final bool estMotDePasse;
  final TextInputType? typeClavier;
  final List<TextInputFormatter>? formateurs;
  final String? Function(String?)? validateur;
  final ValueChanged<String>? onChange;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controleur,
      obscureText: estMotDePasse,
      keyboardType: typeClavier,
      inputFormatters: formateurs,
      validator: validateur,
      onChanged: onChange,
      decoration: InputDecoration(
        labelText: libelle,
        hintText: indication,
        prefixIcon: icone != null ? Icon(icone) : null,
      ),
    );
  }
}
