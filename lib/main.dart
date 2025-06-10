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

void main() {
  runApp(
    MaterialApp(
      title: 'Deteksi Dini Kanker Anak',
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    ),
  );
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => IndikatorKankerAnak()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/logo.jpeg', height: 100),
            SizedBox(height: 20),
            Text(
              'Deteksi Dini Kanker Anak',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            SizedBox(height: 10),
            CircularProgressIndicator(),
          ],
        ),
      ),
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
  final ScrollController _scrollController = ScrollController();

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

  bool get isFormComplete =>
      jawaban.length == indikatorList.length && !jawaban.values.contains(null);

  Future<void> handleSubmit() async {
    if (!isFormComplete) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Mohon isi semua pertanyaan terlebih dahulu.')),
      );
      return;
    }

    setState(() => isLoading = true);

    final isLimaYa = jawaban[5] == "ya";
    final selainLimaYa = jawaban.entries
        .where((entry) => entry.key != 5)
        .any((entry) => entry.value == "ya");
    final isAllTidak = jawaban.values.every((v) => v == "tidak");

    if (isLimaYa && !selainLimaYa) {
      // Hanya indikator ke-5 yang "ya"
      hasil = HasilSkrining(
        warna: Colors.orange,
        status: "KUNING : Memiliki risiko terkena kanker",
        message:
            "Rujuk ke dokter anak untuk menentukan diagnosis penyakit dan tatalaksana yang tepat.",
      );
    } else if (selainLimaYa || (isLimaYa && selainLimaYa)) {
      // Ada indikator lain yang "ya"
      hasil = HasilSkrining(
        warna: Colors.red,
        status: "MERAH : Kemungkinan terkena kanker atau penyakit berat",
        message:
            "Stabilisasi dan rujuk segera ke RS yang memiliki pelayanan hematologi dan onkologi anak.",
      );
    } else if (isAllTidak) {
      hasil = HasilSkrining(
        warna: Colors.green,
        status: "HIJAU : Tidak memiliki risiko terkena kanker",
        message:
            "Pastikan pertumbuhan dan perkembangan anak sesuai usia, imunisasi lengkap, dan lakukan edukasi untuk pencegahan kanker.",
      );
    }

    setState(() => isLoading = false);

    // Auto scroll ke bawah setelah hasil muncul
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void handleReset() {
    setState(() {
      jawaban.clear();
      hasil = null;
    });
  }

  Widget buildIndikatorCard(Indikator indikator) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              style: TextStyle(
                color: Colors.black87,
                fontSize: 14,
                height: 1.4,
              ),
              children: [
                TextSpan(text: '${indikator.id}. '),
                if (indikator.highlight.isNotEmpty)
                  TextSpan(
                    text: indikator.highlight,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                TextSpan(text: indikator.rest),
              ],
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Radio<String>(
                value: "ya",
                groupValue: jawaban[indikator.id],
                onChanged: (value) =>
                    setState(() => jawaban[indikator.id] = value),
                activeColor: Colors.blue,
              ),
              Text("Ya", style: TextStyle(fontSize: 14)),
              SizedBox(width: 32),
              Radio<String>(
                value: "tidak",
                groupValue: jawaban[indikator.id],
                onChanged: (value) =>
                    setState(() => jawaban[indikator.id] = value),
                activeColor: Colors.blue,
              ),
              Text("Tidak", style: TextStyle(fontSize: 14)),
            ],
          ),
          if (jawaban[indikator.id] == null)
            Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                "Mohon pilih salah satu",
                style: TextStyle(color: Colors.red.shade600, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  Widget buildHasilSkriningCard() {
    if (hasil == null) return SizedBox.shrink();
    return Card(
      color: hasil!.warna.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: hasil!.warna, width: 1.5),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                      style: TextStyle(color: Colors.black87, fontSize: 16),
                      children: [
                        TextSpan(text: "Hasil Skrining: "),
                        TextSpan(
                          text: hasil!.status.split(":")[0],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: hasil!.warna,
                          ),
                        ),
                        TextSpan(text: ":${hasil!.status.split(":")[1]}"),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              hasil!.message,
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Hitung tinggi footer secara dinamis
    double footerHeight = 80; // Tinggi dasar tombol
    if (hasil != null) {
      footerHeight += 120; // Tambahan tinggi untuk hasil
    }

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/blur.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Main content wrapped in card
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    // Header with logo
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(
                                'assets/logo.jpeg',
                                fit: BoxFit.cover,
                                height: 170, // sesuaikan tinggi sesuai desain
                              ),
                            ),
                          ),
                          // SizedBox(height: 12),
                          // Text(
                          //   "Deteksi Dini Kanker Anak",
                          //   style: TextStyle(
                          //     fontSize: 20,
                          //     fontWeight: FontWeight.bold,
                          //     color: Colors.blue,
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                    // Form content
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(16),
                            bottomRight: Radius.circular(16),
                          ),
                        ),
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          padding: EdgeInsets.fromLTRB(
                            20,
                            0,
                            20,
                            footerHeight + 16,
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 16),
                                Container(
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.blue.shade100,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "• Setiap kali anak mengunjungi layanan kesehatan karena sebab apapun, kita harus menilai kemungkinan bahwa anak tersebut berisiko terkena kanker",
                                        style: TextStyle(fontSize: 14),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        "• Lakukan langkah-langkah deteksi dini kanker pada anak: Anamnesis - Periksa & Identifikasi - Klasifikasi",
                                        style: TextStyle(fontSize: 14),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        "• Skrining ini bertujuan untuk memastikan bahwa diagnosis dan pengobatan bagi anak yang terkena kanker tidak tertunda",
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 24),
                                Text(
                                  "Anamnesis",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                                SizedBox(height: 8),
                                ...anamnesis.map(buildIndikatorCard).toList(),
                                SizedBox(height: 24),
                                Text(
                                  "Periksa & Identifikasi",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange,
                                  ),
                                ),
                                SizedBox(height: 8),
                                ...identifikasi
                                    .map(buildIndikatorCard)
                                    .toList(),
                                SizedBox(height: 32),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Fixed bottom buttons dengan tinggi dinamis
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: handleReset,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade600,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text("Reset"),
                      ),
                      ElevatedButton(
                        onPressed: isFormComplete && !isLoading
                            ? handleSubmit
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: isLoading
                            ? SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Text("Hitung Klasifikasi"),
                      ),
                    ],
                  ),
                  if (hasil != null) ...[
                    SizedBox(height: 16),
                    buildHasilSkriningCard(),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
