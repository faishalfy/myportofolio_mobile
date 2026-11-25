import 'package:material_ui/material_ui.dart';
import 'package:http/http.dart' show ClientException;
import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:provider/provider.dart';

class ProjectFormPage extends StatefulWidget {
  const ProjectFormPage({super.key});

  @override
  State<ProjectFormPage> createState() => _ProjectFormPageState();
}

class _ProjectFormPageState extends State<ProjectFormPage> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _description = '';
  String _techStack = '';
  String _projectUrl = '';
  String _projectImageUrl = '';
  bool _isSubmitting = false;

  Future<void> _submit() async {
    final form = _formKey.currentState!;
    if (_isSubmitting || !form.validate()) return;
    form.save();

    final auth = context.read<AuthState>();
    setState(() => _isSubmitting = true);
    String? token;
    try {
      if (!await ensureLoggedIn(context) || !mounted) return;
      token = auth.token;
      if (token == null) return;

      final newProject = Project(
        title: _title,
        description: _description,
        techStack: _techStack,
        projectUrl: _projectUrl,
        projectImageUrl: _projectImageUrl,
      );
      final created = await context.read<ApiClient>().createProject(
        newProject,
        token: token,
      );
      if (!mounted) return;

      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Proyek berhasil ditambahkan!'),
          content: Text(created.title),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      if (mounted) form.reset();
    } on ApiException catch (error) {
      if (error.statusCode == 401) {
        if (auth.token == token) await auth.logout();
        if (!mounted || auth.isLoggedIn) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sesi berakhir. Silakan login ulang.')),
        );
        await ensureLoggedIn(context);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menambahkan proyek (${error.statusCode}).'),
          ),
        );
      }
    } on ClientException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal terhubung ke server.')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Widget _field(
    String label,
    ValueChanged<String> onSaved, {
    int maxLines = 1,
    bool isUrl = false,
    bool optional = false,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: TextFormField(
        enabled: !_isSubmitting,
        maxLines: maxLines,
        keyboardType: isUrl ? TextInputType.url : null,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        onSaved: (value) => onSaved(value?.trim() ?? ''),
        validator: (value) {
          final text = value?.trim() ?? '';
          if (text.isEmpty) return optional ? null : '$label wajib diisi.';
          if (isUrl) {
            final uri = Uri.tryParse(text);
            if (uri == null ||
                !{'http', 'https'}.contains(uri.scheme) ||
                uri.host.isEmpty ||
                text.contains(RegExp(r'\s'))) {
              return 'Masukkan URL HTTP atau HTTPS yang valid.';
            }
          }
          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Add Project Form')),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      drawer: const LeftDrawer(),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _field('Title', (value) => _title = value),
              _field(
                'Description',
                (value) => _description = value,
                maxLines: 5,
              ),
              _field('Tech Stack', (value) => _techStack = value),
              _field(
                'Project URL',
                (value) => _projectUrl = value,
                isUrl: true,
              ),
              _field(
                'Project Image URL (Optional)',
                (value) => _projectImageUrl = value,
                isUrl: true,
                optional: true,
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _isSubmitting ? null : _submit,
                    child: const Text('Save'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
