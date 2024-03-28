import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../packages/index.dart';

class AppLogger extends Interceptor {
  static bool isProd = false;

  AppLogger({required bool isProduction}) {
    AppLogger.isProd = isProduction;
    if (!isProduction) {
      Logger.init(
        !isProduction,
        isShowFile: false,
        isShowTime: true,
        isShowNavigation: false,
        levelVerbose: 247,
        levelDebug: 255,
        levelInfo: 28,
        levelWarn: 3,
        levelError: 9,
        phoneVerbose: Colors.white54,
        phoneDebug: Colors.white,
        phoneInfo: Colors.green,
        phoneWarn: Colors.yellow,
        phoneError: Colors.redAccent,
      );
    }
  }
  String jsonToString(Object json) {
    return const JsonEncoder.withIndent('  ').convert(json);
  }

  void logApi(String apiType, String path, {Object? body, Map<String?, dynamic>? response}) {
    if (isProd) return;
    // final now = DateTime.now();
    // final time = '${now.monthAndDay}-${now.time24Only}';
    return debug('$apiType $path\nBody:${jsonToString(body ?? {})}\nResponse: ${response != null ? jsonToString(response) : ''} ');
  }

  void showDebugger(BuildContext context) {
    if (!isProd) {
      WidgetsBinding.instance.addPostFrameCallback((Duration timeStamp) {
        ConsoleOverlay.show(context);
      });
    }
  }

  void verbose(dynamic message) {
    Logger.v(message);
  }

  void debug(dynamic message) {
    Logger.d(message);
  }

  void info(dynamic message) {
    Logger.i(message);
  }

  void warning(dynamic message) {
    Logger.w(message);
  }

  void error(dynamic message, StackTrace trace) {
    Logger.e('$message \n Trace: $trace');
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final uri = options.uri;
    final queryParam = uri.query.isEmpty ? '' : '?${uri.query}';
    final body = options.data is FormData ? {'fields': options.data.fields.toString()} : options.data;
    logApi('Request: ${options.method}', uri.origin + uri.path + queryParam, body: body);

    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    error(err.message, err.stackTrace);
    super.onError(err, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final uri = response.requestOptions.uri;
    final method = response.requestOptions.method;

    logApi(method, uri.toString(), response: response.data, body: response.requestOptions.data);

    // final responseHeaders = <String, String>{};
    // response.headers.forEach((k, list) => responseHeaders[k] = list.toString());
    // _printMapAsTable(responseHeaders, header: 'Headers');

    // debug('''
    //   ╔ Body
    //   ║
    //   ║ ${response.data}
    //   ║
    //   ╚
    // ''');

    super.onResponse(response, handler);
  }
}
