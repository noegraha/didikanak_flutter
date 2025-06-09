// pubspec.yaml dependencies yang diperlukan:
// dependencies:
//   flutter:
//     sdk: flutter
//   http: ^1.1.0
//   intl: ^0.19.0

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  // Load .env file
  // await dotenv.load(fileName: ".env");

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Deteksi Dini Kanker Anak',
      theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'Roboto'),
      home: IndikatorKankerAnak(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Indikator {
  final int id;
  final String highlight;
  final String rest;

  Indikator({required this.id, required this.highlight, required this.rest});
}

class HasilSkrining {
  final Color warna;
  final String status;
  final String message;

  HasilSkrining({
    required this.warna,
    required this.status,
    required this.message,
  });
}

class IndikatorKankerAnak extends StatefulWidget {
  @override
  _IndikatorKankerAnakState createState() => _IndikatorKankerAnakState();
}

class _IndikatorKankerAnakState extends State<IndikatorKankerAnak> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey _hasilKey = GlobalKey();

  Map<int, String?> jawaban = {};
  HasilSkrining? hasil;
  bool isLoading = false;

  final List<Indikator> indikatorList = [
    Indikator(
      id: 1,
      highlight: "",
      rest: "Demam ≥ 7 hari dan/atau berkeringat hebat",
    ),
    Indikator(
      id: 2,
      highlight: "",
      rest:
          "Nyeri kepala yang makin memberat dengan/tanpa disertai muntah hebat",
    ),
    Indikator(
      id: 3,
      highlight: "",
      rest: "Nyeri tulang yang mengganggu aktifitas",
    ),
    Indikator(
      id: 4,
      highlight: "",
      rest: "Gangguan pengelihatan : buram, dobel, buta mendadak",
    ),
    Indikator(
      id: 5,
      highlight: "",
      rest:
          "Nafsu makan hilang, penurunan berat badan, dan kelelahan dalam 3 bulan terakhir",
    ),
    Indikator(
      id: 6,
      highlight: "Pucat disertai tanda-tanda perdarahan: ",
      rest:
          " bintik-bintik merah di kulit (petekie), lebam (hematom), mimisan (epistaksis), gusi berdarah",
    ),
    Indikator(
      id: 7,
      highlight: "Kelainan mata: ",
      rest:
          " mata kucing (lekokorea), mata juling (strabismus) tiba-tiba, tidak memiliki iris (aniridia), perbedaan warna kedua mata (heterokromia), perdarahan di mata (hifema), mata menonjol (proptosis)",
    ),
    Indikator(
      id: 8,
      highlight: "Pembesaran kelenjar getah bening",
      rest:
          "dengan ukuran 2 – 5 cm, keras, tidak nyeri, dan berlangsung ≥ 4 minggu",
    ),
    Indikator(
      id: 9,
      highlight: "Gangguan neurologi mendadak dan progresif berupa:",
      rest:
          " kejang tanpa demam atau tanpa penyebab yang jelas, kelemahan tubuh di satu sisi, wajah asimetris, penurunan kesadaran dan/atau perubahan status mental, hilang keseimbangan atau pincang saat berjalan, kesulitan bicara",
    ),
    Indikator(
      id: 10,
      highlight: "Organomegali",
      rest: ": Pembesaran hepar (hepatomegali) dan/atau limpa (splenomegali)",
    ),
    Indikator(
      id: 11,
      highlight: "Benjolan",
      rest: "yang teraba di perut atau bagian tubuh lain",
    ),
  ];

  List<Indikator> get anamnesis => indikatorList.take(5).toList();
  List<Indikator> get identifikasi => indikatorList.skip(5).toList();

  Future<void> handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    try {
      // Logic untuk menentukan hasil skrining
      final jawabanValues = jawaban.values.toList();
      final isAnyYa = jawabanValues.asMap().entries.any(
        (entry) => entry.value == "ya" && entry.key != 4,
      ); // idx 4 = indikator 5
      final isOnlyLimaYa = jawabanValues.asMap().entries.every(
        (entry) =>
            entry.key == 4 ? entry.value == "ya" : entry.value == "tidak",
      );
      final isAllTidak = jawabanValues.every((v) => v == "tidak");

      HasilSkrining? hasilSkrining;

      if (isAnyYa) {
        hasilSkrining = HasilSkrining(
          warna: Colors.red,
          status: "MERAH : Kemungkinan terkena kanker atau penyakit berat",
          message:
              "Stabilisasi dan rujuk segera ke RS yang memiliki pelayanan hematologi dan onkologi anak.",
        );
      } else if (isOnlyLimaYa) {
        hasilSkrining = HasilSkrining(
          warna: Colors.orange,
          status: "KUNING : Memiliki risiko terkena kanker",
          message:
              "Rujuk ke dokter anak untuk menentukan diagnosis penyakit dan tatalaksana yang tepat.",
        );
      } else if (isAllTidak) {
        hasilSkrining = HasilSkrining(
          warna: Colors.green,
          status: "HIJAU : Tidak memiliki risiko terkena kanker",
          message:
              "Memastikan pertumbuhan dan perkembangan anak sesuai usia, imunisasi lengkap, dan lakukan edukasi untuk pencegahan kanker (lingkungan anak bebas rokok, nutrisi yang seimbang dan bergizi, serta rutin berolahraga).",
        );
      }

      setState(() {
        hasil = hasilSkrining;
        isLoading = false;
      });

      // Scroll ke hasil
      if (hasil != null) {
        await Future.delayed(Duration(milliseconds: 300));
        Scrollable.ensureVisible(
          _hasilKey.currentContext!,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }

      // Kirim data ke backend (uncomment jika diperlukan)

      // if (hasilSkrining != null) {
      //   final tanggalWIB = DateFormat(
      //     'yyyy-MM-dd HH:mm:ss',
      //   ).format(DateTime.now());
      //   await http.post(
      //     Uri.parse('https://v0-api-backend.vercel.app/api/simpan-data'),
      //     headers: {'Content-Type': 'application/json'},
      //     body: json.encode({
      //       'data': jawaban,
      //       'hasil': hasilSkrining.status.split(':')[0].trim(),
      //       'tanggal': tanggalWIB,
      //     }),
      //   );
      // }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Terjadi kesalahan: $e')));
    }
  }

  Widget buildIndikatorCard(Indikator indikator) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Color(0xFFF0F0F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.black87, fontSize: 14),
              children: [
                TextSpan(
                  text: '${indikator.id}. ',
                  style: TextStyle(fontWeight: FontWeight.normal),
                ),
                if (indikator.highlight.isNotEmpty)
                  TextSpan(
                    text: indikator.highlight,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                TextSpan(text: indikator.rest),
              ],
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Radio<String>(
                value: "ya",
                groupValue: jawaban[indikator.id],
                onChanged: (value) {
                  setState(() {
                    jawaban[indikator.id] = value;
                  });
                },
              ),
              Text("Ya"),
              SizedBox(width: 20),
              Radio<String>(
                value: "tidak",
                groupValue: jawaban[indikator.id],
                onChanged: (value) {
                  setState(() {
                    jawaban[indikator.id] = value;
                  });
                },
              ),
              Text("Tidak"),
            ],
          ),
          if (jawaban[indikator.id] == null)
            Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                "Mohon pilih salah satu",
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  Widget buildSectionDivider(String title, Color color) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 8),
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              'assets/rsms_blur.jpg',
            ), // Tambahkan gambar ke assets
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Center(
              child: Container(
                constraints: BoxConstraints(maxWidth: 900),
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header dengan logo
                          Container(
                            width: double.infinity,
                            child: Column(
                              children: [
                                Container(
                                  constraints: BoxConstraints(maxWidth: 400),
                                  child: Image.asset(
                                    'assets/logo.jpeg', // Tambahkan logo ke assets
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 24),

                          // Deskripsi
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "• Setiap kali anak mengunjungi layanan kesehatan karena sebab apapun, kita harus menilai kemungkinan bahwa anak tersebut berisiko terkena kanker",
                                ),
                                SizedBox(height: 8),
                                Text(
                                  "• Lakukan langkah-langkah deteksi dini kanker pada anak: Anamnesis - Periksa & Identifikasi - Klasifikasi",
                                ),
                                SizedBox(height: 8),
                                Text(
                                  "• Skrining ini bertujuan untuk memastikan bahwa diagnosis dan pengobatan bagi anak yang terkena kanker tidak tertunda",
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 32),

                          // Form sections
                          LayoutBuilder(
                            builder: (context, constraints) {
                              if (constraints.maxWidth > 600) {
                                // Desktop layout - 2 columns
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        children: [
                                          buildSectionDivider(
                                            "Anamnesis",
                                            Color(0xFFD9F7BE),
                                          ),
                                          ...anamnesis.map(
                                            (indikator) =>
                                                buildIndikatorCard(indikator),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 24),
                                    Expanded(
                                      child: Column(
                                        children: [
                                          buildSectionDivider(
                                            "Periksa & Identifikasi",
                                            Color(0xFFFFD591),
                                          ),
                                          ...identifikasi.map(
                                            (indikator) =>
                                                buildIndikatorCard(indikator),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              } else {
                                // Mobile layout - single column
                                return Column(
                                  children: [
                                    buildSectionDivider(
                                      "Anamnesis",
                                      Color(0xFFD9F7BE),
                                    ),
                                    ...anamnesis.map(
                                      (indikator) =>
                                          buildIndikatorCard(indikator),
                                    ),
                                    SizedBox(height: 16),
                                    buildSectionDivider(
                                      "Periksa & Identifikasi",
                                      Color(0xFFFFD591),
                                    ),
                                    ...identifikasi.map(
                                      (indikator) =>
                                          buildIndikatorCard(indikator),
                                    ),
                                  ],
                                );
                              }
                            },
                          ),

                          SizedBox(height: 32),

                          // Submit button
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : handleSubmit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: isLoading
                                  ? Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Colors.white,
                                                ),
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Text("Memproses..."),
                                      ],
                                    )
                                  : Text("Hitung Klasifikasi"),
                            ),
                          ),

                          // Hasil skrining
                          if (hasil != null) ...[
                            SizedBox(height: 32),
                            Container(
                              key: _hasilKey,
                              child: Card(
                                color: hasil!.warna == Colors.red
                                    ? Colors.red.shade50
                                    : hasil!.warna == Colors.orange
                                    ? Colors.orange.shade50
                                    : Colors.green.shade50,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide(
                                    color: hasil!.warna,
                                    width: 1.5,
                                  ),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            hasil!.warna == Colors.red
                                                ? Icons.error
                                                : hasil!.warna == Colors.orange
                                                ? Icons.warning
                                                : Icons.check_circle,
                                            color: hasil!.warna,
                                            size: 24,
                                          ),
                                          SizedBox(width: 8),
                                          Expanded(
                                            child: RichText(
                                              text: TextSpan(
                                                style: TextStyle(
                                                  color: Colors.black87,
                                                  fontSize: 16,
                                                ),
                                                children: [
                                                  TextSpan(
                                                    text: "Hasil Skrining: ",
                                                  ),
                                                  TextSpan(
                                                    text: hasil!.status.split(
                                                      ":",
                                                    )[0],
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: hasil!.warna,
                                                    ),
                                                  ),
                                                  TextSpan(
                                                    text:
                                                        ":${hasil!.status.split(":")[1]}",
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 12),
                                      Text(
                                        hasil!.message,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],

                          SizedBox(height: 40),

                          // Footer
                          Center(
                            child: Text(
                              "*Pan American Health Organization, World Health Organization (2014): Early diagnosis of childhood cancer.",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                                fontStyle: FontStyle.italic,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
