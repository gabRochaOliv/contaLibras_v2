import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:conta_libras_2/data/services/feedback_service.dart';

class MockClient extends http.BaseClient {
  final int statusCode;
  final bool throwError;

  MockClient({this.statusCode = 200, this.throwError = false});

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    if (throwError) {
      throw Exception('Network error');
    }
    return http.StreamedResponse(
      Stream.fromIterable([[]]),
      statusCode,
    );
  }
}

class _CapturingClient extends http.BaseClient {
  final Future<http.StreamedResponse> Function(http.BaseRequest) onSend;

  _CapturingClient({required this.onSend});

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) => onSend(request);
}

void main() {
  test('estado inicial: isLoading false e hasError false', () {
    final service = FeedbackService();
    expect(service.isLoading, false);
    expect(service.hasError, false);
  });

  test('submit com HTTP 201: isLoading false e hasError false', () async {
    final service = FeedbackService();
    final mockClient = MockClient(statusCode: 201);
    await service.submit({4: 5, 29: 4}, httpClient: mockClient);
    expect(service.isLoading, false);
    expect(service.hasError, false);
  });

  test('submit com HTTP 500: isLoading false e hasError true', () async {
    final service = FeedbackService();
    final mockClient = MockClient(statusCode: 500);
    await service.submit({4: 5}, httpClient: mockClient);
    expect(service.isLoading, false);
    expect(service.hasError, true);
  });

  test('submit com Exception (sem rede): isLoading false e hasError true',
      () async {
    final service = FeedbackService();
    final mockClient = MockClient(throwError: true);
    await service.submit({4: 5}, httpClient: mockClient);
    expect(service.isLoading, false);
    expect(service.hasError, true);
  });

  test('payload envia sem erro com mock 201', () async {
    final service = FeedbackService();
    final capturingClient = _CapturingClient(onSend: (req) async {
      return http.StreamedResponse(Stream.fromIterable([[]]), 201);
    });

    await service.submit({4: 5}, httpClient: capturingClient);
    expect(service.hasError, false);
  });

  test('submit com HTTP 200: hasError false', () async {
    final service = FeedbackService();
    final mockClient = MockClient(statusCode: 200);
    await service.submit({4: 5}, httpClient: mockClient);
    expect(service.hasError, false);
  });
}
