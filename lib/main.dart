import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  runApp(
    MaterialApp(
      title: 'Deteksi Dini Kanker Anak',
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    ),
  );
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
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
            const SizedBox(height: 20),
            const Text(
              'Deteksi Dini Kanker Anak',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 10),
            const CircularProgressIndicator(),
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
  const IndikatorKankerAnak({super.key});

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
          " dengan ukuran 2 – 5 cm, keras, tidak nyeri, dan berlangsung ≥ 4 minggu",
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
      rest: " yang teraba di perut atau bagian tubuh lain",
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

    String hasilStatus = "";
    if (isLimaYa && !selainLimaYa) {
      hasil = HasilSkrining(
        warna: Colors.orange,
        status: "KUNING : Memiliki risiko terkena kanker",
        message:
            "Rujuk ke dokter anak untuk menentukan diagnosis penyakit dan tatalaksana yang tepat.",
      );
      hasilStatus = "KUNING";
    } else if (selainLimaYa || (isLimaYa && selainLimaYa)) {
      hasil = HasilSkrining(
        warna: Colors.red,
        status: "MERAH : Kemungkinan terkena kanker atau penyakit berat",
        message:
            "Stabilisasi dan rujuk segera ke RS yang memiliki pelayanan hematologi dan onkologi anak.",
      );
      hasilStatus = "MERAH";
    } else if (isAllTidak) {
      hasil = HasilSkrining(
        warna: Colors.green,
        status: "HIJAU : Tidak memiliki risiko terkena kanker",
        message:
            "Pastikan pertumbuhan dan perkembangan anak sesuai usia, imunisasi lengkap, dan lakukan edukasi untuk pencegahan kanker.",
      );
      hasilStatus = "HIJAU";
    }

    // Mapping agar mirip React: { 'indikator_1': 'ya', ... }
    Map<String, String?> mappedData = {
      for (var entry in jawaban.entries) 'indikator_${entry.key}': entry.value,
    };

    // Kirim ke backend
    await kirimHasilKeBackend(data: mappedData, hasil: hasilStatus);

    setState(() => isLoading = false);

    // Auto scroll ke bawah setelah hasil muncul
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> kirimHasilKeBackend({
    required Map<String, String?> data,
    required String hasil,
  }) async {
    final now = DateTime.now().toUtc().add(const Duration(hours: 7));
    final tanggalWIB = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);

    final backendUrl = dotenv.env['DB_URL_SIMPAN'];
    if (backendUrl == null || backendUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('URL backend tidak ditemukan di .env')),
      );
      return;
    }

    final url = Uri.parse(backendUrl);

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'data': data,
          'hasil': hasil,
          'tanggal': tanggalWIB,
        }),
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Success!'), backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengakses: ${response.body}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terdapat error pada backend: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void handleReset() {
    setState(() {
      jawaban.clear();
      hasil = null;
    });
  }

  Widget buildIndikatorCard(Indikator indikator) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 14,
                height: 1.4,
              ),
              children: [
                TextSpan(text: '${indikator.id}. '),
                if (indikator.highlight.isNotEmpty)
                  TextSpan(
                    text: indikator.highlight,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                TextSpan(text: indikator.rest),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Radio<String>(
                value: "ya",
                groupValue: jawaban[indikator.id],
                onChanged: (value) =>
                    setState(() => jawaban[indikator.id] = value),
                activeColor: Colors.blue,
              ),
              const Text("Ya", style: TextStyle(fontSize: 14)),
              const SizedBox(width: 32),
              Radio<String>(
                value: "tidak",
                groupValue: jawaban[indikator.id],
                onChanged: (value) =>
                    setState(() => jawaban[indikator.id] = value),
                activeColor: Colors.blue,
              ),
              const Text("Tidak", style: TextStyle(fontSize: 14)),
            ],
          ),
          if (jawaban[indikator.id] == null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
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
    if (hasil == null) return const SizedBox.shrink();
    return Card(
      color: hasil!.warna.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: hasil!.warna, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                const SizedBox(width: 8),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 16,
                      ),
                      children: [
                        const TextSpan(text: "Hasil Skrining: "),
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
            const SizedBox(height: 12),
            Text(
              hasil!.message,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double footerHeight = 80;
    if (hasil != null) {
      footerHeight += 120;
    }

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/blur.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Main content wrapped in card
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    // Header with logo
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      child: Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(
                                'assets/logo.jpeg',
                                fit: BoxFit.cover,
                                height: 172,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Form content
                    Expanded(
                      child: Container(
                        decoration: const BoxDecoration(
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
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.blue.shade100,
                                    ),
                                  ),
                                  child: const Column(
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
                                const SizedBox(height: 24),
                                const Text(
                                  "Anamnesis",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ...anamnesis.map(buildIndikatorCard),
                                const SizedBox(height: 24),
                                const Text(
                                  "Periksa & Identifikasi",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ...identifikasi.map(buildIndikatorCard),
                                const SizedBox(height: 32),
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
          // Fixed bottom buttons
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
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
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text("Reset"),
                        ),
                        ElevatedButton(
                          onPressed: isFormComplete && !isLoading
                              ? handleSubmit
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Text("Hitung Klasifikasi"),
                        ),
                      ],
                    ),
                    if (hasil != null) ...[
                      const SizedBox(height: 16),
                      buildHasilSkriningCard(),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
