import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/education.dart';
import 'package:myportofolio_mobile/screens/education_detail_screen.dart';
import 'package:myportofolio_mobile/screens/education_form.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:provider/provider.dart';

class EducationListScreen extends StatefulWidget {
  const EducationListScreen({super.key});

  static const routeName = '/education';

  @override
  State<EducationListScreen> createState() => _EducationListScreenState();
}

class _EducationListScreenState extends State<EducationListScreen> {
  late Future<List<Education>> _educationFuture;

  @override
  void initState() {
    super.initState();
    _educationFuture = context.read<ApiClient>().getEducation();
  }

  Future<void> _reload() async {
    final future = context.read<ApiClient>().getEducation();
    setState(() {
      _educationFuture = future;
    });
    try {
      await future;
    } catch (_) {
      // FutureBuilder displays the error and offers a retry.
    }
  }

  Future<void> _addEducation() async {
    if (!await ensureLoggedIn(context) || !mounted) return;

    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(builder: (_) => const EducationFormPage()),
    );
    if (saved == true && mounted) await _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edukasi')),
      drawer: const LeftDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: _addEducation,
        tooltip: 'Tambah pendidikan',
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<Education>>(
        future: _educationFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Gagal memuat daftar pendidikan.'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _reload,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final entries = snapshot.data ?? const <Education>[];
          return RefreshIndicator(
            onRefresh: _reload,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                if (entries.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: Text('Belum ada riwayat pendidikan.')),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
                    sliver: SliverList.builder(
                      itemCount: entries.length,
                      itemBuilder: (context, index) {
                        final education = entries[index];
                        return Card(
                          child: ListTile(
                            title: Text(education.institution),
                            subtitle: Text(
                              education.studyProgram.isEmpty
                                  ? education.educationLevel
                                  : '${education.educationLevel} · '
                                        '${education.studyProgram}',
                            ),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => Navigator.of(context).push<void>(
                              MaterialPageRoute<void>(
                                builder: (_) =>
                                    EducationDetailScreen(education: education),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
