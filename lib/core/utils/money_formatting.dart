import 'package:intl/intl.dart';

final _moneyFormat = NumberFormat('#,##0.00');

/// Formats a number with thousand separators and 2 decimals — e.g.
/// `120000` -> `120,000.00`. Doesn't prepend a currency symbol; callers add
/// their own (₱, Php, etc).
String formatMoney(num value) => _moneyFormat.format(value);
