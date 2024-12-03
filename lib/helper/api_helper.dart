import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http_interceptor/http_interceptor.dart';

import '../constant/data_constant.dart';
import '../helper/shared_preference.dart';
import '../main.dart';
import '../screen/LoginScreen.dart';

class ApiHelper {
  /// Builds an HTTP client with interceptors
  static Client build() {
    return InterceptedClient.build(
      interceptors: [
        _AuthInterceptor(),
        _LoggingInterceptor(),
      ],
      requestTimeout: const Duration(seconds: 30),
    );
  }

  /// Handle unauthorized access centrally
  static Future<void> handleUnauthorized() async {
    try {
      // Clear user session
      await addStringSf(ConstantData.token, "");
      await addBoolSf(ConstantData.is_login, false);
      await addStringSf(ConstantData.is_timer, "");

      // Navigate using navigator key from main
      navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error handling unauthorized: $e');
      }
    }
  }
}

class _AuthInterceptor implements InterceptorContract {
  @override
  Future<BaseRequest> interceptRequest({required BaseRequest request}) async {
    try {
      final token = await getStringValuesSF(ConstantData.token);
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      request.headers['Content-Type'] = 'application/json';
      return request;
    } catch (e) {
      if (kDebugMode) {
        print('Request Interceptor Error: $e');
      }
      rethrow;
    }
  }

  @override
  Future<BaseResponse> interceptResponse(
      {required BaseResponse response}) async {
    try {
      if (response.statusCode == 401) {
        await ApiHelper.handleUnauthorized();
      } else if (response.statusCode >= 500) {
        _handleServerError(response);
      }
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('Response Interceptor Error: $e');
      }
      rethrow;
    }
  }

  void _handleServerError(BaseResponse response) {
    final message =
        response is Response ? response.body : 'Server error occurred';
    if (kDebugMode) {
      print('Server Error: ${response.statusCode}\n$message');
    }
  }

  @override
  Future<bool> shouldInterceptRequest() async => true;

  @override
  Future<bool> shouldInterceptResponse() async => true;
}

class _LoggingInterceptor implements InterceptorContract {
  @override
  Future<BaseRequest> interceptRequest({required BaseRequest request}) async {
    if (kDebugMode) {
      print('-> ${request.method} ${request.url}');
      print('Headers: ${request.headers}');
    }
    return request;
  }

  @override
  Future<BaseResponse> interceptResponse(
      {required BaseResponse response}) async {
    if (kDebugMode) {
      print('<- ${response.statusCode} ${response.request?.url}');
      if (response is Response) {
        print('Body: ${response.body}');
      }
    }
    return response;
  }

  @override
  Future<bool> shouldInterceptRequest() async => true;

  @override
  Future<bool> shouldInterceptResponse() async => true;
}
