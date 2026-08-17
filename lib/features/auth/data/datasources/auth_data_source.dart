import 'package:dio/dio.dart';

class AuthDataSource {
  AuthDataSource(this._dio);

  final Dio _dio;

  Future<Response<dynamic>> login({
    required String email,
    required String password,
    required String deviceName,
  }) {
    return _dio.post(
      'api/login/token',
      data: {'email': email, 'password': password, 'device_name': deviceName},
    );
  }

  Future<Response<dynamic>> logout() => _dio.post('api/logout');

  Future<Response<dynamic>> getCurrentUser() => _dio.get('api/user');
}
