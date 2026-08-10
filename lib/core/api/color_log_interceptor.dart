import 'package:dio/dio.dart';

import 'app_logger.dart';

class ColorLogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    appLogger.i('➡️  ${options.method} ${options.uri}'
        '${options.data != null ? '\n   body: ${options.data}' : ''}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    appLogger.i('✅ ${response.statusCode} ${response.requestOptions.uri}'
        '\n   body: ${response.data}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final res = err.response;
    appLogger.e('❌ ${res?.statusCode ?? err.type.name} '
        '${err.requestOptions.uri}'
        '${res?.data != null ? '\n   body: ${res?.data}' : ''}');
    handler.next(err);
  }
}
