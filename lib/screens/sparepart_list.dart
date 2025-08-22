import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/sparepart.dart';
import '../services/firestore_service.dart';
import '../widgets/sparepart_tile.dart';
import 'sparepart_form.dart';

class SparepartListScreen extends StatelessWidget {
  final String categoryId;
  final String categoryName;

  const SparepartListScreen({super.key, required this.categoryId, required this.categoryName});

  @override
  Widget build(BuildContext context) {
    final service = FirestoreService();
    return Scaffold(
      appBar: AppBar(title: Text('Sparepart • $categoryName')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: service.watchSpareparts(categoryId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text('Belum ada sparepart. Tambahkan dengan tombol +'));
          }
          final items = docs.map((d) => Sparepart.fromMap(d.id, d.data())).toList();
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final sp = items[index];
              return SparepartTile(
                item: sp,
                onEdit: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => SparepartFormScreen(categoryId: categoryId, existing: sp),
                  ));
                },
                onDelete: () async {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Hapus Sparepart?'),
                      content: Text('Hapus "${sp.name}"?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
                        ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus')),
                      ],
                    ),
                  );
                  if (ok == true) {
                    await service.deleteSparepart(categoryId, sp.id);
                  }
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(
            builder: (_) => SparepartFormScreen(categoryId: categoryId),
          ));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}