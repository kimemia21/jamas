import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:jamas/core/constants/constants.dart';

class Comms {
  static final Comms _instance = Comms._internal();
  factory Comms() => _instance;

  late final Dio _dio;

  Comms._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    // Add logging interceptor only in debug mode
    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          logPrint: (obj) => debugPrint(obj.toString()),
        ),
      );
    }
  }

  /// Set authorization token
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  /// Clear authorization token
  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }

  /// Handle error responses in a standardized way
  Map<String, dynamic> _handleErrorResponse(Response response) {
    final statusCode = response.statusCode;
    final data = response.data;

    String message;
    switch (statusCode) {
      case 400:
        message = _extractErrorMessage(data) ?? 'Bad Request';
        break;
      case 401:
        message = 'Unauthorized: Please check your credentials';
        break;
      case 403:
        message =
            'Forbidden: You don\'t have permission to access this resource';
        break;
      case 404:
        message = 'Resource not found';
        break;
      case 500:
      case 501:
      case 502:
      case 503:
        message = 'Server Error: Please try again later';
        break;
      default:
        message = 'Error $statusCode occurred';
    }

print("Error response caught: $message");
    print("Status code: $statusCode");
    print("Response data: $data");
    return {
  "success": false,
   "rsp": data,
   "message": message,
      // "data": rsp,
      "statusCode": statusCode,
    };
  }

  /// Extract error message from different response formats
  String? _extractErrorMessage(dynamic data) {
    if (data == null) return null;

    if (data is Map) {
      // Check common error message fields
      return data['message'] ??
          data['error'] ??
          data['errorMessage'] ??
          data['error_message'];
    } else if (data is String) {
      return data;
    }

    return null;
  }

  /// Handle DioException with appropriate error messages
  Map<String, dynamic> _handleDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return {
          "success": false,
          "rsp": "Connection timeout. Please check your internet connection.",
          "statusCode": e.response?.statusCode,
        };
      case DioExceptionType.receiveTimeout:
        return {
          "success": false,
          "rsp": "Server taking too long to respond. Please try again.",
          "statusCode": e.response?.statusCode,
        };
      case DioExceptionType.sendTimeout:
        return {
          "success": false,
          "rsp": "Request timeout. Please try again.",
          "statusCode": e.response?.statusCode,
        };
      case DioExceptionType.badResponse:
        if (e.response != null) {
          print("DioException caught: ${e.response!.statusCode}");
          return _handleErrorResponse(e.response!);
        }
        return {
          "success": false,
          "rsp": "Server returned an invalid response.",
          "statusCode": null,
        };
      case DioExceptionType.cancel:
        return {
          "success": false,
          "rsp": "Request was cancelled.",
          "statusCode": e.response?.statusCode,
        };
      default:
        return {
          "success": false,
          "rsp": "Network error occurred. Please check your connection.",
          "statusCode": e.response?.statusCode,
        };
    }
  }

  /// GET request implementation
 Future<Map<String, dynamic>> getRequests({
  required String endpoint,
  Map<String, dynamic>? queryParameters,
  Map<String, dynamic>? headers,
  bool? isLocal,
}) async {
  try {
    // Fix: Provide default value for isLocal
    final bool useLocal = isLocal ?? false;
    
    final String url = "${useLocal ? "http://192.168.100.74:3000" : baseUrl}/$endpoint";
    print("hitting $url");
    print("Query parameters: $queryParameters");

    final response = await _dio.get(
      url,
      queryParameters: queryParameters,
      options: headers != null ? Options(headers: headers) : null,
    );

    print("Response status: ${response.statusCode}");
    print("Response data: ${response.data}");

    // Fix: Add null check for statusCode
    if (response.statusCode != null && 
        response.statusCode! >= 200 && 
        response.statusCode! < 300) {
      return {
        "success": true,
        "rsp": response.data,
        "statusCode": response.statusCode,
      };
    } else {
      return _handleErrorResponse(response);
    }
  } on DioException catch (e) {
    print("DioException caught: ${e.message}");
    print("DioException type: ${e.type}");
    return _handleDioException(e);
  } catch (e) {
    print("Unexpected error caught: $e");
    print("Error type: ${e.runtimeType}");
    print("Stack trace: ${StackTrace.current}");
    return {
      "success": false,
      "rsp": "An unexpected error occurred: ${e.toString()}",
      "statusCode": null,
    };
  }
}


Future<Map<String, dynamic>> postRequest({
  required String endpoint,
  required Map<String, dynamic> data,
  Map<String, dynamic>? queryParameters,
  Map<String, dynamic>? headers,
  bool isFormData = false,
}) async {
  try {
    final String url = "$baseUrl/$endpoint";
    print("---------------$url------------------------");
    print("################################$data######################");

    dynamic requestData = data;
    if (isFormData) {
      final formData = FormData();
      data.forEach((key, value) {
        formData.fields.add(MapEntry(key, value.toString()));
      });
      requestData = formData;
    }

    final response = await _dio.post(
      url,
      data: requestData,
      queryParameters: queryParameters,
      options: headers != null ? Options(headers: headers) : null,
    );

    if (response.statusCode! >= 200 && response.statusCode! < 300) {
      return {"rsp": response.data, "statusCode": response.statusCode};
    } else {
    
     return {"rsp": response.data, "statusCode": response.statusCode};
    }
  } on DioException catch (e) {
    return 
    
    _handleDioException(e);
  } catch (e) {
    return {
      "success": false,
      "rsp": {"message": "${e.toString()}"},
      "statusCode": null,
    };
  }
}


  /// PUT request implementation
  Future<Map<String, dynamic>> putRequest({
    required String endpoint,
    required Map<String, dynamic> data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    try {
      final String url = "$baseUrl/$endpoint";

      final response = await _dio.put(
        url,
        data: data,
        queryParameters: queryParameters,
        options: headers != null ? Options(headers: headers) : null,
      );

      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        return {
          "success": true,
          "rsp": response.data,
          "statusCode": response.statusCode,
        };
      } else {
        return _handleErrorResponse(response);
      }
    } on DioException catch (e) {
      return _handleDioException(e);
    } catch (e) {
      return {
        "success": false,
        "rsp": "An unexpected error occurred: ${e.toString()}",
        "statusCode": null,
      };
    }
  }

  /// DELETE request implementation
  Future<Map<String, dynamic>> deleteRequest({
    required String endpoint,
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    try {
      final String url = "$baseUrl/$endpoint";

      final response = await _dio.delete(
        url,
        data: data,
        queryParameters: queryParameters,
        options: headers != null ? Options(headers: headers) : null,
      );

      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        return {
          "success": true,
          "rsp": response.data,
          "statusCode": response.statusCode,
        };
      } else {
        return _handleErrorResponse(response);
      }
    } on DioException catch (e) {
      return _handleDioException(e);
    } catch (e) {
      return {
        "success": false,
        "rsp": "An unexpected error occurred: ${e.toString()}",
        "statusCode": null,
      };
    }
  }

  /// Cancel all ongoing requests
  void cancelRequests() {
    _dio.close(force: true);
  }
}

