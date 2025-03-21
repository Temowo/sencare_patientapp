import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/list_patient_screen.dart';
import 'screens/add_patient_screen.dart';
import 'screens/view_patient_record_screen.dart';

void main() {
  runApp(PatientApp());
}

class PatientApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Patient App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/login_screen',
      routes: {
        '/login_screen': (context) => LoginScreen(),
        '/register_screen': (context) => RegisterScreen(),
        '/home_screen': (context) => HomeScreen(),
        '/list_patient_screen': (context) => ListPatientScreen(),
        '/add_patient_screen': (context) => AddPatientScreen(),
        '/view_patient_record_screen': (context) => ViewPatientRecordScreen(patient: {'id': 1, 'name': 'John Doe'}), // Replace with a valid patient object
      },
    );
  }
}