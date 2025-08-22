class Sparepart {
  final String id;
  final String name;
  final int stock;
  final int price; // harga beli

  Sparepart({
    required this.id,
    required this.name,
    required this.stock,
    required this.price,
  });

  factory Sparepart.fromMap(String id, Map<String, dynamic> data) {
    return Sparepart(
      id: id,
      name: data['name'] ?? '',
      stock: (data['stock'] ?? 0) is int ? data['stock'] ?? 0 : int.tryParse('${data['stock']}') ?? 0,
      price: (data['price'] ?? 0) is int ? data['price'] ?? 0 : int.tryParse('${data['price']}') ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'stock': stock,
        'price': price,
      };
}