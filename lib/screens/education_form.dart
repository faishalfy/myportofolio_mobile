import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/left_drawer.dart';

class EducationFormPage extends StatefulWidget {
  const EducationFormPage({super.key});

  @override
  State<EducationFormPage> createState() => _EducationFormPageState();
}

class _EducationFormPageState extends State<EducationFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _institutionController = TextEditingController();
  final _programController = TextEditingController();
  final _startYearController = TextEditingController();
  final _graduationYearController = TextEditingController();

  @override
  void dispose() {
    _institutionController.dispose();
    _programController.dispose();
    _startYearController.dispose();
    _graduationYearController.dispose();
    super.dispose();
  }

  String? _requiredText(String? value, String label) {
    if (value == null || value.trim().isEmpty) return '$label wajib diisi.';
    if (value.trim().length > 100) return '$label maksimal 100 karakter.';
    return null;
  }

  String? _validateYear(String? value, String label) {
    if (value == null || value.trim().isEmpty) return '$label wajib diisi.';
    final year = int.tryParse(value.trim());
    if (year == null || year < 1900 || year > DateTime.now().year + 10) {
      return 'Masukkan tahun $label yang valid.';
    }
    return null;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final startYear = int.parse(_startYearController.text.trim());
    final graduationYear = int.parse(_graduationYearController.text.trim());

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pendidikan berhasil ditambahkan!'),
        content: Text(
          'Institusi: ${_institutionController.text.trim()}\n'
          'Program: ${_programController.text.trim()}\n'
          'Tahun: $startYear–$graduationYear',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _formKey.currentState!.reset();
              _institutionController.clear();
              _programController.clear();
              _startYearController.clear();
              _graduationYearController.clear();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Education'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      drawer: const LeftDrawer(),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              TextFormField(
                controller: _institutionController,
                decoration: const InputDecoration(
                  labelText: 'Institusi Pendidikan',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => _requiredText(value, 'Institusi'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _programController,
                decoration: const InputDecoration(
                  labelText: 'Program Studi / Gelar',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => _requiredText(value, 'Program studi'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _startYearController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Tahun Mulai',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => _validateYear(value, 'mulai'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _graduationYearController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Tahun Lulus',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final error = _validateYear(value, 'lulus');
                  if (error != null) return error;
                  if (int.parse(value!.trim()) <
                      (int.tryParse(_startYearController.text.trim()) ?? 0)) {
                    return 'Tahun lulus harus sesudah tahun mulai.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: _submit, child: const Text('Simpan')),
            ],
          ),
        ),
      ),
    );
  }
}
