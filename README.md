# MyPortfolio Mobile

[![CI](https://github.com/faishalfy/myportofolio_mobile/actions/workflows/main.yaml/badge.svg?branch=main)](https://github.com/faishalfy/myportofolio_mobile/actions/workflows/main.yaml)

MyPortfolio Mobile adalah aplikasi Flutter sederhana yang menampilkan profil pemilik dan menu aksi portofolio.

## Profil

- **Nama:** Faishal Falih
- **NPM:** 2506612064
- **Kelas:** PBP B

Halaman utama menampilkan tiga kartu profil berisi NPM, nama, dan kelas. Tersedia pula tiga tombol aksi: **Lihat Proyek**, **Tambah Proyek**, dan **Logout**. Saat ditekan, setiap tombol menampilkan pesan konfirmasi.

## Setup

### Siapkan Flutter

Gunakan Flutter SDK dengan Dart yang memenuhi versi di [`pubspec.yaml`](pubspec.yaml). Setelah clone, pasang dependensi dan buat file JSON hasil generasi.

```bash
git clone https://github.com/faishalfy/myportofolio_mobile.git
cd myportofolio_mobile
flutter pub get
dart run build_runner build
```

Jalankan ulang `build_runner` setelah mengubah model JSON. Versi `build_runner` di proyek ini sudah menangani konflik output tanpa flag `--delete-conflicting-outputs`.

### Jalankan dengan Django lokal

Di direktori [repositori backend Django](https://github.com/faishalfy/myportofolio) yang berisi `manage.py`, aktifkan virtual environment Python dan jalankan perintah berikut.

```bash
python -m pip install -r requirements.txt
python manage.py migrate
python manage.py runserver
```

Untuk menguji penyimpanan Education di Django lokal, buat akun owner dengan `python manage.py createsuperuser` melalui terminal backend, lalu login di aplikasi Flutter.

Dari direktori Flutter, gunakan URL lokal berikut untuk Chrome. Backend dalam mode pengembangan mengizinkan origin localhost untuk rute `/api/v1/`.

```bash
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8000
```

Untuk emulator Android, pilih ID dari `flutter devices` dan ganti `<device_id>` di perintah berikut. Aplikasi menggunakan `http://10.0.2.2:8000` secara default untuk menjangkau Django di komputer host.

```bash
flutter run -d <device_id>
```

### Jalankan dengan backend PWS

Untuk Android, arahkan aplikasi ke domain HTTPS PWS melalui `API_BASE_URL`. Masukkan URL dasar tanpa `/api/v1/` atau garis miring penutup karena `ApiClient` menambahkan path endpoint.

```bash
flutter run -d <device_id> --dart-define=API_BASE_URL=https://faishal-falih-myportofolio.pws.cs.ui.ac.id
```

GET publik ke [endpoint Education di PWS](https://faishal-falih-myportofolio.pws.cs.ui.ac.id/api/v1/education/) diharapkan mengembalikan HTTP `200` dan daftar JSON, termasuk `[]` jika belum ada entri.

```bash
curl -i -H 'Accept: application/json' https://faishal-falih-myportofolio.pws.cs.ui.ac.id/api/v1/education/
```

### Tugas 7

1. **Widget tree dan hubungan parent–child**

   Widget tree menyusun tampilan sebagai hierarki: parent mengatur atau memuat child. Pada aplikasi ini, `MyApp` membuat `MaterialApp`, yang menampilkan `MyHomePage`. `MyHomePage` menyusun halaman dengan `Scaffold`; `Scaffold` memiliki `AppBar` dan body. Body berisi `SingleChildScrollView` dengan `Column`, yang memuat baris kartu profil dan bagian sambutan serta grid tombol.

2. **Widget yang digunakan dan fungsinya**

   - `MyApp`: widget akar aplikasi; mengatur `MaterialApp`.
   - `MyHomePage`: membangun halaman utama portofolio dan datanya.
   - `InfoCard`: menampilkan satu informasi profil, seperti NPM, nama, atau kelas.
   - `ItemCard`: menampilkan tombol aksi berwarna, ikon, label, dan respons saat ditekan.
   - `MaterialApp`: menyediakan konfigurasi dan infrastruktur aplikasi bergaya Material.
   - `Scaffold`: menyediakan kerangka halaman, termasuk app bar dan body.
   - `AppBar`: menampilkan bilah judul di bagian atas halaman.
   - `Text`: menampilkan teks seperti judul, informasi profil, dan label tombol.
   - `SingleChildScrollView`: membuat isi halaman dapat digulir jika melebihi layar.
   - `Column`: menyusun child secara vertikal.
   - `Row`: menyusun child secara horizontal.
   - `Flexible`: membagi ruang yang tersedia di dalam `Row` untuk kartu profil.
   - `SizedBox`: memberi jarak atau ukuran tetap, misalnya jarak antarbagian.
   - `Center`: menempatkan child di tengah.
   - `Padding`: memberi ruang di sekitar child.
   - `LayoutBuilder`: membaca batas ukuran yang tersedia untuk menghitung ukuran tile grid.
   - `GridView.count`: menyusun tombol dalam grid dengan jumlah kolom yang ditentukan.
   - `Card`: memberi tampilan kartu pada informasi profil.
   - `Container`: mengatur ukuran, padding, dan tata letak child.
   - `Material`: menyediakan permukaan Material dan warna untuk tombol aksi.
   - `InkWell`: membuat area dapat ditekan dan menangani `onTap`.
   - `SnackBar`: menampilkan pesan singkat setelah tombol ditekan.
   - `Icon`: menampilkan ikon untuk setiap tombol aksi.

3. **Fungsi `MaterialApp`**

   `MaterialApp` menjadi pembungkus utama yang menyediakan gaya dan perilaku dasar aplikasi Material. Di `MyApp`, properti `theme` mengatur skema warna dan Material 3, sedangkan `home: MyHomePage()` menentukan halaman awal. Widget ini juga menghubungkan halaman dengan layanan Material seperti navigasi dan tema.

4. **Perbedaan `StatelessWidget` dan `StatefulWidget`**

   `StatelessWidget` cocok untuk tampilan yang tidak menyimpan state yang berubah selama widget hidup. `MyApp`, `MyHomePage`, `InfoCard`, dan `ItemCard` pada aplikasi ini menggunakan `StatelessWidget`; data profil dan daftar tombolnya ditetapkan di widget.

   `StatefulWidget` digunakan ketika tampilan perlu berubah karena state lokal, misalnya penghitung yang bertambah saat tombol ditekan, pilihan switch, atau formulir yang menyimpan input. Perubahan state biasanya memanggil `setState` agar Flutter membangun ulang bagian tampilan terkait.

5. **Fungsi `BuildContext`**

   `BuildContext` adalah rujukan ke lokasi sebuah widget di dalam widget tree. Melalui context, widget dapat menemukan layanan atau konfigurasi dari ancestor yang sesuai. Di `MyHomePage`, `Theme.of(context).colorScheme.primary` mengambil warna utama dari tema yang disediakan `MaterialApp`. Di `ItemCard`, `ScaffoldMessenger.of(context)` menemukan `ScaffoldMessenger` terdekat untuk menampilkan `SnackBar` ketika tombol ditekan.

6. **Hot reload, hot restart, dan full restart**

   - **Hot reload** menerapkan perubahan kode Dart ke aplikasi yang sedang berjalan dan mempertahankan state yang ada. Gunakan untuk perubahan tampilan atau logika biasa; perubahan pada kode tertentu seperti `initState` tidak otomatis menjalankan ulang lifecycle.
   - **Hot restart** memulai ulang aplikasi Flutter dari `main()` dan menghapus state sementara, tanpa membangun ulang atau memulai ulang proses native. Gunakan ketika perubahan perlu mengulang inisialisasi Dart atau hot reload tidak cukup.
   - **Full restart** menghentikan lalu menjalankan kembali aplikasi dari awal, termasuk membangun ulang bagian native bila diperlukan. Gunakan untuk perubahan konfigurasi atau kode platform native, dan perubahan plugin/dependensi yang memengaruhi aplikasi native.

### Tugas 8

1. **Perbedaan `Navigator.push()`, `Navigator.pushReplacement()`, dan `Navigator.pop()`**

   `Navigator.push()` menambahkan halaman baru di atas halaman aktif sehingga pengguna dapat kembali ke halaman sebelumnya. Kartu **Edukasi** memakai metode ini untuk membuka `EducationFormPage` dari beranda. `Navigator.pushReplacement()` mengganti halaman aktif dengan halaman baru. Opsi **Home** di drawer memakai metode ini untuk mengganti halaman formulir dengan `MyHomePage`. `Navigator.pop()` menghapus rute teratas sehingga tampilan di bawahnya muncul kembali. Tombol **OK** di dialog ringkasan memakai `pop()` untuk menutup dialog dan menampilkan kembali formulir.

2. **Struktur halaman dan warna tema portofolio**

   `Scaffold` menyediakan tempat untuk `AppBar`, `Drawer`, dan isi halaman (`body`). `AppBar` menampilkan judul dan akses ke menu, sedangkan `LeftDrawer` dipakai bersama di beranda dan kedua halaman formulir. Susunan ini membuat judul dan menu mudah ditemukan ketika pengguna berpindah halaman. Contohnya, `AppBar` pada formulir Proyek dan Pendidikan sama-sama memakai `Colors.indigo`, warna yang juga menjadi dasar skema warna aplikasi.

3. **Tata letak formulir saat ruang terbatas**

   `Column` menyusun kolom isian dari atas ke bawah agar urutan pengisian mudah diikuti, dari institusi sampai tahun lulus. `Padding` memberi jarak dari tepi layar dan `SizedBox` memberi jarak antarkolom serta sebelum tombol **Simpan**. `SingleChildScrollView` memungkinkan pengguna menggulir sampai ke kolom terakhir dan tombol **Simpan** saat layar pendek atau papan ketik mengurangi ruang yang tersedia.

4. **Validasi ketika tombol Simpan ditekan**

   `GlobalKey<FormState>` menghubungkan tombol **Simpan** dengan state formulir. Saat tombol ditekan, `validate()` menjalankan `validator` di setiap kolom. Jika validator mengembalikan pesan kesalahan, pesan itu tampil pada kolom terkait dan dialog ringkasan baru bisa dibuka setelah semua kolom valid. Contohnya, tahun lulus `2023` ditolak jika tahun mulai `2024` karena tahun lulus tidak boleh mendahului tahun mulai. `TextInputType.number` hanya meminta papan ketik angka. Papan ketik tidak bisa menilai apakah angka yang dimasukkan memenuhi aturan formulir, termasuk urutan kedua tahun tersebut.

### Assignment 9

1. **Serialisasi model Education**

   `@JsonSerializable(fieldRename: FieldRename.snake)` menghasilkan `fromJson()` dan `toJson()` dengan nama field yang sesuai kontrak Django REST Framework. Form mengisi properti Dart `endYear` dari input Tahun Lulus, lalu model otomatis mengirim `end_year`. Jika form merakit sebuah `Map` dan keliru memakai `graduationYear`, nilai tahun lulus bisa terabaikan karena serializer Django mengenal `end_year` sebagai field opsional. `@JsonKey(includeToJson: false)` tetap memungkinkan model membaca `id`, `star_count`, dan `is_starred` dari respons serta mengecualikan ketiganya dari payload POST karena server yang menentukan nilainya.

2. **`FutureBuilder` dan penanganan error**

   `EducationListScreen` menyimpan `Future` dari `getEducation()` di `initState()`, sehingga pemanggilan ulang `build()` tidak memicu GET baru. Membuat `Future` di dalam `build()` bisa menyebabkan permintaan berulang setiap widget dibangun ulang dan membuat indikator loading muncul kembali. Retry, pull-to-refresh, dan penyimpanan yang berhasil mengganti `Future` tersebut agar daftar dimuat ulang. Respons `200` dengan `[]` berarti daftar berhasil dimuat dan kosong. Respons gagal menghasilkan `ApiException` yang membawa status HTTP dan isi respons, sehingga daftar bisa menawarkan Retry dan form bisa meminta login ulang khusus ketika POST mendapat `401`.

3. **Autentikasi sesi Django dan token DRF**

   Django memakai cookie untuk mengenali sesi browser. Jika request yang mengubah data diautentikasi dengan sesi, `SessionAuthentication` juga memeriksa token CSRF. Flutter memperoleh token dari `/api/v1/auth/token/` setelah login, menyimpannya di `AuthState`, dan menambahkannya melalui header `Authorization: Token <key>` saat mengirim POST. Backend mempertahankan kedua skema karena halaman web Django sudah memakai sesi browser, sementara aplikasi Flutter mengirim token secara eksplisit. GET Education bisa diakses publik, sedangkan POST tetap memerlukan izin owner meskipun token pengguna valid.

4. **Workflow CI dan build APK**

   Job `build` memakai workflow `flutter_package.yml@v2` dari Very Good Workflows untuk memasang dependensi, menjalankan `build_runner` pada langkah `setup`, memeriksa format Dart, menjalankan `flutter analyze`, dan menjalankan tes dengan pengukuran coverage. `min_coverage: 0` meniadakan ambang persentase minimum, sementara tes tetap harus lulus. Job `build_apk` berjalan setelah `build` lulus. Job ini melakukan checkout sendiri, memasang dependensi, menjalankan code generation lagi, lalu membangun APK release dan mengunggahnya sebagai `app-release-apk`. File `*.g.dart` diabaikan Git karena dapat dibuat ulang dari model dan dependensi proyek. Setiap job perlu membuat ulang file itu agar analisis, tes, dan build dapat memuat `part` yang dirujuk model. [Workflow proyek](.github/workflows/main.yaml) · [Dokumentasi Very Good Workflows](https://workflows.vgv.dev/docs/workflows/flutter_package)

## AI Disclosure

ChatGPT/Codex membantu menyusun dan menyunting README, termasuk deskripsi aplikasi, petunjuk setup, dan jawaban Tugas 7. Strategi prompt yang digunakan adalah memberi instruksi spesifik tentang bagian dan urutan konten yang diminta, lalu meminta penjelasan disesuaikan dengan aplikasi ini. Pemeriksaan dilakukan dengan membaca `lib/main.dart` dan `lib/menu.dart`, lalu mencocokkan identitas, tombol aksi, struktur widget, tema, dan penggunaan `BuildContext` dengan README.

Link Prompt Tugas 7 : https://chatgpt.com/share/6af7e104-b474-83ec-ab8f-7af7b714afb7
Link Prompt Tugas 8 : https://chatgpt.com/share/6b0179ef-81dc-83ec-9a29-fd5f363e103b

Untuk Assignment 9, ChatGPT/Codex membantu mengerjakan checklist secara bertahap, mulai dari model dan API Education, navigasi, form dan penanganan `401`, sampai pembaruan tes dan README. Prompt merujuk ke nomor TODO yang sedang dikerjakan agar tiap perubahan mengikuti kontrak backend dan struktur proyek yang ada. Pemeriksaan bersama Codex mencakup pencocokan field dengan serializer Django, verifikasi `education.g.dart`, pemeriksaan format, `flutter analyze`, dan build Flutter bundle. Seluruh tes unit dan widget lulus lewat `flutter_tester` dengan runner lokal sementara karena `flutter test` membutuhkan socket localhost yang dibatasi di lingkungan eksekusi. Pengujian PWS dan hasil CI untuk perubahan Assignment 9 masih perlu dikonfirmasi.

## TODO Assignment 9

Referensi [Assignment 9](https://pbp.cs.ui.ac.id/assignments/individual/tugas-9.html) dan [Tutorial 10](https://pbp.cs.ui.ac.id/tutorial/tutorial-10.html).

1. [x] Implementasikan model [`Education`](lib/models/education.dart) serta GET publik dan POST dengan token di [`api_client.dart`](lib/services/api_client.dart). `build_runner` menghasilkan `education.g.dart` dan Git mengabaikannya.
2. [x] Implementasikan [daftar](lib/screens/education_list_screen.dart) dan [detail Education](lib/screens/education_detail_screen.dart) publik dari kartu Edukasi dan drawer. Daftar mendukung loading, error, Retry, kondisi kosong, dan pull-to-refresh. Verifikasi lewat widget test dicakup di langkah 6.
3. [x] Refactor [form Education](lib/screens/education_form.dart) untuk validasi input, POST dengan token, login ulang pada 401, dan refresh daftar setelah berhasil menyimpan. Widget test untuk alur ini ada di langkah 6.
   - [ ] Verifikasi di PWS dengan akun owner. Tambah entri dari Flutter, cek hasilnya di daftar Flutter dan web Django, lalu uji logout. Untuk menguji 401, cabut token akun uji sebelum menekan Simpan dan pastikan login ulang ditawarkan dengan isian tetap tersimpan di form.
4. [x] Dokumentasikan setup Flutter, code generation, serta koneksi ke Django lokal dan PWS di [Setup](#setup).
   - [ ] Verifikasi respons GET publik pada [endpoint Education di PWS](https://faishal-falih-myportofolio.pws.cs.ui.ac.id/api/v1/education/).
5. [x] Isi [jawaban reflektif Assignment 9](#assignment-9), perbarui [AI Disclosure](#ai-disclosure), dan tambahkan badge CI.
6. [x] Jalankan pemeriksaan format, `flutter analyze`, dan suite tes lokal. [Tes `MockClient`](test/education_api_client_test.dart) mencakup GET publik, payload dan header POST, serta respons `401`. Seluruh 11 tes lulus lewat `flutter_tester`. Eksekusi `flutter test` standar akan diverifikasi di CI pada langkah 7.
7. [ ] Buat commit bertahap dengan pesan deskriptif, lalu push ke repo GitHub publik yang sama dengan Assignment 8. Buka PR ke `main` untuk menjalankan [CI](.github/workflows/main.yaml), cek kedua job hijau dan unduh `app-release-apk`. Kumpulkan tautan commit final lewat SCELE sebelum **30 November 2026, 23.59 WIB**.

