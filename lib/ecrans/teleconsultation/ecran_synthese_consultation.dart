import 'package:flutter/material.dart';

import '../../composants/bouton_principal.dart';
import '../../config/couleurs_application.dart';
import '../../config/dimensions_application.dart';
import '../../modeles/modele_consultation.dart';
import '../../services/service_teleconsultation.dart';
import '../../utilitaires/validateurs.dart';
import 'ecran_detail_consultation.dart';

/// Rédaction de la synthèse de consultation par le médecin (cf. cahier 4.4 §15).
class EcranSyntheseConsultation extends StatefulWidget {
  const EcranSyntheseConsultation({super.key, required this.consultation});

  final Consultation consultation;

  @override
  State<EcranSyntheseConsultation> createState() =>
      _EcranSyntheseConsultationState();
}

class _EcranSyntheseConsultationState extends State<EcranSyntheseConsultation> {
  final _cleFormulaire = GlobalKey<FormState>();
  final _controleurSynthese = TextEditingController();
  final _service = ServiceTeleconsultation();
  bool _enCours = false;

  @override
  void initState() {
    super.initState();
    _controleurSynthese.text = widget.consultation.synthese ?? '';
  }

  @override
  void dispose() {
    _controleurSynthese.dispose();
    super.dispose();
  }

  Future<void> _valider() async {
    if (!_cleFormulaire.currentState!.validate()) return;
    setState(() => _enCours = true);
    final maj = await _service.enregistrerSynthese(
      widget.consultation.id,
      _controleurSynthese.text.trim(),
    );
    if (!mounted) return;
    setState(() => _enCours = false);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) =>
            EcranDetailConsultation(consultation: maj ?? widget.consultation),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Synthèse de consultation')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(DimensionsApplication.espacementGrand),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: DimensionsApplication.largeurMaxContenu,
              ),
              child: Form(
                key: _cleFormulaire,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Consultation avec ${widget.consultation.patientNom}',
                      style: textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: DimensionsApplication.espacementPetit),
                    Text(
                      'Rédigez une synthèse courte, qui sera visible par le '
                      'patient dans son historique.',
                      style: textTheme.bodySmall?.copyWith(
                        color: CouleursApplication.texteSecondaire,
                      ),
                    ),
                    const SizedBox(height: DimensionsApplication.espacementGrand),
                    TextFormField(
                      controller: _controleurSynthese,
                      minLines: 5,
                      maxLines: 10,
                      validator: Validateurs.champObligatoire,
                      decoration: const InputDecoration(
                        labelText: 'Synthèse de la consultation',
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: DimensionsApplication.espacementGrand),
                    BoutonPrincipal(
                      libelle: 'Valider la synthèse',
                      icone: Icons.check,
                      enChargement: _enCours,
                      onPressed: _valider,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
