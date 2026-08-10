import 'dart:async';

import 'package:dio/dio.dart';

import '../../../../core/api/local_storage_service.dart';
import '../../../../core/config/api_config.dart';
import '../datasources/auth_data_source.dart';

class AuthUser {
  const AuthUser({this.id, required this.email, this.name});

  final String? id;
  final String email;
  final String? name;

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
        id: json['id']?.toString(),
        email: (json['email'] ?? '').toString(),
        name: json['name']?.toString(),
      );
}

class AuthException implements Exception {
  const AuthException(this.message);
  final String message;
  @override
  String toString() => message;
}

class AuthRepository {
  AuthRepository(this._dataSource, this._session);

  final AuthDataSource _dataSource;
  final LocalStorageService _session;

  final _controller = StreamController<AuthUser?>.broadcast();
  AuthUser? _currentUser;

  Stream<AuthUser?> get onAuthStateChange => _controller.stream;

  AuthUser? get currentUser => _currentUser;

  Future<AuthUser?> restoreSession() async {
    final token = await _session.readToken();
    if (token == null || token.isEmpty) {
      _currentUser = null;
      return null;
    }
    final cachedEmail = await _session.readEmail();
    final cachedName = await _session.readName();
    final cachedUserId = await _session.readUserId();
    _currentUser = AuthUser(
      id: cachedUserId,
      email: cachedEmail ?? '',
      name: cachedName,
    );

    try {
      final res = await _dataSource.getCurrentUser();
      final body = res.data;
      if (body is Map<String, dynamic>) {
        final fresh = AuthUser.fromJson(body);
        await _session.writeSession(
          token: token,
          userId: fresh.id,
          name: fresh.name,
          email: fresh.email,
        );
        _currentUser = fresh;
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await _session.clear();
        _currentUser = null;
      }
    }
    return _currentUser;
  }

  Future<void> signIn({
    required String email,
    required String password,
    String deviceName = ApiConstants.defaultDeviceName,
  }) async {
    final Response<dynamic> res;
    try {
      res = await _dataSource.login(
        email: email,
        password: password,
        deviceName: deviceName,
      );
    } on DioException catch (e) {
      throw AuthException(_messageFrom(e));
    }

    final body = res.data;
    if (body is! Map<String, dynamic>) {
      throw const AuthException('Unexpected response from server.');
    }

    final token = (body['token'] ?? body['access_token'])?.toString();
    if (token == null || token.isEmpty) {
      throw const AuthException('Login succeeded but no token was returned.');
    }

    final rawUser = body['user'];
    final user = rawUser is Map<String, dynamic>
        ? AuthUser.fromJson(rawUser)
        : AuthUser(id: body['id']?.toString(), email: email);

    await _session.writeSession(
      token: token,
      userId: user.id,
      name: user.name,
      email: user.email,
    );
    _currentUser = user;
    _controller.add(user);
  }

  Future<void> signOut() async {
    try {
      await _dataSource.logout();
    } catch (_) {
      // Best-effort server revoke; clear locally regardless.
    }
    await _session.clear();
    _currentUser = null;
    _controller.add(null);
  }

  String _messageFrom(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      final msg = data['message'];
      if (msg is String && msg.isNotEmpty) return msg;
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return 'Could not reach the server. Check your connection.';
    }
    return 'Login failed. Please try again.';
  }

  void dispose() => _controller.close();
}
