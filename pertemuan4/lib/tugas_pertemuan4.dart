import 'package:flutter/material.dart';

void main() {
  runApp(const TugasApp());
}

// ==========================================
// 1. MODEL DATA (TUGAS MANDIRI 3: EMAIL)
// ==========================================
class Catatan {
  final String judul;
  final String isi;
  final String kategori;
  final String emailPengirim;
  final DateTime dibuatPada;

  Catatan({
    required this.judul,
    required this.isi,
    required this.kategori,
    required this.emailPengirim,
    required this.dibuatPada,
  });
}

// ==========================================
// 2. ROOT APP & NAVIGASI
// ==========================================
class TugasApp extends StatelessWidget {
  const TugasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tugas Pertemuan 4',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.deepPurple,
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey[100],
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: Colors.black45,
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePageTugas(),
      },
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/tambah':
            final args = settings.arguments as Map<String, dynamic>?;
            return MaterialPageRoute(
              builder: (_) => TambahCatatanTugas(catatanLama: args?['catatan']),
            );
          case '/detail':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => DetailCatatanTugas(
                catatan: args['catatan'],
                index: args['index'],
              ),
            );
        }
        return null;
      },
    );
  }
}

// ==========================================
// 3. HALAMAN HOME (TUGAS MANDIRI 1 & 2)
// ==========================================
class HomePageTugas extends StatefulWidget {
  const HomePageTugas({super.key});

  @override
  State<HomePageTugas> createState() => _HomePageTugasState();
}

class _HomePageTugasState extends State<HomePageTugas> {
  final List<Catatan> _catatan = [
    Catatan(
      judul: 'Tugas Mandiri Selesai',
      isi: 'Fitur Filter, Edit, dan Email udah kelar semua bang.',
      kategori: 'Tugas',
      emailPengirim: 'mahasiswa@pasundan.ac.id',
      dibuatPada: DateTime.now(),
    ),
  ];

  String _filterKategori = 'Semua';
  final List<String> _opsiFilter = ['Semua', 'Kuliah', 'Tugas', 'Pribadi', 'Lainnya'];

