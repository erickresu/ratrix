import 'package:dio/dio.dart';

// Rename `_template` -> your feature name, delete this comment.
class TemplateDataSource {
  TemplateDataSource(this._dio);

  final Dio _dio;

  Future<Response<dynamic>> fetchAll() => _dio.get('items');
}
