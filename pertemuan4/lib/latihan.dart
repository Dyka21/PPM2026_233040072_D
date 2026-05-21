import 'package:flutter/material.dart';

void main() {
  runApp(const LatihanApp());
}

class Catatan {
  final String judul;
  final String isi;
  final String kategori;
  final DateTime dibuatPada;

  Catatan({required this.judul, required this.isi, required this.kategori, required this.dibuatPada});
}

class LatihanApp extends StatelessWidget {
  const LatihanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Latihan Pertemuan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.deepPurple,
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey[100],
        appBarTheme: const AppBarTheme(
          centerTitle: true, backgroundColor: Colors.deepPurple, foregroundColor: Colors.white, elevation: 4, shadowColor: Colors.black45,
        ),
        cardTheme: CardThemeData(
          elevation: 2, margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePageLatihan(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/tambah') return MaterialPageRoute(builder: (_) => const TambahCatatanLatihan());
        if (settings.name == '/detail') return MaterialPageRoute(builder: (_) => DetailCatatanLatihan(catatan: settings.arguments as Catatan));
        return null;
      },
    );
  }
}

class HomePageLatihan extends StatefulWidget {
  const HomePageLatihan({super.key});
  @override
  State<HomePageLatihan> createState() => _HomePageLatihanState();
}

class _HomePageLatihanState extends State<HomePageLatihan> {
  final List<Catatan> _catatan = [
    Catatan(judul: 'Belajar Flutter', isi: 'Mempelajari Stateful Widget dkk.', kategori: 'Kuliah', dibuatPada: DateTime.now()),
  ];

  Future<void> _bukaTambah() async {
    final hasil = await Navigator.pushNamed(context, '/tambah');
    if (hasil is Catatan) {
      setState(() => _catatan.add(hasil));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Catatan ditambah!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Latihan Modul')),
      body: _catatan.isEmpty
          ? const Center(child: Text('Belum ada catatan', style: TextStyle(fontSize: 16)))
          : ListView.builder(
        padding: const EdgeInsets.only(top: 10, bottom: 80),
        itemCount: _catatan.length,
        itemBuilder: (context, i) {
          final c = _catatan[i];
          return Card(
            child: ListTile(
              leading: CircleAvatar(backgroundColor: Colors.deepPurple.shade100, child: const Icon(Icons.note_alt, color: Colors.deepPurple)),
              title: Text(c.judul, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(c.kategori),
              trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => setState(() => _catatan.removeAt(i))),
              onTap: () => Navigator.pushNamed(context, '/detail', arguments: c),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(onPressed: _bukaTambah, icon: const Icon(Icons.add), label: const Text('Tambah')),
    );
  }
}

class TambahCatatanLatihan extends StatefulWidget {
  const TambahCatatanLatihan({super.key});
  @override
  State<TambahCatatanLatihan> createState() => _TambahCatatanLatihanState();
}

class _TambahCatatanLatihanState extends State<TambahCatatanLatihan> {
  final _formKey = GlobalKey<FormState>();
  final _judulCtrl = TextEditingController();
  final _isiCtrl = TextEditingController();
  String _kategori = 'Kuliah';

  @override
  void dispose() {
    _judulCtrl.dispose(); _isiCtrl.dispose(); super.dispose();
  }

  void _simpan() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(context, Catatan(judul: _judulCtrl.text, isi: _isiCtrl.text, kategori: _kategori, dibuatPada: DateTime.now()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Latihan')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(controller: _judulCtrl, decoration: const InputDecoration(labelText: 'Judul', border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? 'Wajib isi' : null),
            const SizedBox(height: 16),
            DropdownButtonFormField(value: _kategori, items: ['Kuliah', 'Tugas', 'Pribadi', 'Lainnya'].map((k) => DropdownMenuItem(value: k, child: Text(k))).toList(), onChanged: (v) => setState(() => _kategori = v as String), decoration: const InputDecoration(border: OutlineInputBorder())),
            const SizedBox(height: 16),
            TextFormField(controller: _isiCtrl, maxLines: 5, decoration: const InputDecoration(labelText: 'Isi', border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? 'Wajib isi' : null),
            const SizedBox(height: 24),
            FilledButton(onPressed: _simpan, child: const Text('Simpan')),
          ],
        ),
      ),
    );
  }
}

class DetailCatatanLatihan extends StatelessWidget {
  final Catatan catatan;
  const DetailCatatanLatihan({super.key, required this.catatan});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Latihan')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(catatan.judul, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          Chip(label: Text(catatan.kategori)),
          const Divider(),
          Text(catatan.isi, style: const TextStyle(fontSize: 16)),
        ]),
      ),
    );
  }
}