  Future<void> _bukaTambahCatatan() async {
    final hasil = await Navigator.pushNamed(context, '/tambah');

    if (hasil is Catatan) {
      setState(() => _catatan.add(hasil));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Keren! Catatan "${hasil.judul}" berhasil ditambah 🚀'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void _hapusCatatan(Catatan c) {
    setState(() {
      _catatan.remove(c);
    });
  }

  @override
  Widget build(BuildContext context) {
    final catatanTampil = _filterKategori == 'Semua'
        ? _catatan
        : _catatan.where((c) => c.kategori == _filterKategori).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tugas Mandiri'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list_rounded),
            tooltip: 'Filter Kategori',
            onSelected: (String k) => setState(() => _filterKategori = k),
            itemBuilder: (BuildContext context) {
              return _opsiFilter.map((String k) {
                return PopupMenuItem<String>(
                  value: k,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(k),
                      if (_filterKategori == k)
                        const Icon(Icons.check, color: Colors.deepPurple, size: 20),
                    ],
                  ),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: catatanTampil.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_rounded, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              _catatan.isEmpty
                  ? 'Yah, belum ada catatan nih.\nTambah dulu gih!'
                  : 'Nggak ada catatan di kategori\n"$_filterKategori"',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.only(top: 10, bottom: 80),
        itemCount: catatanTampil.length,
        itemBuilder: (context, i) {
          final c = catatanTampil[i];
          final realIndex = _catatan.indexOf(c);

          return Card(
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              leading: CircleAvatar(
                backgroundColor: Colors.deepPurple.shade100,
                child: const Icon(Icons.note_alt, color: Colors.deepPurple),
              ),
              title: Text(c.judul, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(c.kategori, style: TextStyle(color: Colors.deepPurple.shade700)),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                onPressed: () => _hapusCatatan(c),
              ),
              onTap: () async {
                final hasil = await Navigator.pushNamed(
                    context,
                    '/detail',
                    arguments: {'catatan': c, 'index': realIndex}
                );

                if (hasil != null && hasil is Map && hasil['action'] == 'edit') {
                  setState(() {
                    _catatan[hasil['index']] = hasil['catatan'];
                  });
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Catatan berhasil di-update 📝')),
                  );
                }
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _bukaTambahCatatan,
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
      ),
    );
  }
}

// ==========================================
// 4. HALAMAN TAMBAH/EDIT CATATAN
// ==========================================
class TambahCatatanTugas extends StatefulWidget {
  final Catatan? catatanLama;
  const TambahCatatanTugas({super.key, this.catatanLama});

  @override
  State<TambahCatatanTugas> createState() => _TambahCatatanTugasState();
}

class _TambahCatatanTugasState extends State<TambahCatatanTugas> {
  final _formKey = GlobalKey<FormState>();
  final _judulCtrl = TextEditingController();
  final _isiCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  String _kategori = 'Kuliah';
  final _kategoriOpsi = const ['Kuliah', 'Tugas', 'Pribadi', 'Lainnya'];

  @override
  void initState() {
    super.initState();
    if (widget.catatanLama != null) {
      _judulCtrl.text = widget.catatanLama!.judul;
      _isiCtrl.text = widget.catatanLama!.isi;
      _emailCtrl.text = widget.catatanLama!.emailPengirim;
      _kategori = widget.catatanLama!.kategori;
    }
  }

  @override
  void dispose() {
    _judulCtrl.dispose();
    _isiCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  void _simpan() {
    if (!_formKey.currentState!.validate()) return;

    final catatanBaru = Catatan(
      judul: _judulCtrl.text.trim(),
      isi: _isiCtrl.text.trim(),
      kategori: _kategori,
      emailPengirim: _emailCtrl.text.trim(),
      dibuatPada: widget.catatanLama?.dibuatPada ?? DateTime.now(),
    );

    Navigator.pop(context, catatanBaru);
  }

  InputDecoration _inputStyle(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.catatanLama != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Tugas' : 'Tambah Tugas')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _judulCtrl,
              decoration: _inputStyle('Judul Catatan', Icons.title),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Judul wajib diisi ngab';
                if (v.trim().length < 3) return 'Minimal 3 karakter dong';
                return null;
              },
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _kategori,
              decoration: _inputStyle('Kategori', Icons.category),
              items: _kategoriOpsi
                  .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                  .toList(),
              onChanged: (v) => setState(() => _kategori = v!),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: _inputStyle('Email Pengirim', Icons.email),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Email wajib diisi';
                final emailValid = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
                if (!emailValid.hasMatch(v)) return 'Format emailnya salah woi';
                return null;
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _isiCtrl,
              maxLines: 5,
              decoration: _inputStyle('Isi Catatan', Icons.notes),
              validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Isinya jangan dikosongin yak' : null,
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 50,
              child: FilledButton.icon(
                onPressed: _simpan,
                icon: const Icon(Icons.save),
                label: Text(isEdit ? 'Update Catatan' : 'Simpan Catatan', style: const TextStyle(fontSize: 16)),
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 5. HALAMAN DETAIL CATATAN
// ==========================================
class DetailCatatanTugas extends StatelessWidget {
  final Catatan catatan;
  final int index;
  const DetailCatatanTugas({super.key, required this.catatan, required this.index});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Tugas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_document),
            tooltip: 'Edit Catatan',
            onPressed: () async {
              final hasil = await Navigator.pushNamed(context, '/tambah', arguments: {'catatan': catatan});
              if (hasil != null && hasil is Catatan) {
                if (!context.mounted) return;
                Navigator.pop(context, {'action': 'edit', 'catatan': hasil, 'index': index});
              }
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              catatan.judul,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Chip(
                  label: Text(catatan.kategori),
                  backgroundColor: Colors.deepPurple.shade50,
                  labelStyle: TextStyle(color: Colors.deepPurple.shade700, fontWeight: FontWeight.bold),
                  side: BorderSide.none,
                ),
                const SizedBox(width: 12),
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  "${catatan.dibuatPada.day}/${catatan.dibuatPada.month}/${catatan.dibuatPada.year}",
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.email_outlined, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 6),
                Text(
                  catatan.emailPengirim,
                  style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Divider(height: 32, thickness: 1),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Text(
                catatan.isi,
                style: const TextStyle(fontSize: 16, height: 1.6, letterSpacing: 0.3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}