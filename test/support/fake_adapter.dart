import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

typedef FakeHandler = ResponseBody Function(RequestOptions options);

/// A dio adapter that answers from [handler] and records every request.
class FakeAdapter implements HttpClientAdapter {
  FakeAdapter(this.handler);

  final FakeHandler handler;
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody jsonBody(
  Object? json, {
  int status = 200,
  Map<String, String> headers = const {},
}) => ResponseBody.fromString(
  jsonEncode(json),
  status,
  headers: {
    Headers.contentTypeHeader: ['application/json'],
    for (final e in headers.entries) e.key.toLowerCase(): [e.value],
  },
);
