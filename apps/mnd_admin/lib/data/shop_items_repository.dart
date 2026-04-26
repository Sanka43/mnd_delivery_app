import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'shops_repository.dart';

/// One menu / catalog item under `shops/{shopId}/items/{itemId}`.
class ShopItemRecord {
  const ShopItemRecord({
    required this.id,
    required this.name,
    required this.price,
    this.shopId,
    this.description,
    this.imageUrl,
    this.createdAt,
    this.available = true,
  });

  final String id;
  final String name;
  final num price;
  /// Parent shop document id (`shops/{shopId}`), duplicated on the doc for queries / console.
  final String? shopId;
  final String? description;
  final String? imageUrl;
  final DateTime? createdAt;
  /// When `false`, item is treated as out of stock / hidden from ordering (customer apps should filter).
  final bool available;

  factory ShopItemRecord.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    final av = d['available'];
    return ShopItemRecord(
      id: doc.id,
      name: (d['name'] as String?)?.trim() ?? '',
      price: (d['price'] as num?) ?? 0,
      shopId: (d['shop_id'] as String?)?.trim(),
      description: (d['description'] as String?)?.trim(),
      imageUrl: (d['image_url'] as String?)?.trim(),
      createdAt: (d['created_at'] as Timestamp?)?.toDate(),
      available: av is bool ? av : true,
    );
  }
}

class ShopItemDraft {
  const ShopItemDraft({
    required this.name,
    required this.price,
    this.description = '',
    this.available = true,
    this.newImageBytes,
    this.newImageContentType = 'image/jpeg',
    this.removeImage = false,
  });

  final String name;
  final num price;
  final String description;
  final bool available;
  final Uint8List? newImageBytes;
  final String newImageContentType;
  final bool removeImage;
}

class ShopItemsRepository {
  ShopItemsRepository({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _db = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  final FirebaseFirestore _db;
  final FirebaseStorage _storage;

  static const String itemsSubcollection = 'items';

  CollectionReference<Map<String, dynamic>> _itemsCol(String shopId) =>
      _db
          .collection(ShopsRepository.collection)
          .doc(shopId)
          .collection(itemsSubcollection);

  static String _fileExtForMime(String mime) {
    switch (mime.toLowerCase()) {
      case 'image/png':
        return 'png';
      case 'image/webp':
        return 'webp';
      case 'image/gif':
        return 'gif';
      default:
        return 'jpg';
    }
  }

  Future<String> _uploadItemImage(
    String shopId,
    String itemId,
    Uint8List bytes,
    String contentType,
  ) async {
    final ext = _fileExtForMime(contentType);
    final ref = _storage.ref('shop_item_images/$shopId/$itemId.$ext');
    final task = ref.putData(
      bytes,
      SettableMetadata(contentType: contentType),
    );
    final snapshot = await task;
    if (snapshot.state != TaskState.success) {
      throw FirebaseException(
        plugin: 'firebase_storage',
        message: 'Upload did not complete: ${snapshot.state}',
        code: 'upload-failed',
      );
    }
    return snapshot.ref.getDownloadURL();
  }

  Future<void> _tryDeleteStoredObject(String? downloadUrl) async {
    if (downloadUrl == null || downloadUrl.isEmpty) return;
    try {
      await _storage.refFromURL(downloadUrl).delete();
    } on FirebaseException catch (e) {
      if (e.code == 'object-not-found') return;
      rethrow;
    }
  }

  Stream<List<ShopItemRecord>> watchItems(String shopId) {
    // No server `orderBy`: docs missing `created_at` would be excluded from the query.
    return _itemsCol(shopId).snapshots().map((snap) {
      final list = snap.docs.map(ShopItemRecord.fromDoc).toList();
      int compareItems(ShopItemRecord a, ShopItemRecord b) {
        if (a.available != b.available) {
          return a.available ? -1 : 1;
        }
        final ca = a.createdAt;
        final cb = b.createdAt;
        if (ca == null && cb == null) return 0;
        if (ca == null) return 1;
        if (cb == null) return -1;
        return cb.compareTo(ca);
      }

      list.sort(compareItems);
      return list;
    });
  }

  /// Returns `true` if the user picked an image but Storage upload failed (item
  /// is still saved without `image_url`).
  Future<bool> create(String shopId, ShopItemDraft draft) async {
    final docRef = _itemsCol(shopId).doc();
    final id = docRef.id;
    String? imageUrl;
    var imageUploadFailed = false;
    final bytes = draft.newImageBytes;
    if (bytes != null && bytes.isNotEmpty) {
      try {
        imageUrl = await _uploadItemImage(
          shopId,
          id,
          bytes,
          draft.newImageContentType,
        );
      } on FirebaseException {
        // Storage off / rules / bucket: still write the item; image can be added later.
        imageUrl = null;
        imageUploadFailed = true;
      }
    }
    await docRef.set({
      'shop_id': shopId,
      'name': draft.name.trim(),
      'price': draft.price,
      'description': draft.description.trim().isEmpty
          ? null
          : draft.description.trim(),
      'image_url': imageUrl,
      'available': draft.available,
      'created_at': FieldValue.serverTimestamp(),
    });
    return imageUploadFailed;
  }

  Future<void> update(
    String shopId,
    String itemId,
    ShopItemDraft draft, {
    String? previousImageUrl,
  }) async {
    final desc = draft.description.trim();
    final data = <String, dynamic>{
      'shop_id': shopId,
      'name': draft.name.trim(),
      'price': draft.price,
      'description': desc.isEmpty ? null : desc,
      'available': draft.available,
    };

    if (draft.removeImage) {
      await _tryDeleteStoredObject(previousImageUrl);
      data['image_url'] = null;
    } else {
      final bytes = draft.newImageBytes;
      if (bytes != null && bytes.isNotEmpty) {
        // Delete old object before upload: new bytes often land at the same path
        // (`.../itemId.ext`). Upload-then-delete would remove the file we just wrote.
        await _tryDeleteStoredObject(previousImageUrl);
        final url = await _uploadItemImage(
          shopId,
          itemId,
          bytes,
          draft.newImageContentType,
        );
        data['image_url'] = url;
      }
    }

    await _itemsCol(shopId).doc(itemId).update(data);
  }

  /// Toggle or set availability without opening the full editor.
  Future<void> setAvailable(
    String shopId,
    String itemId,
    bool available,
  ) async {
    await _itemsCol(shopId).doc(itemId).update({'available': available});
  }

  Future<void> delete(String shopId, String itemId, {String? imageUrl}) async {
    await _tryDeleteStoredObject(imageUrl);
    await _itemsCol(shopId).doc(itemId).delete();
  }
}
