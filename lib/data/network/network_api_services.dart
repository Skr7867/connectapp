import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../appexception/app_exception.dart';
import 'base_api_services.dart';

class NetworkApiServices extends BaseApiServices {
  @override
  Future<dynamic> getApi(String url, {String? token}) async {
    if (kDebugMode) log("GET Token: $token");
    dynamic responseJson;
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          if (token != null) "Authorization": "Bearer $token",
        },
      ).timeout(const Duration(seconds: 60));

      responseJson = returnResponse(response);
    } on SocketException {
      throw InternetException('Please turn on internet');
    } on RequestTimeOut {
      throw RequestTimeOut('');
    } on ServerException {
      throw ServerException();
    } on InvalidUrl {
      throw InvalidUrl();
    }

    return responseJson;
  }

  @override
  Future<dynamic> postApi(
    dynamic data,
    String url, {
    String? token,
    bool isFileUpload = false,
  }) async {
    if (kDebugMode) {
      log("POST URL: $url");
      if (data != null) log("POST DATA: $data");
      if (token != null) log("POST TOKEN: $token");
      if (isFileUpload) log("IS FILE UPLOAD: $isFileUpload");
    }

    dynamic responseJson;
    try {
      if (isFileUpload) {
        final request = http.MultipartRequest('POST', Uri.parse(url))
          ..headers['Authorization'] = token != null ? 'Bearer $token' : ''
          ..headers['Content-Type'] = 'multipart/form-data';
        if (data is Map<String, dynamic>) {
          for (var entry in data.entries) {
            if (entry.value is http.MultipartFile) {
              request.files.add(entry.value);
            } else {
              request.fields[entry.key] = entry.value.toString();
            }
          }
        }

        final streamedResponse =
            await request.send().timeout(const Duration(seconds: 60));
        final response = await http.Response.fromStream(streamedResponse);
        responseJson = returnResponse(response);
      } else {
        final response = await http
            .post(
              Uri.parse(url),
              headers: {
                "Content-Type": "application/json",
                if (token != null) "Authorization": "Bearer $token",
              },
              body: data != null ? jsonEncode(data) : null,
            )
            .timeout(const Duration(seconds: 60));

        responseJson = returnResponse(response);
      }
    } on SocketException {
      throw InternetException(' Please turn on internet');
    } on TimeoutException {
      throw RequestTimeOut('');
    } on ServerException {
      throw ServerException();
    } on InvalidUrl {
      throw InvalidUrl();
    } catch (e) {
      throw FetchDataException('Unexpected error: $e');
    }

    // if (kDebugMode) log("POST RESPONSE: $responseJson");

    return responseJson;
  }

  @override
  Future<dynamic> patchApi(Map<String, dynamic> data, String url,
      {String? token}) async {
    if (kDebugMode) {
      log("PATCH URL: $url");
      log("PATCH DATA: $data");
      if (token != null) log("PATCH TOKEN: $token");
    }

    dynamic responseJson;
    try {
      final response = await http
          .patch(
            Uri.parse(url),
            headers: {
              "Content-Type": "application/json",
              if (token != null) "Authorization": "Bearer $token",
            },
            body: jsonEncode(data),
          )
          .timeout(const Duration(seconds: 10));

      responseJson = returnResponse(response);
    } on SocketException {
      throw InternetException('Please check your internet connection');
    } on RequestTimeOut {
      throw RequestTimeOut('');
    } on ServerException {
      throw ServerException();
    } on InvalidUrl {
      throw InvalidUrl();
    }

    if (kDebugMode) log("PATCH RESPONSE: $responseJson");
    return responseJson;
  }

  @override
  Future<dynamic> deleteApi(String url, {String? token}) async {
    if (kDebugMode) {
      log("DELETE URL: $url");
      if (token != null) log("DELETE TOKEN: $token");
    }

    dynamic responseJson;
    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          if (token != null) "Authorization": "Bearer $token",
        },
      ).timeout(const Duration(seconds: 10));

      responseJson = returnResponse(response);
    } on SocketException {
      throw InternetException('Please turn on internet');
    } on RequestTimeOut {
      throw RequestTimeOut('');
    } on ServerException {
      throw ServerException();
    } on InvalidUrl {
      throw InvalidUrl();
    }

    if (kDebugMode) log("DELETE RESPONSE: $responseJson");
    return responseJson;
  }

  dynamic returnResponse(http.Response response) {
    log('Response Code: ${response.statusCode}');
    log('Response Body: ${response.body}');

    dynamic responseJson;

    if (response.body.isNotEmpty) {
      try {
        responseJson = jsonDecode(response.body);
      } catch (e) {
        throw FetchDataException('Failed to parse response: $e');
      }
    } else {
      responseJson = true;
    }

    switch (response.statusCode) {
      case 200:
      case 304:
      case 201:
      case 204:
      case 206:
      case 409:
      case 500:
      case 401:
        return responseJson;
      case 400:
      case 403:
      case 404:
        throw FetchDataException(
            responseJson != true && responseJson['message'] != null
                ? responseJson['message']
                : 'Error: ${response.statusCode}');
      default:
        throw FetchDataException(
            'Unexpected error occurred: ${response.statusCode}');
    }
  }
}
