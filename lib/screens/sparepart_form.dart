import 'package:flutter/material.dart';
import '../models/sparepart.dart';
import '../services/firestore_service.dart';

class SparepartFormScreen extends StatefulWidget {
  final String categoryId;
  final Sparepart? existing;

  const SparepartFormScreen({super.key, required this.categoryId, this.existing});

  @override
  State<SparepartFormScreen> createState() => _SparepartFormScreenState();
}

class _SparepartFormScreenState extends State<SparepartFormScreen> {
  final _name = TextEditingController();
  final _stock = TextEditingController();
  final _price = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final service = FirestoreService();

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      _name.text = widget.existing!.name;
      _stock.text = widget.existing!.stock.toString();
      _price.text = widget.existing!.price.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Sparepart' : 'Tambah Sparepart')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Nama Sparepart'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _stock,
                decoration: const InputDecoration(labelText: 'Jumlah Stok'),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Stok wajib diisi';
                  final n = int.tryParse(v);
                  if (n == null) return 'Stok harus angka';
                  if (n < 0) return 'Tidak boleh negatif';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _price,
                decoration: const InputDecoration(labelText: 'Harga Beli (Rp)'),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Harga wajib diisi';
                  final n = int.tryParse(v);
                  if (n == null) return 'Harga harus angka';
                  if (n < 0) return 'Tidak boleh negatif';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) return;
                    final name = _name.text.trim();
                    final stock = int.parse(_stock.text.trim());
                    final price = int.parse(_price.text.trim());
                    if (isEdit) {
                      await service.updateSparepart(widget.categoryId, widget.existing!.id,
                          name: name, stock: stock, price: price);
                    } else {
                      await service.addSparepart(widget.categoryId, name, stock, price);
                    }
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: Text(isEdit ? 'Simpan Perubahan' : 'Tambah'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}