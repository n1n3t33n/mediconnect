# MediConnect

Application mobile de **santé connectée** pour la Côte d'Ivoire : téléconsultation,
auto-diagnostic, ordonnances numériques et paiement Mobile Money.

> Projet étudiant E-Santé — prototype développé **exclusivement en Flutter/Dart**.
> Les services (SMS, appels, paiements, back-end) sont **simulés** : aucune donnée
> réelle n'est transmise, la persistance se fait en local (`shared_preferences`).

## Objectifs

- Réduire le délai d'accès à un avis médical, surtout pour les zones éloignées.
- Permettre un pré-diagnostic à domicile avant la mise en relation avec un médecin.
- Dématérialiser l'ordonnance (PDF horodaté / signé) et la rendre immédiatement disponible.
- Proposer un paiement accessible via Mobile Money (Wave, Orange Money, MTN, Moov).

## Stack technique

- **Flutter / Dart** (mobile prioritaire : Android, puis iOS ; web allégé pour test).
- **Gestion d'état :** `provider`.
- **Navigation :** `go_router` (déclaré) + `Navigator` pour les flux transitoires.
- **Animations :** `rive` (onboarding).
- **Ordonnance :** `pdf` + `printing` (génération / impression / partage PDF), `qr_flutter` (QR de partage).
- **Autres :** `http`, `shared_preferences`, `intl`, `google_fonts`.

## Architecture (nomenclature française)

Un fichier = une responsabilité ; les dossiers portent le nom de leur fonctionnalité.

```
lib/
  main.dart             # point d'entrée par défaut de l'outillage (délègue à principal.dart)
  principal.dart        # démarrage réel de l'application (MultiProvider + thème)
  config/               # thème, couleurs, dimensions, constantes, typographie
  modeles/              # modèles de données (modele_utilisateur.dart, modele_ordonnance.dart, …)
  services/             # logique métier / persistance (service_authentification.dart, …)
  fournisseurs/         # gestion d'état (Provider / ChangeNotifier)
  ecrans/               # écrans regroupés par fonctionnalité
    authentification/
    accueil/
    auto_diagnostic/
    recherche_medecin/
    teleconsultation/
    ordonnance/
    (paiement/, espace_medecin/, administration/, suivi_chronique/, dossier_familial/ — à venir)
  composants/           # widgets réutilisables (bouton_principal.dart, carte_ordonnance.dart, …)
  utilitaires/          # fonctions utilitaires (formatage_date.dart, validateurs.dart, générateur PDF…)
assets/
  animations/           # fichiers .riv
  images/
```

## Démarrage

Prérequis : Flutter 3.32+ / Dart 3.8+.

```bash
flutter pub get

# Lancement (lib/main.dart délègue au démarrage réel de lib/principal.dart)
flutter run -d chrome     # test rapide dans le navigateur
flutter run               # appareil / émulateur Android

# Analyse statique et tests
flutter analyze
flutter test
```

> Historique : le point d'entrée métier a été renommé `lib/principal.dart` (nomenclature
> française). `lib/main.dart` est un stub minimal requis par Flutter qui appelle simplement
> `principal.dart`, de sorte que `flutter run` fonctionne sans l'option `-t`. Les configurations
> VS Code (`.vscode/launch.json`) ciblent `lib/principal.dart` : la touche F5 fonctionne aussi.

## Comptes de démonstration

Trois comptes sont pré-chargés pour les tests (téléphone / mot de passe) :

| Rôle | Téléphone | Mot de passe | Remarque |
|------|-----------|--------------|----------|
| Administrateur | `0700000000` | `admin123` | — |
| Médecin | `0700000001` | `medecin123` | compte **validé** |
| Patient | `0700000002` | `patient123` | — |

La connexion par SMS est simulée : le code à 6 chiffres est renvoyé directement par le
service (affiché à l'écran) au lieu d'être envoyé par un vrai SMS.

## Fonctionnalités implémentées

### Étape 0 — Initialisation
Squelette Flutter, dépôt git dédié, arborescence française, dépendances de base.

### Étape 1 — Design system & thème
Palette santé (bleu-vert médical + accent orange), typographie Poppins (`google_fonts`),
dimensions/espacements centralisés, thème Material 3 et composants de base
(boutons, champ de saisie, carte).

### Étape 2 — Onboarding animé (Rive)
Écrans d'introduction avec fond animé Rive, indicateur de pages, aiguillage
onboarding → portail d'authentification.

### Étape 3 — Authentification
Inscription et connexion patient / médecin, vérification par **SMS simulé**,
récupération de mot de passe. Le compte médecin doit être **validé** avant activation.
Session persistée localement.

### Étape 4 — Auto-diagnostic
Questionnaire **adaptatif** (les questions dépendent des réponses), évaluation de la
**criticité** (faible → urgence), orientation, et **avertissement légal** rappelant que
l'auto-diagnostic ne remplace pas un avis médical.

### Étape 5 — Recherche & mise en relation médecin
Recherche filtrable (spécialité, établissement, disponibilité), fiches médecins avec
notes, mise en relation **immédiate** (avec file d'attente si aucun médecin libre) ou
**réservation d'un créneau**. Le résumé d'auto-diagnostic est joint à la demande.

### Étape 6 — Téléconsultation
Appel audio/vidéo **simulé** (micro, caméra, mode audio seul, minuteur, gestion de la
**coupure / reprise**), accès au **pré-diagnostic** pendant l'appel, **synthèse** rédigée
par le médecin, et **historique** des consultations (patient / médecin).

### Étape 7 — Ordonnance numérique
Rédaction d'une ordonnance par le médecin (liste dynamique de médicaments + remarques),
génération d'un **PDF horodaté et « signé » électroniquement** (code de vérification unique),
**réception côté patient**, aperçu / impression du PDF, et **partage par QR code ou lien**.
« Mes ordonnances » liste les ordonnances reçues (patient) ou émises (médecin).

## Perspectives d'évolution (étapes non encore implémentées)

| Étape | Contenu prévu |
|-------|---------------|
| 8 | **Paiement Mobile Money** : Wave / Orange / MTN / Moov, tarif < 3000 FCFA, reçu, reprise sur échec. |
| 9 | **Espace médecin & back-office admin** : agenda, gestion des demandes, validation des médecins, établissements, statistiques. |
| 10 | **Suivi chronique, renouvellement & dossier familial** : médecin référent, renouvellement d'ordonnance, profils rattachés. |
| 11 | **Finitions & non-fonctionnel** : mode dégradé 3G, optimisation des données, accessibilité, tests supplémentaires. |

Au-delà de la feuille de route, les évolutions naturelles du prototype incluent le
remplacement des services simulés par un back-end réel (authentification, SMS, signalisation
d'appel WebRTC, passerelle de paiement) et une signature d'ordonnance cryptographique.

## Tests

Tests unitaires des services et de la génération PDF (`flutter test`) : authentification,
auto-diagnostic, recherche de médecins, téléconsultation et ordonnances.

## Crédits

- Animations Rive (`assets/animations/shapes.riv`, `button.riv`) issues du template
  public **« Build an Animated App with Rive and Flutter »** d'Abu Anwar, adaptées
  pour l'onboarding MediConnect.
