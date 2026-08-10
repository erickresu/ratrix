const _weekdayNames = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];

const _monthNames = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

String _pad2(int n) => n.toString().padLeft(2, '0');

/// e.g. "Tuesday, June 16, 2026"
String formatLongDate(DateTime date) {
  final weekday = _weekdayNames[date.weekday - 1];
  final month = _monthNames[date.month - 1];
  return '$weekday, $month ${date.day}, ${date.year}';
}

/// e.g. "June 2026"
String formatMonthYear(DateTime date) {
  return '${_monthNames[date.month - 1]} ${date.year}';
}

/// e.g. "2026-06-10"
String formatIsoDate(DateTime date) {
  return '${date.year.toString().padLeft(4, '0')}-${_pad2(date.month)}-${_pad2(date.day)}';
}

/// e.g. "Jun 10, 2026"
String formatShortDate(DateTime date) {
  return '${_monthNames[date.month - 1].substring(0, 3)} ${date.day}, ${date.year}';
}

/// e.g. "08:05"
String formatHHmm(DateTime time) {
  return '${_pad2(time.hour)}:${_pad2(time.minute)}';
}
