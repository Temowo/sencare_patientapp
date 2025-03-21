import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class ViewPatientRecordScreen extends StatefulWidget {
  final Map<String, dynamic> patient;

  ViewPatientRecordScreen({required this.patient});

  @override
  _ViewPatientRecordScreenState createState() => _ViewPatientRecordScreenState();
}

class _ViewPatientRecordScreenState extends State<ViewPatientRecordScreen> {
  bool isEditing = false;
  bool showTestForm = false;
  String selectedTest = "";
  DateTime testDate = DateTime.now();
  bool isDatePickerVisible = false;  // ✅ Renamed variable to avoid conflict
  String selectedLocation = "";
  List<Map<String, dynamic>> savedTests = [];
  late Map<String, dynamic> editedPatient;

  final List<String> clinicOptions = ["Clinic A", "Clinic B", "Clinic C"];
  final List<String> testTypes = ["Blood Pressure", "Heart Rate", "Respiratory Rate", "Temperature"];

  @override
  void initState() {
    super.initState();
    editedPatient = Map.from(widget.patient);
  }

  void handleDelete() async {
    final response = await http.delete(Uri.parse('http://172.20.10.6:5000/patients/${widget.patient["_id"]}'));

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Patient record deleted successfully')));
      Navigator.pushNamedAndRemoveUntil(context, '/list_patient_screen', (route) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete the record')));
    }
  }

  void handleSaveTest() {
    if (selectedTest.isEmpty || selectedLocation.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please select a test type and location')));
      return;
    }

    final newTest = {
      'type': selectedTest,
      'date': DateFormat('yyyy-MM-dd').format(testDate),
      'location': selectedLocation,
    };
    setState(() {
      savedTests.add(newTest);
      showTestForm = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Test details saved successfully')));
  }

  void handleSavePatient() async {
    final response = await http.put(
      Uri.parse('http://172.20.10.6:5000/patients/${widget.patient["_id"]}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(editedPatient),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Patient record updated successfully')));
      setState(() {
        isEditing = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update the record')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.patient["name"]}\'s Record'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              setState(() {
                isEditing = !isEditing;
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: handleDelete,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPatientDetail('Name', editedPatient['name'], (value) => editedPatient['name'] = value),
            _buildPatientDetail('Age', editedPatient['age'], (value) => editedPatient['age'] = value),
            _buildPatientDetail('Gender', editedPatient['gender'], (value) => editedPatient['gender'] = value),
            _buildPatientDetail('Diagnosis', editedPatient['diagnosis'], (value) => editedPatient['diagnosis'] = value),
            _buildPatientDetail('Phone', editedPatient['phone'], (value) => editedPatient['phone'] = value),
            _buildPatientDetail('Address', editedPatient['address'], (value) => editedPatient['address'] = value),
            _buildPatientDetail('Critical Condition', editedPatient['critical'] ? 'Yes' : 'No', (value) => editedPatient['critical'] = value == 'Yes'),
            _buildPatientDetail('Heart Rate', editedPatient['heart_rate'], (value) => editedPatient['heart_rate'] = value),
            _buildPatientDetail('Blood Pressure', editedPatient['blood_pressure'], (value) => editedPatient['blood_pressure'] = value),
            _buildPatientDetail('Respiratory Rate', editedPatient['respiratory_rate'], (value) => editedPatient['respiratory_rate'] = value),
            _buildPatientDetail('Temperature', editedPatient['temperature'], (value) => editedPatient['temperature'] = value),
            if (isEditing)
              ElevatedButton(
                onPressed: handleSavePatient,
                child: Text('Save Changes'),
              ),
            SizedBox(height: 20),
            _buildTestSection(),
            if (showTestForm) _buildTestForm(),
            _buildSavedTestsTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientDetail(String label, dynamic value, Function(String) onChange) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text(
              '$label:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 2,
            child: isEditing
                ? TextFormField(
                    initialValue: value.toString(),
                    onChanged: onChange,
                  )
                : Text(value.toString()),
          ),
        ],
      ),
    );
  }

  Widget _buildTestSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Patient Tests',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          icon: Icon(showTestForm ? Icons.remove_circle : Icons.add_circle, color: Colors.blue),
          onPressed: () {
            setState(() {
              showTestForm = !showTestForm;
            });
          },
        ),
      ],
    );
  }

  Widget _buildTestForm() {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Test Type',
              border: OutlineInputBorder(),
            ),
            value: selectedTest.isNotEmpty ? selectedTest : null,
            onChanged: (value) {
              setState(() {
                selectedTest = value!;
              });
            },
            items: testTypes.map((test) {
              return DropdownMenuItem<String>(
                value: test,
                child: Text(test),
              );
            }).toList(),
          ),
          SizedBox(height: 16),
          Text(
            'Test Date',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Text(DateFormat('yyyy-MM-dd').format(testDate)),
    IconButton(
      icon: Icon(Icons.calendar_today),
      onPressed: () {
        showDatePicker(
          context: context,
          initialDate: testDate,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        ).then((date) {
          if (date != null) {
            setState(() {
              testDate = date;
            });
          }
        });
      },
    ),
  ],
),
SizedBox(height: 16),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Location',
              border: OutlineInputBorder(),
            ),
            value: selectedLocation.isNotEmpty ? selectedLocation : null,
            onChanged: (value) {
              setState(() {
                selectedLocation = value!;
              });
            },
            items: clinicOptions.map((clinic) {
              return DropdownMenuItem<String>(
                value: clinic,
                child: Text(clinic),
              );
            }).toList(),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: handleSaveTest,
            child: Text('Save Test Details'),
          ),
        ],
      ),
    );
  }

  Widget _buildSavedTestsTable() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Saved Tests',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Table(
          border: TableBorder.all(),
          children: [
            TableRow(
              decoration: BoxDecoration(color: Colors.grey[200]),
              children: [
                _buildTableHeader('Test Type'),
                _buildTableHeader('Test Date'),
                _buildTableHeader('Test Location'),
              ],
            ),
            for (var test in savedTests)
              TableRow(
                children: [
                  _buildTableCell(test['type']),
                  _buildTableCell(test['date']),
                  _buildTableCell(test['location']),
                ],
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildTableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: TextStyle(fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTableCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
      ),
    );
  }
}