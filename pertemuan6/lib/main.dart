import 'package:flutter/material.dart';
import 'api_client.dart';

void main() {
  runApp(const TugasApp());
}

class Catatan {
  final int? id;
  final String judul;
  final String isi;
  final String kategori;
  final DateTime dibuatPada;

  Catatan({
    this.id,
    required this.judul,
    required this.isi,
    required this.kategori,
    required this.dibuatPada,
  });

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'judul': judul,
    'isi': isi,
    'kategori': kategori,
    'dibuat_pada': dibuatPada.toUtc().toIso8601String(),
  };

  static Catatan fromJson(Map<String, dynamic> m) => Catatan(
    id: m['id'] as int?,
    judul: m['judul'] as String,
    isi: m['isi'] as String,
    kategori: m['kategori'] as String,
    dibuatPada: DateTime.parse(m['dibuat_pada'] as String),
  );

  Catatan copyWith({String? judul, String? isi, String? kategori}) => Catatan(
    id: id,
    judul: judul ?? this.judul,
    isi: isi ?? this.isi,
    kategori: kategori ?? this.kategori,
    dibuatPada: dibuatPada,
  );
}

class TugasApp extends StatelessWidget {
  const TugasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tugas Pertemuan 7',
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
          case '/form':
            final arg = settings.arguments;
            return MaterialPageRoute(
              builder: (_) => CatatanFormPage(initial: arg as Catatan?),
            );
          case '/detail':
            final c = settings.arguments as Catatan;
            return MaterialPageRoute(
              builder: (_) => DetailCatatanPage(catatan: c),
            );
        }
        return null;
      },
    );
  }
}

class HomePageTugas extends StatefulWidget {
  const HomePageTugas({super.key});

  @override
  State<HomePageTugas> createState() => _HomePageTugasState();
}

class _HomePageTugasState extends State<HomePageTugas> {
  late Future<List<Catatan>> _futureCatatan;

  String _filterKategori = 'Semua';
  final List<String> _opsiFilter = ['Semua', 'Kuliah', 'Tugas', 'Pribadi', 'Lainnya'];

  @override
  void initState() {
    super.initState();
    _muatUlang();
  }

  void _muatUlang() {
    setState(() {
      _futureCatatan = ApiClient.instance.getAll();
    });
  }

  Future<void> _bukaForm({Catatan? initial}) async {
    await Navigator.pushNamed(context, '/form', arguments: initial);
    _muatUlang();
  }

  Future<void> _konfirmasiHapus(Catatan c) async {
    final yakin = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus catatan?'),
        content: Text('"${c.judul}" akan dihapus permanen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (yakin == true) {
      try {
        await ApiClient.instance.delete(c.id!);
        if (!mounted) return;
        _muatUlang();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('"${c.judul}" dihapus')),
        );
      } on ApiException catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus: ${e.message}')),
        );
      }
    }
  }

  Widget _itemCatatan(Catatan c) {
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
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: Colors.blueGrey),
              tooltip: 'Edit',
              onPressed: () => _bukaForm(initial: c),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              tooltip: 'Hapus',
              onPressed: () => _konfirmasiHapus(c),
            ),
          ],
        ),
        onTap: () async {
          await Navigator.pushNamed(context, '/detail', arguments: c);
          _muatUlang();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tugas Pertemuan 7'),
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
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _muatUlang,
          ),
        ],
      ),
      body: FutureBuilder<List<Catatan>>(
        future: _futureCatatan,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            final e = snapshot.error;
            final pesan = e is ApiException ? e.message : 'Terjadi kesalahan: $e';
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48),
                  const SizedBox(height: 8),
                  Text(pesan, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  FilledButton(onPressed: _muatUlang, child: const Text('Coba lagi')),
                ],
              ),
            );
          }

          final semua = snapshot.data ?? const [];
          final data = _filterKategori == 'Semua'
              ? semua
              : semua.where((c) => c.kategori == _filterKategori).toList();

          if (data.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_rounded, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    semua.isEmpty
                        ? 'Belum ada catatan.\nTap tombol + untuk menambah!'
                        : 'Tidak ada catatan di kategori\n"$_filterKategori"',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(top: 10, bottom: 80),
            itemCount: data.length,
            itemBuilder: (_, i) => _itemCatatan(data[i]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _bukaForm(),
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
      ),
    );
  }
}

class CatatanFormPage extends StatefulWidget {
  final Catatan? initial;
  const CatatanFormPage({super.key, this.initial});

  @override
  State<CatatanFormPage> createState() => _CatatanFormPageState();
}

class _CatatanFormPageState extends State<CatatanFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _judulCtrl;
  late final TextEditingController _isiCtrl;
  late String _kategori;
  final _kategoriOpsi = const ['Kuliah', 'Tugas', 'Pribadi', 'Lainnya'];

  bool get _isEdit => widget.initial != null;
  bool _menyimpan = false;

  @override
  void initState() {
    super.initState();
    _judulCtrl = TextEditingController(text: widget.initial?.judul ?? '');
    _isiCtrl = TextEditingController(text: widget.initial?.isi ?? '');
    _kategori = widget.initial?.kategori ?? 'Kuliah';
  }

  @override
  void dispose() {
    _judulCtrl.dispose();
    _isiCtrl.dispose();
    super.dispose();
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _menyimpan = true);

    try {
      if (_isEdit) {
        final updated = widget.initial!.copyWith(
          judul: _judulCtrl.text.trim(),
          isi: _isiCtrl.text.trim(),
          kategori: _kategori,
        );
        await ApiClient.instance.update(updated);
      } else {
        final baru = Catatan(
          judul: _judulCtrl.text.trim(),
          isi: _isiCtrl.text.trim(),
          kategori: _kategori,
          dibuatPada: DateTime.now(),
        );
        await ApiClient.instance.insert(baru);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_isEdit ? 'Catatan diperbarui 📝' : 'Catatan ditambahkan 🚀'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
      Navigator.pop(context);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _menyimpan = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan: ${e.message}')),
      );
    }
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
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Catatan' : 'Tambah Catatan'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _judulCtrl,
              decoration: _inputStyle('Judul Catatan', Icons.title),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Judul wajib diisi';
                if (v.trim().length < 3) return 'Minimal 3 karakter';
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
              controller: _isiCtrl,
              maxLines: 5,
              decoration: _inputStyle('Isi Catatan', Icons.notes),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Isi catatan jangan dikosongkan'
                  : null,
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 50,
              child: FilledButton.icon(
                onPressed: _menyimpan ? null : _simpan,
                icon: _menyimpan
                    ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
                    : const Icon(Icons.save),
                label: Text(
                  _isEdit ? 'Update Catatan' : 'Simpan Catatan',
                  style: const TextStyle(fontSize: 16),
                ),
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

class DetailCatatanPage extends StatelessWidget {
  final Catatan catatan;
  const DetailCatatanPage({super.key, required this.catatan});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Catatan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Catatan',
            onPressed: () async {
              await Navigator.pushNamed(context, '/form', arguments: catatan);
              if (context.mounted) Navigator.pop(context);
            },
          ),
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
                  labelStyle: TextStyle(
                      color: Colors.deepPurple.shade700,
                      fontWeight: FontWeight.bold),
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