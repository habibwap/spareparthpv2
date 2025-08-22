import 'package:flutter/material.dart';
import '../models/sparepart.dart';
import 'package:intl/intl.dart';

class SparepartTile extends StatelessWidget {
  final Sparepart item;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const SparepartTile({
    super.key,
    required this.item,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  String rupiah(int value) {
    final f = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
    return f.format(value);
    }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(item.name),
      subtitle: Text('Stok: ${item.stock} • Harga: ${rupiah(item.price)}'),
      onTap: onTap,
      trailing: PopupMenuButton<String>(
        onSelected: (value) {
          if (value == 'edit') onEdit?.call();
          if (value == 'delete') onDelete?.call();
        },
        itemBuilder: (context) => [
          const PopupMenuItem(value: 'edit', child: Text('Edit')),
          const PopupMenuItem(value: 'delete', child: Text('Hapus')),
        ],
      ),
    );
  }
}