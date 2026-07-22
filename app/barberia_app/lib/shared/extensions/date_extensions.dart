import 'package:intl/intl.dart';

extension DateOnlyFormatting on DateTime {
  String get toApiDate => DateFormat('yyyy-MM-dd').format(this);
  String get toHumanDate => DateFormat('dd/MM/yyyy').format(this);
  String get toHumanDateTime => DateFormat('dd/MM/yyyy HH:mm').format(this);
}
