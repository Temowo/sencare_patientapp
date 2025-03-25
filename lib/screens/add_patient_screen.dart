import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddPatientScreen extends StatefulWidget {
  @override
  _AddPatientScreenState createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends State<AddPatientScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _diagnosisController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _medicalHistoryController = TextEditingController();
  final TextEditingController _heartRateController = TextEditingController();
  final TextEditingController _bloodPressureController = TextEditingController();
  final TextEditingController _respiratoryRateController = TextEditingController();
  final TextEditingController _temperatureController = TextEditingController();
  bool _critical = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_assessCriticality);
    _ageController.addListener(_assessCriticality);
    _phoneController.addListener(_assessCriticality);
    _diagnosisController.addListener(_assessCriticality);
    _genderController.addListener(_assessCriticality);
    _addressController.addListener(_assessCriticality);
    _medicalHistoryController.addListener(_assessCriticality);
    _heartRateController.addListener(_assessCriticality);
    _bloodPressureController.addListener(_assessCriticality);
    _respiratoryRateController.addListener(_assessCriticality);
    _temperatureController.addListener(_assessCriticality);
  }

  void _assessCriticality() {
    final temperature = double.tryParse(_temperatureController.text);
    final heartRate = int.tryParse(_heartRateController.text);
    final bloodPressure = _bloodPressureController.text.split('/').map(int.tryParse).toList();
    final respiratoryRate = int.tryParse(_respiratoryRateController.text);

    final isTempCritical = temperature != null && (temperature < 35 || temperature > 40);
    final isHeartRateCritical = heartRate != null && (heartRate < 40 || heartRate > 120);
    final isBloodPressureCritical = bloodPressure.length == 2 &&
        (bloodPressure[0] != null && (bloodPressure[0]! < 90 || bloodPressure[0]! > 180)) ||
        (bloodPressure[1] != null && (bloodPressure[1]! < 60 || bloodPressure[1]! > 120));
    final isRespiratoryCritical = respiratoryRate != null && (respiratoryRate < 10 || respiratoryRate > 30);

    setState(() {
      _critical = isTempCritical || isHeartRateCritical || isBloodPressureCritical || isRespiratoryCritical;
    });
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final newPatient = {
      'name': _nameController.text,
      'age': int.tryParse(_ageController.text),
      'phone': _phoneController.text,
      'critical': _critical,
      'diagnosis': _diagnosisController.text,
      'gender': _genderController.text,
      'address': _addressController.text,
      'medicalHistory': _medicalHistoryController.text,
      'heart_rate': int.tryParse(_heartRateController.text),
      'blood_pressure': _bloodPressureController.text,
      'respiratory_rate': int.tryParse(_respiratoryRateController.text),
      'temperature': double.tryParse(_temperatureController.text),
    };

    final url = Uri.parse('http://localhost:5001/patients');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(newPatient),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Patient added successfully')),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add patient. Server returned status ${response.statusCode}')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An unexpected error occurred: $error')),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    _diagnosisController.dispose();
    _genderController.dispose();
    _addressController.dispose();
    _medicalHistoryController.dispose();
    _heartRateController.dispose();
    _bloodPressureController.dispose();
    _respiratoryRateController.dispose();
    _temperatureController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Patient'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField('Name', _nameController, TextInputType.text),
              _buildTextField('Age', _ageController, TextInputType.number),
              _buildTextField('Phone', _phoneController, TextInputType.phone),
              _buildTextField('Diagnosis', _diagnosisController, TextInputType.text),
              _buildTextField('Gender', _genderController, TextInputType.text),
              _buildTextField('Address', _addressController, TextInputType.text),
              _buildTextField('Medical History', _medicalHistoryController, TextInputType.text),
              _buildTextField('Heart Rate (BPM)', _heartRateController, TextInputType.number),
              _buildTextField('Blood Pressure (Systolic/Diastolic)', _bloodPressureController, TextInputType.text),
              _buildTextField('Respiratory Rate (Breaths/Min)', _respiratoryRateController, TextInputType.number),
              _buildTextField('Temperature (°C)', _temperatureController, TextInputType.number),
              SizedBox(height: 20),
              Row(
                children: [
                  Text('Condition: '),
                  Text(
                    _critical ? 'Critical' : 'Stable',
                    style: TextStyle(
                      color: _critical ? Colors.red : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _handleSubmit,
                child: Text('Add Patient'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, TextInputType keyboardType) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        keyboardType: keyboardType,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }
}