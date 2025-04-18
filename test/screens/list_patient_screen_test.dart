import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'dart:convert';

import 'package:sencare_patientapp/screens/list_patient_screen.dart';
import 'list_patient_screen_test.mocks.dart';


@GenerateMocks([http.Client])
void main() {
  late MockClient mockClient;

  setUp(() {
    mockClient = MockClient();
  });

  testWidgets('ListPatientScreen displays patients correctly', (WidgetTester tester) async {
  final samplePatients = [
    {
      'name': 'John Doe',
      'age': 30,
      'diagnosis': 'Flu',
      'critical': true,
    },
  ];

  when(mockClient.get(Uri.parse('http://localhost:5001/patients')))
      .thenAnswer((_) async => http.Response(jsonEncode(samplePatients), 200));

  await tester.pumpWidget(
    MaterialApp(
      home: ListPatientScreen(client: mockClient),
    ),
  );

  await tester.pumpAndSettle();

  expect(find.text('John Doe'), findsOneWidget);
  expect(find.text('Diagnosis: Flu'), findsOneWidget);
  expect(find.text('Status: Critical'), findsOneWidget);
});

}
