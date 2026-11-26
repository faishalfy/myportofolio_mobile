import 'package:http/http.dart' show ClientException;
import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/education.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:provider/provider.dart';

class EducationFormPage extends StatefulWidget {
  const EducationFormPage({super.key});

  @override
  State<EducationFormPage> createState() => _EducationFormPageState();
}

class _EducationFormPageState extends State<EducationFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _institutionController = TextEditingController();
  final _levelController = TextEditingController();
  final _programController = TextEditingController();
  final _startYearController = TextEditingController();
  final _graduationYearController = TextEditingController();
  final _logoUrlController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _institutionController.dispose();
    _levelController.dispose();
    _programController.dispose();
    _startYearController.dispose();
    _graduationYearController.dispose();
    _logoUrlController.dispose();
    super.dispose();
  }

  String? _validateText(
    String? value,
    String label,
    int maxLength, {
    bool optional = false,
  }) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return optional ? null : '$label wajib diisi.';
    if (text.runes.length > maxLength) {
      return '$label maksimal $maxLength karakter.';
    }
    return null;
  }

  String? _validateYear(String? value, String label) {
    if (value == null || value.trim().isEmpty) return '$label wajib diisi.';
    final year = int.tryParse(value.trim());
    if (year == null || year < 1900 || year > DateTime.now().year + 10) {
      return 'Masukkan $label yang valid.';
    }
    return null;
  }

  String? _validateGraduationYear(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;

    final error = _validateYear(text, 'Tahun lulus');
    if (error != null) return error;

    final startYear = int.tryParse(_startYearController.text.trim());
    if (startYear != null && int.parse(text) < startYear) {
      return 'Tahun lulus harus sesudah tahun mulai.';
    }
    return null;
  }

  String? _validateLogoUrl(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    final error = _validateText(text, 'URL logo', 200);
    if (error != null) return error;

    final uri = Uri.tryParse(text);
    if (uri == null ||
        !{'http', 'https'}.contains(uri.scheme) ||
        uri.host.isEmpty ||
        text.contains(RegExp(r'\s'))) {
      return 'Masukkan URL HTTP atau HTTPS yang valid.';
    }
    return null;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _submit() async {
    if (_isSubmitting || !_formKey.currentState!.validate()) return;
    final auth = context.read<AuthState>();
    setState(() => _isSubmitting = true);

    try {
      if (!await ensureLoggedIn(context) || !mounted) return;
      final token = auth.token;
      if (token == null) return;

      final education = Education(
        institution: _institutionController.text.trim(),
        educationLevel: _levelController.text.trim(),
        studyProgram: _programController.text.trim(),
        startYear: int.parse(_startYearController.text.trim()),
        endYear: int.tryParse(_graduationYearController.text.trim()),
        logoUrl: _logoUrlController.text.trim(),
      );

      final Education created;
      try {
        created = await context.read<ApiClient>().createEducation(
          education,
          token: token,
        );
      } on ApiException catch (error) {
        if (error.statusCode == 401) {
          auth.invalidateToken(token);
          if (!mounted || auth.isLoggedIn) return;
          _showError('Sesi berakhir. Silakan login ulang.');
          await ensureLoggedIn(context);
        } else if (mounted) {
          _showError(
            error.statusCode == 403
                ? 'Hanya pemilik portofolio yang dapat menambah pendidikan.'
                : 'Gagal menambahkan pendidikan (${error.statusCode}).',
          );
        }
        return;
      } on ClientException {
        if (mounted) _showError('Gagal terhubung ke server.');
        return;
      }

      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Pendidikan berhasil ditambahkan!'),
          content: Text(created.institution),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      if (mounted) Navigator.pop(context, true);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Widget _field(
    String label,
    TextEditingController controller,
    FormFieldValidator<String> validator, {
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        enabled: !_isSubmitting,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: validator,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isSubmitting,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Add Education'),
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
        ),
        drawer: _isSubmitting ? null : const LeftDrawer(),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                _field(
                  'Institusi Pendidikan',
                  _institutionController,
                  (value) => _validateText(value, 'Institusi', 255),
                ),
                _field(
                  'Jenjang Pendidikan',
                  _levelController,
                  (value) => _validateText(value, 'Jenjang', 16),
                ),
                _field(
                  'Program Studi (opsional)',
                  _programController,
                  (value) =>
                      _validateText(value, 'Program studi', 64, optional: true),
                ),
                _field(
                  'Tahun Mulai',
                  _startYearController,
                  (value) => _validateYear(value, 'Tahun mulai'),
                  keyboardType: TextInputType.number,
                ),
                _field(
                  'Tahun Lulus (opsional)',
                  _graduationYearController,
                  _validateGraduationYear,
                  keyboardType: TextInputType.number,
                ),
                _field(
                  'URL Logo (opsional)',
                  _logoUrlController,
                  _validateLogoUrl,
                  keyboardType: TextInputType.url,
                ),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  child: Text(_isSubmitting ? 'Menyimpan…' : 'Simpan'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
