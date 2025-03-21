import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ListPatientScreen extends StatefulWidget {
  @override
  _ListPatientScreenState createState() => _ListPatientScreenState();
}

class _ListPatientScreenState extends State<ListPatientScreen> {
  List patients = [];
  List filteredPatients = [];
  bool loading = true;
  String filter = 'all';
  String searchText = '';

  @override
  void initState() {
    super.initState();
    fetchPatients();
  }

  Future<void> fetchPatients() async {
    final response = await http.get(Uri.parse('http://172.20.10.6:5000/patients'));

    if (response.statusCode == 200) {
      setState(() {
        patients = json.decode(response.body);
        filteredPatients = patients;
        loading = false;
      });
    } else {
      setState(() {
        loading = false;
      });
    }
  }

  void applyFilter() {
    List filtered = patients;

    if (filter == 'critical') {
      filtered = filtered.where((patient) => patient['critical'] as bool).toList();
    } else if (filter == 'stable') {
      filtered = filtered.where((patient) => !(patient['critical'] as bool)).toList();
    }

    if (searchText.isNotEmpty) {
      filtered = filtered.where((patient) => (patient['name'] as String).toLowerCase().contains(searchText.toLowerCase())).toList();
    }

    setState(() {
      filteredPatients = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('List of Patients'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Search Patients',
                border: OutlineInputBorder(),
              ),
              onChanged: (text) {
                setState(() {
                  searchText = text;
                });
                applyFilter();
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              FilterButton(
                text: 'All Patients',
                isActive: filter == 'all',
                onPressed: () {
                  setState(() {
                    filter = 'all';
                  });
                  applyFilter();
                },
              ),
              FilterButton(
                text: 'Critical',
                isActive: filter == 'critical',
                onPressed: () {
                  setState(() {
                    filter = 'critical';
                  });
                  applyFilter();
                },
              ),
              FilterButton(
                text: 'Stable',
                isActive: filter == 'stable',
                onPressed: () {
                  setState(() {
                    filter = 'stable';
                  });
                  applyFilter();
                },
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredPatients.length,
              itemBuilder: (context, index) {
                final patient = filteredPatients[index];
                return PatientCard(
                  patient: patient,
                  onTap: () {
                    Navigator.pushNamed(context, '/view_patient_record_screen', arguments: patient);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add_patient_screen');
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class FilterButton extends StatelessWidget {
  final String text;
  final bool isActive;
  final VoidCallback onPressed;

  const FilterButton({
    required this.text,
    required this.isActive,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive ? Colors.blue : Colors.grey,
      ),
      onPressed: onPressed,
      child: Text(text),
    );
  }
}

class PatientCard extends StatelessWidget {
  final Map patient;
  final VoidCallback onTap;

  const PatientCard({
    required this.patient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: EdgeInsets.all(16),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                patient['name'] as String,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text('Age: ${patient['age'] ?? 'N/A'}'),
              Text('Diagnosis: ${patient['diagnosis'] ?? 'N/A'}'),
              Text('Status: ${patient['critical'] as bool ? 'Critical' : 'Stable'}'),
            ],
          ),
        ),
      ),
    );
  }
}