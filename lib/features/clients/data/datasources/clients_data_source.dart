import 'package:dio/dio.dart';

class ClientsDataSource {
  ClientsDataSource(this._dio);

  final Dio _dio;

  Future<Response<dynamic>> fetchClients() => _dio.get('api/clients');
}
