import 'package:flutter/material.dart';

import '../../composants/arriere_plan_anime.dart';
import '../../composants/bouton_principal.dart';
import '../../composants/indicateur_pages.dart';
import '../../config/couleurs_application.dart';
import '../../config/dimensions_application.dart';
import 'contenu_onboarding.dart';

/// Écran d'accueil animé (onboarding) de MediConnect.
///
/// Présente les fonctionnalités clés sur plusieurs pages défilantes, sur fond
/// d'animation Rive. Le bouton final mènera à l'authentification (Étape 3).
class EcranOnboarding extends StatefulWidget {
  const EcranOnboarding({super.key});

  @override
  State<EcranOnboarding> createState() => _EcranOnboardingState();
}

class _EcranOnboardingState extends State<EcranOnboarding> {
  final PageController _controleurPages = PageController();
  int _index = 0;

  bool get _dernierePage => _index == pagesOnboarding.length - 1;

  @override
  void dispose() {
    _controleurPages.dispose();
    super.dispose();
  }

  void _pageSuivante() {
    if (_dernierePage) {
      _terminerOnboarding();
    } else {
      _controleurPages.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  void _passer() {
    _controleurPages.animateToPage(
      pagesOnboarding.length - 1,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeInOut,
    );
  }

  void _terminerOnboarding() {
    // L'écran d'authentification sera branché ici à l'Étape 3.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Authentification disponible à l\'étape suivante.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: ArrierePlanAnime()),
          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: AnimatedOpacity(
                    opacity: _dernierePage ? 0 : 1,
                    duration: const Duration(milliseconds: 200),
                    child: TextButton(
                      onPressed: _dernierePage ? null : _passer,
                      child: const Text('Passer'),
                    ),
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _controleurPages,
                    itemCount: pagesOnboarding.length,
                    onPageChanged: (i) => setState(() => _index = i),
                    itemBuilder: (context, i) =>
                        _VuePageOnboarding(page: pagesOnboarding[i]),
                  ),
                ),
                IndicateurPages(
                  nombre: pagesOnboarding.length,
                  indexActif: _index,
                ),
                Padding(
                  padding: const EdgeInsets.all(
                    DimensionsApplication.espacementGrand,
                  ),
                  child: BoutonPrincipal(
                    libelle: _dernierePage ? 'Commencer' : 'Suivant',
                    icone: _dernierePage
                        ? Icons.check_circle_outline
                        : Icons.arrow_forward,
                    onPressed: _pageSuivante,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Rendu d'une page d'onboarding : illustration circulaire, titre, description.
class _VuePageOnboarding extends StatelessWidget {
  const _VuePageOnboarding({required this.page});

  final PageOnboarding page;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DimensionsApplication.espacementTresGrand,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 168,
            height: 168,
            decoration: BoxDecoration(
              color: page.couleurIcone.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(page.icone, size: 84, color: page.couleurIcone),
          ),
          const SizedBox(height: DimensionsApplication.espacementTresGrand),
          Text(
            page.titre,
            textAlign: TextAlign.center,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: CouleursApplication.textePrincipal,
            ),
          ),
          const SizedBox(height: DimensionsApplication.espacementMoyen),
          Text(
            page.description,
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge?.copyWith(
              color: CouleursApplication.texteSecondaire,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
