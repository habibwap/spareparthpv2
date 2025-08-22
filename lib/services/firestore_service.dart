import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;

  String get uid => FirebaseAuth.instance.currentUser!.uid;

  CollectionReference<Map<String, dynamic>> get _userDoc =>
      _db.collection('users');

  CollectionReference<Map<String, dynamic>> categoriesCol() =>
      _userDoc.doc(uid).collection('categories');

  CollectionReference<Map<String, dynamic>> sparepartsCol(String categoryId) =>
      categoriesCol().doc(categoryId).collection('spareparts');

  // Categories
  Future<String> addCategory(String name) async {
    final doc = await categoriesCol().add({
      'name': name,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  Future<void> updateCategory(String id, String name) async {
    await categoriesCol().doc(id).update({'name': name});
  }

  Future<void> deleteCategory(String id) async {
    // delete nested spareparts
    final sp = await sparepartsCol(id).get();
    for (final d in sp.docs) {
      await d.reference.delete();
    }
    await categoriesCol().doc(id).delete();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchCategories() {
    return categoriesCol().orderBy('createdAt', descending: false).snapshots();
  }

  // Spareparts
  Future<String> addSparepart(String categoryId, String name, int stock, int price) async {
    final doc = await sparepartsCol(categoryId).add({
      'name': name,
      'stock': stock,
      'price': price,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  Future<void> updateSparepart(String categoryId, String id, {String? name, int? stock, int? price}) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (stock != null) data['stock'] = stock;
    if (price != null) data['price'] = price;
    await sparepartsCol(categoryId).doc(id).update(data);
  }

  Future<void> deleteSparepart(String categoryId, String id) async {
    await sparepartsCol(categoryId).doc(id).delete();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchSpareparts(String categoryId) {
    return sparepartsCol(categoryId).orderBy('createdAt', descending: false).snapshots();
  }
}