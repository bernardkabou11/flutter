# Piste

Application Flutter de suivi des candidatures, réalisée pour les TP 1 à 3 du
cours Flutter 2026. Elle permet de centraliser les offres visées, leur statut
et les prochaines relances, avec une sauvegarde locale sur l’appareil.

## Fonctionnalités

- Créer, consulter, modifier et supprimer une candidature.
- Renseigner l’entreprise, le poste, le statut, l’URL de l’offre, des notes et
  une date de relance facultative.
- Rechercher par entreprise ou par poste et filtrer par statut.
- Consulter un bilan avec le nombre total de candidatures, les relances à venir
  et le détail des candidatures par statut.
- Enregistrer les candidatures localement avec SQLite en mode normal.
- Afficher les états de chargement, de liste vide et d’erreur.

Les statuts disponibles sont : Brouillon, Envoyée, Entretien, Acceptée et
Refusée.

## Prérequis

- Flutter installé et disponible dans le `PATH` (`flutter --version`).
- Dart **3.3 ou supérieur**, conformément à la contrainte du projet.
- Pour créer et lancer l’application native : les outils de la plateforme
  ciblée (par exemple Android Studio et le SDK Android). La compilation iOS
  nécessite macOS et Xcode.

Le dépôt contient le code Dart et les tests, mais pas les dossiers natifs
Android ou iOS. Ils sont générés à la première installation.

## Installation et lancement

Depuis le dossier du projet — celui qui contient `pubspec.yaml` — générez les
plateformes natives, récupérez les dépendances et lancez l’application :

```shell
flutter create --platforms=android,ios --project-name piste .
flutter pub get
flutter run
```

La commande `flutter create` peut être relancée si vous souhaitez générer
uniquement une plateforme, par exemple `--platforms=android`.

Le mode par défaut utilise SQLite via `sqflite`. Les données sont conservées
dans la base locale `piste.db` de l’application et ne sont pas synchronisées
avec un serveur.

## Modes pédagogiques

Les modes se sélectionnent avec des options de compilation `--dart-define`.
Lancez une seule commande à la fois ; si les deux options sont définies,
`DEMO_TP1` est prioritaire.

### TP1 — démonstration statique

```shell
flutter run --dart-define=DEMO_TP1=true
```

Affiche deux candidatures d’exemple intégrées au code. Le mode est en lecture
seule : l’ouverture des détails et l’ajout sont désactivés.

### TP2 — gestion en mémoire

```shell
flutter run --dart-define=USE_MEMORY_REPOSITORY=true
```

Permet de gérer des candidatures sans SQLite. Les données sont conservées
uniquement pendant l’exécution et disparaissent à la fermeture de l’application.

### TP3 — stockage SQLite

```shell
flutter run
```

C’est le mode par défaut. Les candidatures sont conservées dans la base locale
de l’application.

## Structure du projet

```text
lib/
  main.dart                         Initialisation, thème et sélection du mode
  models/candidature.dart           Modèle, statuts et conversion SQLite
  data/candidature_repository.dart  Contrat et dépôts mémoire/SQLite
  state/candidature_controller.dart Chargement, recherche, filtres et bilan
  ui/
    accueil_page.dart               Liste, recherche, filtres et bilan
    candidature_detail_page.dart    Détail et suppression
    candidature_form_page.dart      Création et modification
test/
  accueil_page_test.dart            Tests de l’interface
  candidature_controller_test.dart   Tests du contrôleur
  candidature_repository_test.dart   Tests des dépôts mémoire et SQLite
  fake_repository.dart               Dépôt factice pour les tests
```

## Vérification

```shell
flutter analyze
flutter test
```

Les tests couvrent les principaux parcours de l’interface et du contrôleur,
ainsi que les opérations de création, lecture, modification et suppression des
dépôts. Les tests SQLite utilisent `sqflite_common_ffi`.
