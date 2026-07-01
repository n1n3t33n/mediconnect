// Point d'entrée par défaut attendu par l'outillage Flutter.
//
// `flutter run` et `flutter build` recherchent `lib/main.dart` lorsqu'aucune
// cible n'est précisée. Le démarrage réel de l'application est délégué à
// `principal.dart`, qui demeure le fichier de référence (cf. .vscode/launch.json).
import 'principal.dart' as application;

void main() => application.main();
