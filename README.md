# Rekomendasi Fasilitas Kesehatan (Android, Flutter)

Sistem rekomendasi fasilitas layanan kesehatan berbasis lokasi untuk Kota Sukabumi.
Aplikasi menghitung jarak menggunakan **Haversine**, mengambil **jarak & waktu tempuh** via API peta, lalu melakukan **perangkingan dengan TOPSIS** agar pengguna mendapat rekomendasi paling sesuai. :contentReference[oaicite:1]{index=1}

![Flutter](https://img.shields.io/badge/Flutter-3.x-blue)
![Platforms](https://img.shields.io/badge/Platforms-Android%20|%20iOS%20|%20Web%20|%20Desktop-informational)
![License](https://img.shields.io/badge/License-MIT-green)

---

## ✨ Fitur Utama

1) **Deteksi Lokasi Otomatis (GPS) + Izin Lokasi**  
   - Dialog izin lokasi (precise/approximate; while-in-use/one-time).  
   - Deteksi cepat (< 1 detik dalam pengujian). :contentReference[oaicite:2]{index=2}

2) **Beranda Informatif**  
   - Menampilkan **nama lokasi** pengguna.  
   - **Cuaca terkini** dari API eksternal (akurasi deviasi ~0.5°C pada uji banding).  
   - Akses cepat ke kategori: **Rumah Sakit**, **Klinik**, **Puskesmas**. :contentReference[oaicite:3]{index=3}

3) **Daftar Per-Kategori**  
   - Kartu berisi **nama fasilitas**, **alamat**, dan **gambar** untuk memudahkan identifikasi.  
   - **Muat cepat** (< 1 detik) berkat cache/penyimpanan lokal. :contentReference[oaicite:4]{index=4}

4) **Halaman Rekomendasi (TOPSIS) dengan Slider Bobot**  
   - 4 kriteria yang bisa diatur user:
     - **Radius** (garis lurus haversine)  
     - **Jarak** (rute aktual)  
     - **Waktu Tempuh** (estimasi perjalanan)  
     - **Rating** (penilaian pengguna)  
   - Slider responsif (0.1–0.5) dan **hasil dihitung < 2 detik**. :contentReference[oaicite:5]{index=5}

5) **Hasil Peringkat & Navigasi**  
   - Menampilkan **skor preferensi** tiap fasilitas (semakin tinggi semakin baik).  
   - Tombol **“Lihat di Google Maps”** untuk navigasi langsung. :contentReference[oaicite:6]{index=6}

6) **Performa & Validasi Pengguna**  
   - Waktu pemrosesan rata-rata **< 2 detik/pencarian**, stabil hingga **100 fasilitas**.  
   - Validasi 20 responden: **90%** mudah digunakan, **85%** cepat, **85%** relevan. :contentReference[oaicite:7]{index=7}

---

## 🧠 Cara Kerja (Ringkas)

- **Haversine**: hitung **radius** (jarak garis lurus) dari posisi pengguna ke tiap fasilitas.  
- **OpenStreetMap/servis rute**: ambil **jarak rute** & **waktu tempuh** aktual.  
- **TOPSIS**: normalisasi + bobot → jarak ke **solusi ideal (+/−)** → **skor preferensi** → **peringkat**.  
- Bobot contoh (default riset): `Radius=0.25`, `Jarak=0.30`, `Waktu=0.10`, `Rating=0.40`. :contentReference[oaicite:8]{index=8}

---

## 🗂️ Arsitektur & Data

- **Tabel**:
  - `fasilitas` — profil fasilitas (nama, alamat, koordinat, jenis).  
  - `rekomendasi` — hasil hitung (radius haversine, jarak & waktu dari API).  
  - `bobot_kriteria` — bobot kriteria TOPSIS per pengguna/sesi.  
  - Relasi menjaga integritas & memudahkan kueri rekomendasi. :contentReference[oaicite:9]{index=9}

- **Alur**: Lokasi user → Haversine (radius) → API rute (jarak/waktu) → simpan → TOPSIS → tampilkan peringkat. :contentReference[oaicite:10]{index=10}

---

## 🔧 Instalasi & Menjalankan

> Prasyarat: **Flutter** 3.x (stable), Android SDK/iOS toolchain sesuai target.

```bash
# 1) Clone
git clone https://github.com/0xZAI/skripsi_app.git
cd skripsi_app

# 2) Dependencies
flutter pub get

# 3) (Opsional) Generate native splash (sesuaikan jika plugin digunakan)
dart run flutter_native_splash:create

# 4) Run
flutter run
