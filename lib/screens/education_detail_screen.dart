import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/education.dart';

class EducationDetailScreen extends StatelessWidget {
  const EducationDetailScreen({super.key, required this.education});

  final Education education;

  @override
  Widget build(BuildContext context) {
    final fields = {
      'Institusi': education.institution,
      'Jenjang': education.educationLevel,
      'Program studi': education.studyProgram.isEmpty
          ? 'Belum diisi'
          : education.studyProgram,
      'Tahun mulai': education.startYear.toString(),
      'Tahun lulus': education.endYear?.toString() ?? 'Belum diisi',
      'URL logo': education.logoUrl.isEmpty ? 'Belum diisi' : education.logoUrl,
      'Jumlah bintang': education.starCount.toString(),
      'Status bintang': education.isStarred ? 'Dibintangi' : 'Belum dibintangi',
      'ID': education.id ?? 'Belum tersedia',
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Detail pendidikan')),
      body: ListView(
        padding: const EdgeInsets.all(8),
        children: [
          for (final field in fields.entries)
            ListTile(title: Text(field.key), subtitle: Text(field.value)),
        ],
      ),
    );
  }
}
