# Rekomendasi Fasilitas Kesehatan — Flutter

Aplikasi rekomendasi fasilitas kesehatan berbasis lokasi (studi kasus Kota Sukabumi). Aplikasi:
- Menghitung jarak garis lurus menggunakan **Haversine**
- Mengambil **jarak & waktu tempuh** via layanan rute
- Melakukan **perangkingan dengan TOPSIS** sesuai bobot yang ditentukan pengguna

---

## Daftar Isi
- [Ringkasan](#ringkasan)
- [Fitur Utama](#fitur-utama)
- [Cara Kerja (Ringkas)](#cara-kerja-ringkas)
- [Alur Pengguna](#alur-pengguna)
- [Struktur Proyek](#struktur-proyek)
- [Instalasi](#instalasi)
- [Konfigurasi (Opsional)](#konfigurasi-opsional)
- [Testing](#testing)
- [Build & Rilis](#build--rilis)
- [Roadmap](#roadmap)
- [Lisensi](#lisensi)
- [Kredit](#kredit)

---

## Ringkasan
Aplikasi membantu pengguna menemukan fasilitas kesehatan terdekat dan paling sesuai preferensi. Sistem memadukan:
1) **Geolokasi** pengguna  
2) **Perhitungan jarak** (garis lurus dan rute aktual)  
3) **Multi-kriteria TOPSIS** untuk memberi peringkat rekomendasi yang transparan dan dapat dikendalikan bobotnya.

---

## Fitur Utama

### 1) Geolokasi & Perizinan
- Meminta izin lokasi (while-in-use/one-time).
- Mendeteksi posisi pengguna secara otomatis.
- Menangani kondisi gagal (mis. lokasi ditolak) dengan pesan ramah dan opsi coba lagi.

### 2) Beranda Informatif
- Menampilkan **nama lokasi** pengguna.
- Informasi **cuaca singkat** dari layanan eksternal (opsional).
- Akses cepat ke kategori: **Rumah Sakit**, **Klinik**, **Puskesmas**.

### 3) Direktori per Kategori
- Daftar fasilitas per kategori dengan ringkasan: **nama**, **alamat**.
- Navigasi ke detail fasilitas (alamat lengkap, koordinat, dan opsi rute).

### 4) Rekomendasi Berbasis TOPSIS
- **Halaman pengaturan bobot** (slider) untuk 4 kriteria:
  - **Radius (Haversine)** — jarak garis lurus
  - **Jarak (rute aktual)** — dari layanan rute
  - **Waktu tempuh** — estimasi lama perjalanan
  - **Rating** — penilaian/keunggulan fasilitas
- **Hasil peringkat** menampilkan skor preferensi (semakin tinggi semakin baik).

### 5) Navigasi ke Peta
- Tautan **“Lihat di Google Maps”** untuk mulai navigasi ke fasilitas terpilih.

### 6) Performa & Kegunaan
- Perhitungan efisien untuk daftar fasilitas skala kecil–menengah.
- Antarmuka sederhana, fokus pada tugas utama (temukan & bandingkan).

---

## Cara Kerja (Ringkas)

1) **Haversine**  
   Menghitung jarak garis lurus dari koordinat pengguna ke tiap fasilitas.

2) **Layanan Rute**  
   Mengambil **jarak rute** dan **waktu tempuh** aktual (mengikuti jaringan jalan).

3) **TOPSIS**  
   - Normalisasi matriks keputusan  
   - Terapkan bobot kriteria dari pengguna  
   - Hitung jarak ke solusi ideal positif/negatif  
   - Ambil **skor preferensi** → urutkan sebagai **peringkat rekomendasi**  

> Bobot bersifat fleksibel dan dapat diubah pengguna sesuai prioritas.

---

## Alur Pengguna
1) Buka aplikasi → setujui izin lokasi.  
2) Lihat beranda (lokasi, cuaca singkat, kategori).  
3) Pilih kategori atau langsung ke **Rekomendasi**.  
4) Atur **bobot kriteria** sesuai preferensi.  
5) Tinjau **peringkat fasilitas** dan buka rute di Maps jika sudah memilih.

---

## Struktur Proyek
skripsi_app/
├─ android/ # konfigurasi platform Android
├─ ios/ # konfigurasi platform iOS
├─ web/ # konfigurasi platform Web
├─ linux/ # Desktop (Linux)
├─ macos/ # Desktop (macOS)
├─ windows/ # Desktop (Windows)
├─ assets/ # aset statis (ikon, font, ilustrasi, dsb.)
├─ lib/ # source code utama (UI, routing, services, utils)
├─ native_splash.yaml # konfigurasi splash screen native (opsional)
├─ analysis_options.yaml # aturan linting/analisis Dart
├─ pubspec.yaml # dependency & konfigurasi Flutter
└─ README.md

---

## Instalasi
```bash
git clone https://github.com/0xZAI/skripsi_app.git
cd skripsi_app
flutter pub get

# (Opsional) generate splash jika menggunakan plugin
dart run flutter_native_splash:create

flutter run
