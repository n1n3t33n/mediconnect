import 'package:intl/intl.dart';

/// Formatage des dates/heures pour l'affichage (français).
class FormatageDate {
  FormatageDate._();

  /// Ex. « 05/07 à 18:00 » — utilisé pour les créneaux.
  static String creneau(DateTime date) =>
      DateFormat("dd/MM 'à' HH:mm").format(date);

  /// Ex. « 05/07/2026 à 18:00 ».
  static String dateHeure(DateTime date) =>
      DateFormat("dd/MM/yyyy 'à' HH:mm").format(date);
}
