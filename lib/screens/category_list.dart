import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/category.dart';
import '../services/firestore_service.dart';
import 'sparepart_list.dart';

class CategoryListScreen extends StatefulWidget {
  const CategoryListScreen({super.key});

  @override
  State<CategoryListScreen> createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen> {
  final service = FirestoreService();
  final _controller = TextEditingController();

  void _showAddDialog({Category? existing}) {
    _controller.text = existing?.name ?? '';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(existing == null ? 'Kategori Baru' : 'Edit Kategori'),
        content: TextField(
          controller: _controller,
          decoration: const InputDecoration(labelText: 'Nama kategori (mis. LCD, Baterai)'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              final name = _controller.text.trim();
              if (name.isEmpty) return;
              if (existing == null) {
                await service.addCategory(name);
              } else {
                await service.updateCategory(existing.id, name);
              }
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kategori Sparepart'),
        actions: [
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: service.watchCategories(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return Center(
              child: Text('Halo ${user.displayName ?? ''} 👋\nBelum ada kategori. Tambahkan dengan tombol +', textAlign: TextAlign.center),
            );
          }
          final items = docs.map((d) => Category.fromMap(d.id, d.data())).toList();
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final c = items[index];
              return ListTile(
                title: Text(c.name),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => SparepartListScreen(categoryId: c.id, categoryName: c.name),
                  ));
                },
                trailing: PopupMenuButton<String>(
                  onSelected: (v) async {
                    if (v == 'edit') _showAddDialog(existing: c);
                    if (v == 'delete') {
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Hapus Kategori?'),
                          content: const Text('Semua sparepart di dalam kategori ini juga akan dihapus.'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
                            ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus')),
                          ],
                        ),
                      );
                      if (ok == true) {
                        await service.deleteCategory(c.id);
                      }
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'edit', child: Text('Edit')),
                    PopupMenuItem(value: 'delete', child: Text('Hapus')),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}