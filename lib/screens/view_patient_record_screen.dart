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
  bool isDatePickerVisible = false;
  String testResult = "";  
  String selectedLocation = "";
  List<Map<String, dynamic>> savedTests = [];
  late Map<String, dynamic> editedPatient;

  final List<String> clinicOptions = ["Clinic A", "Clinic B", "Clinic C"];
  final List<String> testTypes = ["Blood Pressure", "Heart Rate", "Respiratory Rate", "Temperature"];

  @override
  void initState() {
    super.initState();
    print("Received Patient Data: ${widget.patient}");
    editedPatient = Map.from(widget.patient);
    editedPatient['critical'] ??= false;
  }

  void handleDelete() async {
    final response = await http.delete(Uri.parse('http://localhost:5001/patients/${widget.patient["_id"]}'));

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Patient record deleted successfully')));
      Navigator.pushNamedAndRemoveUntil(context, '/list_patient_screen', (route) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete the record')));
    }
  }

  void handleSaveTest() async {
  if (selectedTest.isEmpty || selectedLocation.isEmpty|| testResult.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please select a test type and location')));
    return;
  }

  final newTest = {
    'patientId': widget.patient["_id"], // Ensure you're passing this from the patient screen
    'type': selectedTest,
    'date': DateFormat('yyyy-MM-dd').format(testDate),
    'location': selectedLocation,
    'result': testResult, // Ensure testResult is provided in your UI
  };

  try {
    final response = await http.post(
      Uri.parse('http://localhost:5001/tests'), // Change to your actual API URL
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(newTest),
    );

    if (response.statusCode == 201) {
      final responseData = jsonDecode(response.body);
      bool isCritical = responseData['isCritical']; // Get updated status

      setState(() {
        savedTests.add(newTest);
        showTestForm = false;
        editedPatient['critical'] = isCritical;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Test saved successfully. Patient status: ${isCritical ? "Critical" : "Stable"}')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving test: ${response.body}')),
      );
    }
  } catch (error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to save test. Check your connection.')),
    );
  }
}


  void handleSavePatient() async {
    final response = await http.put(
      Uri.parse('http://localhost:5001/patients/${widget.patient["_id"]}'),
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
    title: Text('${widget.patient["name"] ?? "Unknown"}\'s Record'),
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
            _buildPatientDetail('Critical Condition',(editedPatient['critical'] ?? false) ? 'Yes' : 'No', (value) => editedPatient['critical'] = value == 'Yes'),
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
        Text('Patient Tests', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        IconButton(
          icon: Icon(showTestForm ? Icons.remove_circle : Icons.add_circle, color: Colors.blue),
          onPressed: () => setState(() => showTestForm = !showTestForm),
        ),
      ],
    );
  }

  Widget _buildTestForm() {
    return Column(
      children: [
        DropdownButtonFormField<String>(
          decoration: InputDecoration(labelText: 'Test Type', border: OutlineInputBorder()),
          value: selectedTest.isNotEmpty ? selectedTest : null,
          onChanged: (value) => setState(() => selectedTest = value!),
          items: testTypes.map((test) => DropdownMenuItem(value: test, child: Text(test))).toList(),
        ),
        SizedBox(height: 16),
        TextFormField(
          decoration: InputDecoration(labelText: 'Test Result', border: OutlineInputBorder()),
          onChanged: (value) => setState(() => testResult = value),
        ),
        SizedBox(height: 16),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(labelText: 'Location', border: OutlineInputBorder()),
          value: selectedLocation.isNotEmpty ? selectedLocation : null,
          onChanged: (value) => setState(() => selectedLocation = value!),
          items: clinicOptions.map((clinic) => DropdownMenuItem(value: clinic, child: Text(clinic))).toList(),
        ),
        SizedBox(height: 16),
        ElevatedButton(onPressed: handleSaveTest, child: Text('Save Test')),
      ],
    );
  }

  Widget _buildSavedTestsTable() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Saved Tests', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Table(
          border: TableBorder.all(),
          children: [
            TableRow(children: [
              _buildTableHeader('Test Type'),
              _buildTableHeader('Test Date'),
              _buildTableHeader('Test Location'),
              _buildTableHeader('Result'),
            ]),
            for (var test in savedTests)
              TableRow(children: [
                _buildTableCell(test['type']),
                _buildTableCell(test['date']),
                _buildTableCell(test['location']),
                _buildTableCell(test['result']),
              ]),
          ],
        ),
      ],
    );
  }

  Widget _buildTableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(text, style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
    );
  }

  Widget _buildTableCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(text, textAlign: TextAlign.center),
    );
  }
}
