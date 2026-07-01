# MediConnect

Application mobile de **santé connectée** pour la Côte d'Ivoire : téléconsultation,
auto-diagnostic, ordonnances numériques et paiement Mobile Money.

> Projet étudiant E-Santé — prototype développé **exclusivement en Flutter/Dart**.

## Objectifs

- Réduire le délai d'accès à un avis médical, surtout pour les zones éloignées.
- Permettre un pré-diagnostic à domicile avant la mise en relation avec un médecin.
- Dématérialiser l'ordonnance (PDF) et la rendre immédiatement disponible.
- Proposer un paiement accessible via Mobile Money (Wave, Orange Money, MTN, Moov).

## Stack technique

- **Flutter / Dart** (mobile prioritaire : Android, puis iOS ; web allégé pour test).
- **Gestion d'état :** `provider`.
- **Navigation :** `go_router`.
- **Animations :** `rive` (onboarding).
- **Autres :** `http`, `shared_preferences`, `intl`, `google_fonts`.

## Architecture (nomenclature française)

Un fichier = une responsabilité ; les dossiers portent le nom de leur fonctionnalité.

```
lib/
  principal.dart        # point d'entrée de l'application
  config/               # thème, couleurs, constantes
  modeles/              # modèles de données (modele_utilisateur.dart, …)
  services/             # logique métier / API (service_authentification.dart, …)
  fournisseurs/         # gestion d'état (Provider)
  ecrans/               # écrans regroupés par fonctionnalité
    authentification/
    auto_diagnostic/
    recherche_medecin/
    teleconsultation/
    ordonnance/
    paiement/
    espace_medecin/
    administration/
    suivi_chronique/
    dossier_familial/
  composants/           # widgets réutilisables (bouton_principal.dart, …)
  utilitaires/          # fonctions utilitaires
assets/
  animations/           # fichiers .riv
  images/
```

## Démarrage

Prérequis : Flutter 3.32+ / Dart 3.8+.

```bash
flutter pub get

# Lancement (le point d'entrée est lib/principal.dart, pas lib/main.dart)
flutter run -d chrome -t lib/principal.dart     # test rapide dans le navigateur
flutter run -t lib/principal.dart               # appareil / émulateur Android

# Analyse statique et tests
flutter analyze
flutter test
```

Sous VS Code, les configurations de lancement (`.vscode/launch.json`) pointent déjà
sur `lib/principal.dart` : la touche F5 fonctionne directement.

## Feuille de route (étapes)

| Étape | Contenu |
|-------|---------|
| 0 | Initialisation : structure, dépendances, dépôt git |
| 1 | Design system & thème |
| 2 | Onboarding animé (Rive) |
| 3 | Authentification (patient / médecin) |
| 4 | Auto-diagnostic |
| 5 | Recherche & mise en relation médecin |
| 6 | Téléconsultation |
| 7 | Ordonnance numérique |
| 8 | Paiement Mobile Money |
| 9 | Espace médecin & back-office admin |
| 10 | Suivi chronique, renouvellement & dossier familial |
| 11 | Finitions & exigences non fonctionnelles |

## Crédits

- Animations Rive (`assets/animations/shapes.riv`, `button.riv`) issues du template
  public **« Build an Animated App with Rive and Flutter »** d'Abu Anwar, adaptées
  pour l'onboarding MediConnect.
