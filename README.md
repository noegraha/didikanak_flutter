# 📱 Deteksi Dini Kanker Anak - Flutter App

Aplikasi **Deteksi Dini Kanker Anak** adalah aplikasi mobile berbasis Flutter yang membantu tenaga kesehatan dan masyarakat melakukan skrining cepat untuk mendeteksi tanda awal kanker pada anak.  
Hasil skrining dapat langsung dikirim ke backend untuk pencatatan.

---

## ✨ Fitur Utama

- **Form skrining gejala** kanker anak berdasarkan indikator klinis
- **Klasifikasi hasil** (HIJAU, KUNING, MERAH) secara otomatis
- **Pengiriman hasil ke backend** (API siap pakai)
- **UI modern** dan ramah pengguna
- **Splash screen** dan logo rumah sakit
- Mendukung semua perangkat Android (dengan SafeArea untuk menghindari overlap tombol)

---

## 📝 Teknologi

- Flutter 3.x
- [http](https://pub.dev/packages/http)
- [intl](https://pub.dev/packages/intl)
- Backend API: [Vercel Serverless](https://v0-api-backend.vercel.app/api/simpan-data)

---

## 🚀 Instalasi & Jalankan di Lokal

1. **Clone repositori:**

```
git clone https://github.com/noegraha/didikanak_flutter.git
cd didikanak_flutter
```

2. **Install dependencies:**

  ```bash
  flutter pub get
  ```

3. **Daftarkan aset (logo dan background):**

Pastikan file berikut ada di folder assets/:
assets/logo.jpeg
assets/blur.jpg

Tambahkan ke pubspec.yaml:

```yaml
flutter:
  assets:
    - assets/logo.jpeg
    - assets/blur.jpg
```

4. **Jalankan aplikasi:**

```bash
flutter run
```
📦 Build APK Release
```bash
flutter build apk --release
```

File apk ada di: build/app/outputs/flutter-apk/app-release.apk

**⚠️ Konfigurasi Penting**
Permission Internet:
Sudah otomatis diaktifkan pada android/app/src/main/AndroidManifest.xml

URL Backend:
Default sudah mengarah ke

```bash
https://v0-api-backend.vercel.app/api/simpan-data
```

Ubah jika ingin backend sendiri.

🛠️ Struktur Data yang Dikirim ke Backend
Contoh JSON payload yang dikirim via POST ke backend:

```json
{
  "data": {
    "indikator_1": "ya",
    "indikator_2": "tidak",
    "indikator_3": "tidak",
    ...
    "indikator_11": "ya"
  },
  "hasil": "MERAH",
  "tanggal": "2025-06-10 21:43:21"
}
```

🖼️ UI Preview
Splash	Form Skrining	Hasil
![image](https://github.com/user-attachments/assets/7e435719-9446-46b8-95fe-7d37b18b1e25)

👨‍💻 Kontribusi
Pull request sangat diterima!
Silakan fork repo, buat branch baru, dan ajukan PR untuk fitur/bug/perbaikan.

📄 Lisensi

Aplikasi ini bertujuan untuk mendukung edukasi dan skrining awal kanker anak, bukan sebagai alat diagnosis akhir. Selalu konsultasikan ke tenaga medis profesional untuk diagnosis dan penanganan lebih lanjut.
