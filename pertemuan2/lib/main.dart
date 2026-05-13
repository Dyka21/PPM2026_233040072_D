import 'package:flutter/material.dart';
import 'gallery_widget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const ProfilePage(),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: const Text('Profil Saya'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text('Menu', style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            const ListTile(leading: Icon(Icons.person), title: Text('Profil')),
            ListTile(
              leading: const Icon(Icons.widgets),
              title: const Text('Widget Gallery'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const GalleryHome()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Pengaturan'),
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Info'),
                    content: const Text('Menu pengaturan sedang dikembangkan.'),
                    actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage('https://ui-avatars.com/api/?name=Andyka+Khaerulana&background=0D8ABC&color=fff'),
                  ),
                  const SizedBox(height: 12),
                  const Text('Andyka Khaerulana', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const Text('Mahasiswa Teknik Informatika - UNPAS', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Row(
              children: [
                Expanded(child: StatBox(label: 'Post', value: '5')),
                Expanded(child: StatBox(label: 'Teman', value: '450')),
                Expanded(child: StatBox(label: 'Project', value: '12')),
              ],
            ),
            const SizedBox(height: 24),
            const SectionCard(icon: Icons.info, title: 'Tentang', content: 'Fokus pada Web Development (Laravel & Golang) serta UI/UX Design.'),
            const SectionCard(icon: Icons.school, title: 'Pendidikan', content: 'Universitas Pasundan\nTeknik Informatika - Semester 6'),

            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [Icon(Icons.star, color: Colors.blue), SizedBox(width: 12), Text('Skills', style: TextStyle(fontWeight: FontWeight.bold))]),
                    SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: [Chip(label: Text('Laravel')), Chip(label: Text('Golang')), Chip(label: Text('UI/UX')), Chip(label: Text('Figma'))],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Edit profil belum tersedia'))),
        child: const Icon(Icons.edit),
      ),
      bottomNavigationBar: NavigationBar(
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}

class StatBox extends StatelessWidget {
  final String label, value;
  const StatBox({super.key, required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Column(children: [Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), Text(label)]);
  }
}

class SectionCard extends StatelessWidget {
  final IconData icon;
  final String title, content;
  const SectionCard({super.key, required this.icon, required this.title, required this.content});
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(leading: Icon(icon, color: Colors.blue), title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)), subtitle: Text(content)),
    );
  }
}