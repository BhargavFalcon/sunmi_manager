// ignore_for_file: file_names
import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../../main.dart';
import '../constants/api_constants.dart';
import '../routes/app_pages.dart';

class NetworkClient {
  static final NetworkClient _instance = NetworkClient._internal();
  late Dio _dio;

  factory NetworkClient() {
    return _instance;
  }

  NetworkClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ArgumentConstant.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add Pretty Dio Logger interceptor for debugging
    _dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
        maxWidth: 90,
      ),
    );

    // Add error interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) {
          // Handle 401 Unauthorized - redirect to login
          // Skip redirect if already on login screen or if it's a login request
          if (error.response?.statusCode == 401) {
            final requestPath = error.requestOptions.path;
            final isLoginRequest = requestPath.contains(
              ArgumentConstant.loginEndpoint,
            );
            final isOnLoginScreen = Get.currentRoute == Routes.LOGIN_SCREEN;

            if (!isOnLoginScreen && !isLoginRequest) {
              removeAuthToken();
              box.erase();
              Get.offAllNamed(Routes.LOGIN_SCREEN);
            }
          }
          return handler.next(error);
        },
      ),
    );

    // Load saved token on initialization
    _loadSavedToken();
  }

  // Load saved token from GetStorage
  void _loadSavedToken() {
    try {
      final token = box.read<String>(ArgumentConstant.tokenKey);
      if (token != null && token.isNotEmpty) {
        _dio.options.headers['Authorization'] = 'Bearer $token';
      }
    } catch (e) {
      // Handle error silently
    }
  }

  // GET Request
  Future<Response> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    Options? options,
  }) async {
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
        options: options ?? Options(headers: headers),
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // POST Request
  Future<Response> post(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    Options? options,
  }) async {
    try {
      final response = await _dio.post(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options ?? Options(headers: headers),
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // PUT Request
  Future<Response> put(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    Options? options,
  }) async {
    try {
      final response = await _dio.put(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options ?? Options(headers: headers),
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // PATCH Request
  Future<Response> patch(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    Options? options,
  }) async {
    try {
      final response = await _dio.patch(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options ?? Options(headers: headers),
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // DELETE Request
  Future<Response> delete(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    Options? options,
  }) async {
    try {
      final response = await _dio.delete(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options ?? Options(headers: headers),
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Handle Response based on status code
  Response _handleResponse(Response response) {
    switch (response.statusCode) {
      case 200: // OK
      case 201: // Created
      case 202: // Accepted
      case 204: // No Content
        return response;

      case 400: // Bad Request
        throw ApiException(
          message: 'Bad Request',
          statusCode: 400,
          data: response.data,
        );

      case 401: // Unauthorized
        throw ApiException(
          message: 'Unauthorized. Please login again.',
          statusCode: 401,
          data: response.data,
        );

      case 403: // Forbidden
        throw ApiException(
          message: 'Forbidden. You do not have permission.',
          statusCode: 403,
          data: response.data,
        );

      case 404: // Not Found
        throw ApiException(
          message: 'Resource not found',
          statusCode: 404,
          data: response.data,
        );

      case 422: // Unprocessable Entity
        throw ApiException(
          message: 'Validation error',
          statusCode: 422,
          data: response.data,
        );

      case 500: // Internal Server Error
        throw ApiException(
          message: 'Internal server error. Please try again later.',
          statusCode: 500,
          data: response.data,
        );

      case 502: // Bad Gateway
        throw ApiException(
          message: 'Bad gateway. Please try again later.',
          statusCode: 502,
          data: response.data,
        );

      case 503: // Service Unavailable
        throw ApiException(
          message: 'Service unavailable. Please try again later.',
          statusCode: 503,
          data: response.data,
        );

      default:
        throw ApiException(
          message: 'Unknown error occurred',
          statusCode: response.statusCode ?? 0,
          data: response.data,
        );
    }
  }

  // Handle DioException errors
  ApiException _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(
          message: 'Connection timeout. Please check your internet connection.',
          statusCode: 0,
        );

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode ?? 0;
        final data = error.response?.data;

        switch (statusCode) {
          case 400:
            return ApiException(
              message: _extractErrorMessage(data) ?? 'Bad Request',
              statusCode: 400,
              data: data,
            );
          case 401:
            return ApiException(
              message:
                  _extractErrorMessage(data) ??
                  'Unauthorized. Please login again.',
              statusCode: 401,
              data: data,
            );
          case 403:
            return ApiException(
              message:
                  _extractErrorMessage(data) ??
                  'Forbidden. You do not have permission.',
              statusCode: 403,
              data: data,
            );
          case 404:
            return ApiException(
              message: _extractErrorMessage(data) ?? 'Resource not found',
              statusCode: 404,
              data: data,
            );
          case 422:
            return ApiException(
              message: _extractErrorMessage(data) ?? 'Validation error',
              statusCode: 422,
              data: data,
            );
          case 500:
            return ApiException(
              message:
                  _extractErrorMessage(data) ??
                  'Internal server error. Please try again later.',
              statusCode: 500,
              data: data,
            );
          case 502:
            return ApiException(
              message:
                  _extractErrorMessage(data) ??
                  'Bad gateway. Please try again later.',
              statusCode: 502,
              data: data,
            );
          case 503:
            return ApiException(
              message:
                  _extractErrorMessage(data) ??
                  'Service unavailable. Please try again later.',
              statusCode: 503,
              data: data,
            );
          default:
            return ApiException(
              message: _extractErrorMessage(data) ?? 'Unknown error occurred',
              statusCode: statusCode,
              data: data,
            );
        }

      case DioExceptionType.cancel:
        return ApiException(message: 'Request cancelled', statusCode: 0);

      case DioExceptionType.unknown:
      default:
        return ApiException(
          message: 'No internet connection. Please check your network.',
          statusCode: 0,
        );
    }
  }

  // Extract error message from response data
  String? _extractErrorMessage(dynamic data) {
    if (data == null) return null;

    if (data is Map<String, dynamic>) {
      // Try common error message fields
      if (data.containsKey('message')) {
        return data['message']?.toString();
      }
      if (data.containsKey('error')) {
        return data['error']?.toString();
      }
      if (data.containsKey('errors')) {
        final errors = data['errors'];
        if (errors is Map) {
          final firstError = errors.values.first;
          if (firstError is List && firstError.isNotEmpty) {
            return firstError.first.toString();
          }
          return firstError.toString();
        }
        return errors.toString();
      }
    }

    return data.toString();
  }

  // Set authorization token and save to storage
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
    // Save token to GetStorage
    try {
      box.write(ArgumentConstant.tokenKey, token);
    } catch (e) {
      // Handle error silently
    }
  }

  // Remove authorization token and clear from storage
  void removeAuthToken() {
    _dio.options.headers.remove('Authorization');
    // Remove token from GetStorage
    try {
      box.remove(ArgumentConstant.tokenKey);
    } catch (e) {
      // Handle error silently
    }
  }

  // Get saved token from storage
  String? getSavedToken() {
    try {
      return box.read<String>(ArgumentConstant.tokenKey);
    } catch (e) {
      return null;
    }
  }

  // Update headers
  void updateHeaders(Map<String, String> headers) {
    _dio.options.headers.addAll(headers);
  }

  // Clear headers
  void clearHeaders() {
    _dio.options.headers.clear();
    _dio.options.headers['Content-Type'] = 'application/json';
    _dio.options.headers['Accept'] = 'application/json';
  }
}

// Custom Exception class for API errors
class ApiException implements Exception {
  final String message;
  final int statusCode;
  final dynamic data;

  ApiException({required this.message, required this.statusCode, this.data});

  @override
  String toString() {
    return 'ApiException: $message (Status Code: $statusCode)';
  }
}
