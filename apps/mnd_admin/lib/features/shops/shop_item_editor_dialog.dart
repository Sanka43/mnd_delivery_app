import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/shop_items_repository.dart';

Future<ShopItemDraft?> showShopItemEditorDialog(
  BuildContext context, {
  ShopItemRecord? existing,
}) {
  return showDialog<ShopItemDraft>(
    context: context,
    builder: (ctx) => _ShopItemEditorDialog(existing: existing),
  );
}

class _ShopItemEditorDialog extends StatefulWidget {
  const _ShopItemEditorDialog({this.existing});

  final ShopItemRecord? existing;

  @override
  State<_ShopItemEditorDialog> createState() => _ShopItemEditorDialogState();
}

class _ShopItemEditorDialogState extends State<_ShopItemEditorDialog> {
  late final TextEditingController _name;
  late final TextEditingController _price;
  late final TextEditingController _description;

  Uint8List? _pickedBytes;
  String _pickedContentType = 'image/jpeg';
  bool _removeImage = false;
  late bool _available;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _available = e?.available ?? true;
    _name = TextEditingController(text: e?.name ?? '');
    _price = TextEditingController(
      text: e != null && e.price == e.price.roundToDouble()
          ? e.price.round().toString()
          : (e?.price.toString() ?? ''),
    );
    _description = TextEditingController(text: e?.description ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    _description.dispose();
    super.dispose();
  }

  String _mimeFromFileName(String name) {
    final n = name.toLowerCase();
    if (n.endsWith('.png')) return 'image/png';
    if (n.endsWith('.webp')) return 'image/webp';
    if (n.endsWith('.gif')) return 'image/gif';
    return 'image/jpeg';
  }

  /// Uses [file_picker] (not `image_picker`) so Windows/desktop register the
  /// same `file_selector` plugin — avoids MissingPluginException on desktop.
  Future<void> _pickImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true,
      );
      if (result == null || result.files.isEmpty) return;

      final f = result.files.single;
      var bytes = f.bytes;
      if (bytes == null || bytes.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Could not read image data. Try a smaller file or '
                'another photo.',
              ),
            ),
          );
        }
        return;
      }

      if (!mounted) return;
      setState(() {
        _pickedBytes = bytes;
        _pickedContentType = _mimeFromFileName(f.name);
        _removeImage = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Photo selected. Tap Add or Save to upload.',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } on MissingPluginException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'File picker not ready ($e). Stop the app completely, then run:\n'
              'flutter clean && flutter pub get && flutter run',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not pick image: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _clearImage() {
    setState(() {
      if (_pickedBytes != null) {
        _pickedBytes = null;
        return;
      }
      final url = widget.existing?.imageUrl;
      if (url != null && url.isNotEmpty) {
        _removeImage = true;
      }
    });
  }

  void _submit() {
    final name = _name.text.trim();
    final price = num.tryParse(_price.text.trim());
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter item name.')),
      );
      return;
    }
    if (price == null || price < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid price (LKR).')),
      );
      return;
    }
    Navigator.of(context).pop(
      ShopItemDraft(
        name: name,
        price: price,
        description: _description.text,
        available: _available,
        newImageBytes: _pickedBytes,
        newImageContentType: _pickedContentType,
        removeImage: _removeImage,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isEdit = widget.existing != null;
    final hadUrl = widget.existing?.imageUrl != null &&
        widget.existing!.imageUrl!.isNotEmpty;
    final showNetworkPreview =
        hadUrl && _pickedBytes == null && !_removeImage;

    return AlertDialog(
      title: Text(isEdit ? 'Edit item' : 'Add item'),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AspectRatio(
                aspectRatio: 16 / 10,
                child: Material(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  clipBehavior: Clip.antiAlias,
                  child: _pickedBytes != null
                      ? Image.memory(
                          _pickedBytes!,
                          fit: BoxFit.cover,
                        )
                      : showNetworkPreview
                          ? Image.network(
                              widget.existing!.imageUrl!,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              },
                              errorBuilder: (_, __, ___) => const Center(
                                child: Icon(Icons.broken_image_outlined),
                              ),
                            )
                          : Center(
                              child: Icon(
                                Icons.add_photo_alternate_outlined,
                                size: 48,
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.photo_library_outlined, size: 20),
                      label: const Text('Choose from gallery'),
                    ),
                  ),
                  if (_pickedBytes != null || (hadUrl && !_removeImage)) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      tooltip: 'Remove image',
                      onPressed: _clearImage,
                      icon: const Icon(Icons.delete_outline_rounded),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _name,
                decoration: const InputDecoration(
                  labelText: 'Item name',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _price,
                decoration: const InputDecoration(
                  labelText: 'Price (LKR)',
                  border: OutlineInputBorder(),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _description,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 8),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text('Available'),
                subtitle: Text(
                  _available
                      ? 'Shown for ordering in customer apps.'
                      : 'Hidden from ordering (out of stock / paused).',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                ),
                value: _available,
                onChanged: (v) => setState(() => _available = v),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(isEdit ? 'Save' : 'Add'),
        ),
      ],
    );
  }
}
