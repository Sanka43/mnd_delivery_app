import 'package:flutter/material.dart';

import '../../data/shops_repository.dart';

/// Add or edit a shop. Returns [ShopRecordDraft] on save, `null` on cancel.
Future<ShopRecordDraft?> showShopEditorDialog(
  BuildContext context, {
  ShopRecord? existing,
}) {
  return showDialog<ShopRecordDraft>(
    context: context,
    builder: (ctx) => _ShopEditorDialog(existing: existing),
  );
}

class _ShopEditorDialog extends StatefulWidget {
  const _ShopEditorDialog({this.existing});

  final ShopRecord? existing;

  @override
  State<_ShopEditorDialog> createState() => _ShopEditorDialogState();
}

class _ShopEditorDialogState extends State<_ShopEditorDialog> {
  late final TextEditingController _name;
  late final TextEditingController _owner;
  late final TextEditingController _area;
  late final TextEditingController _phone;
  late ShopCategory _category;
  late ShopRecordStatus _status;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _name = TextEditingController(text: e?.name ?? '');
    _owner = TextEditingController(text: e?.ownerName ?? '');
    _area = TextEditingController(text: e?.area ?? '');
    _phone = TextEditingController(text: e?.phone ?? '');
    _category = e?.category ?? ShopCategory.restaurant;
    _status = e?.status ?? ShopRecordStatus.pending;
  }

  @override
  void dispose() {
    _name.dispose();
    _owner.dispose();
    _area.dispose();
    _phone.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _name.text.trim();
    final owner = _owner.text.trim();
    final area = _area.text.trim();
    final phone = _phone.text.trim();
    if (name.isEmpty || owner.isEmpty || area.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fill name, owner, and area.')),
      );
      return;
    }
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phone number is required.')),
      );
      return;
    }
    final digits = RegExp(r'\d').allMatches(phone).length;
    if (digits < 7) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a valid phone number (at least 7 digits).'),
        ),
      );
      return;
    }
    Navigator.of(context).pop(
      ShopRecordDraft(
        name: name,
        ownerName: owner,
        area: area,
        phone: phone,
        category: _category,
        status: _status,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return AlertDialog(
      title: Text(isEdit ? 'Edit shop' : 'Add shop'),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 380,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _name,
                decoration: const InputDecoration(
                  labelText: 'Shop name',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _owner,
                decoration: const InputDecoration(
                  labelText: 'Owner name',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _area,
                decoration: const InputDecoration(
                  labelText: 'Area / city',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _phone,
                decoration: const InputDecoration(
                  labelText: 'Phone number',
                  border: OutlineInputBorder(),
                  hintText: 'e.g. 077 123 4567',
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<ShopCategory>(
                    isExpanded: true,
                    value: _category,
                    items: ShopCategory.values
                        .map(
                          (c) => DropdownMenuItem(
                            value: c,
                            child: Text(c.label),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _category = v);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),
              InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<ShopRecordStatus>(
                    isExpanded: true,
                    value: _status,
                    items: ShopRecordStatus.values
                        .map(
                          (s) => DropdownMenuItem(
                            value: s,
                            child: Text(_statusLabel(s)),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _status = v);
                    },
                  ),
                ),
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

String _statusLabel(ShopRecordStatus s) => switch (s) {
      ShopRecordStatus.pending => 'Pending',
      ShopRecordStatus.active => 'Active',
      ShopRecordStatus.suspended => 'Suspended',
    };
