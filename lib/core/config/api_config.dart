enum Flavor { staging, prod }

class ApiConstants {
  static const _flavorName = String.fromEnvironment('FLAVOR', defaultValue: 'staging');

  static Flavor get flavor => _flavorName == 'prod' ? Flavor.prod : Flavor.staging;

  static const _stagingBaseUrl = 'https://api.cerrov5.wyred.tech/';
  static const _prodBaseUrl = 'https://prod-api.cerrov5.wyred.tech/';

  static String get baseUrl => switch (flavor) {
        Flavor.prod => _prodBaseUrl,
        Flavor.staging => _stagingBaseUrl,
      };

  static const defaultDeviceName = 'mobile';
}
