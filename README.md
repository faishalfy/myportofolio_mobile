# MyPortfolio Mobile

MyPortfolio Mobile adalah aplikasi Flutter sederhana yang menampilkan profil pemilik dan menu aksi portofolio.

## Profil

- **Nama:** Faishal Falih
- **NPM:** 2506612064
- **Kelas:** PBP B

Halaman utama menampilkan tiga kartu profil berisi NPM, nama, dan kelas. Tersedia pula tiga tombol aksi: **Lihat Proyek**, **Tambah Proyek**, dan **Logout**. Saat ditekan, setiap tombol menampilkan pesan konfirmasi.

## Setup

1. Clone repositori:
   ```bash
   git clone https://github.com/faishalfy/myportofolio_mobile.git
   ```
2. Masuk ke folder proyek:
   ```bash
   cd myportofolio_mobile
   ```
3. Pasang dependensi:
   ```bash
   flutter pub get
   ```
4. Pilih perangkat yang tersedia dengan melihat daftar perangkat:
   ```bash
   flutter devices
   ```
5. Jalankan aplikasi pada perangkat pilihan:
   ```bash
   flutter run -d <device_id>
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

## AI Disclosure

ChatGPT/Codex membantu menyusun dan menyunting README, termasuk deskripsi aplikasi, petunjuk setup, dan jawaban Tugas 7. Strategi prompt yang digunakan adalah memberi instruksi spesifik tentang bagian dan urutan konten yang diminta, lalu meminta penjelasan disesuaikan dengan aplikasi ini. Pemeriksaan dilakukan dengan membaca `lib/main.dart` dan `lib/menu.dart`, lalu mencocokkan identitas, tombol aksi, struktur widget, tema, dan penggunaan `BuildContext` dengan README.

Link Prompt Tugas 7 : https://chatgpt.com/share/6af7e104-b474-83ec-ab8f-7af7b714afb7
Link Prompt Tugas 8 : https://chatgpt.com/share/6b0179ef-81dc-83ec-9a29-fd5f363e103b

