import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:myportofolio_mobile/models/education.dart';
import 'package:myportofolio_mobile/services/api_client.dart';

void main() {
  const submittedEducation = Education(
    institution: 'Universitas Indonesia',
    educationLevel: 'S1',
    startYear: 2025,
  );
  const savedJson = {
    'id': 'fbf02b2e-e965-46a4-a2c7-4980ea10ea89',
    'institution': 'Universitas Indonesia',
    'education_level': 'S1',
    'start_year': 2025,
    'star_count': 2,
  };

  test('GET Education is public and decodes optional fields', () async {
    final client = MockClient((request) async {
      expect(request.method, 'GET');
      expect(request.url.path, '/api/v1/education/');
      expect(request.headers['authorization'], isNull);
      return http.Response(jsonEncode([savedJson]), 200);
    });
    addTearDown(client.close);

    final education = (await ApiClient(client: client).getEducation()).single;
    expect(education.id, savedJson['id']);
    expect(education.educationLevel, 'S1');
    expect(education.startYear, 2025);
    expect(education.studyProgram, isEmpty);
    expect(education.endYear, isNull);
    expect(education.logoUrl, isEmpty);
    expect(education.starCount, 2);
    expect(education.isStarred, isFalse);
  });

  test('POST Education sends a token and only writable fields', () async {
    final client = MockClient((request) async {
      expect(request.method, 'POST');
      expect(request.url.path, '/api/v1/education/');
      expect(request.headers['authorization'], 'Token test-token');
      expect(jsonDecode(request.body), {
        'institution': 'Universitas Indonesia',
        'education_level': 'S1',
        'study_program': '',
        'start_year': 2025,
        'end_year': null,
        'logo_url': '',
      });
      return http.Response(jsonEncode(savedJson), 201);
    });
    addTearDown(client.close);

    final created = await ApiClient(client: client)
        .createEducation(Education.fromJson(savedJson), token: 'test-token');
    expect(created.id, savedJson['id']);
  });

  test('POST Education preserves HTTP 401 and its response body', () async {
    const responseBody = '{"detail":"Invalid token."}';
    final client = MockClient((_) async => http.Response(responseBody, 401));
    addTearDown(client.close);

    await expectLater(
      ApiClient(client: client)
          .createEducation(submittedEducation, token: 'revoked-token'),
      throwsA(
        isA<ApiException>()
            .having((error) => error.statusCode, 'statusCode', 401)
            .having((error) => error.message, 'message', responseBody),
      ),
    );
  });
}
