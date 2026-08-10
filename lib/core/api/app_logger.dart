import 'package:logger/logger.dart';

final appLogger = Logger(
  printer: PrettyPrinter(
    methodCount: 0,
    errorMethodCount: 3,
    noBoxingByDefault: true,
    dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
  ),
);
