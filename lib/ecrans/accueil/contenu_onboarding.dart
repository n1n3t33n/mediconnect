import 'package:flutter/material.dart';

import '../../config/couleurs_application.dart';

/// Contenu d'une page d'onboarding (illustration + texte).
class PageOnboarding {
  const PageOnboarding({
    required this.titre,
    required this.description,
    required this.icone,
    required this.couleurIcone,
  });

  final String titre;
  final String description;
  final IconData icone;
  final Color couleurIcone;
}

/// Pages présentées à l'utilisateur lors du premier lancement de MediConnect.
///
/// Elles résument les fonctionnalités clés : consultation à distance,
/// auto-diagnostic, ordonnance numérique et paiement Mobile Money.
const List<PageOnboarding> pagesOnboarding = [
  PageOnboarding(
    titre: 'Bienvenue sur MediConnect',
    description:
        'Votre santé, connectée. Consultez un médecin où que vous soyez, '
        'sans avoir à vous déplacer.',
    icone: Icons.health_and_safety,
    couleurIcone: CouleursApplication.primaire,
  ),
  PageOnboarding(
    titre: 'Auto-diagnostic guidé',
    description:
        'Évaluez vos symptômes en quelques questions simples et recevez une '
        'orientation claire avant votre consultation.',
    icone: Icons.fact_check_outlined,
    couleurIcone: CouleursApplication.accent,
  ),
  PageOnboarding(
    titre: 'Téléconsultation & ordonnance',
    description:
        'Échangez avec un médecin par appel audio ou vidéo et recevez votre '
        'ordonnance numérique directement sur votre téléphone.',
    icone: Icons.medical_services_outlined,
    couleurIcone: CouleursApplication.succes,
  ),
  PageOnboarding(
    titre: 'Paiement Mobile Money',
    description:
        'Réglez votre consultation en toute simplicité via Wave, Orange Money, '
        'MTN Mobile Money ou Moov Money.',
    icone: Icons.payments_outlined,
    couleurIcone: CouleursApplication.primaireFonce,
  ),
];
