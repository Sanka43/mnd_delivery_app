import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mnd_core/mnd_core.dart';
import 'package:mnd_theme/mnd_theme.dart';

import '../../data/settings_repository.dart';

/// Form for `settings/global` with live preview (example item subtotal).
class GlobalSettingsPage extends StatefulWidget {
  const GlobalSettingsPage({super.key});

  @override
  State<GlobalSettingsPage> createState() => _GlobalSettingsPageState();
}

class _GlobalSettingsPageState extends State<GlobalSettingsPage> {
  final _repo = SettingsRepository();
  final _commission = TextEditingController();
  final _deliveryFee = TextEditingController();
  final _deliveryCut = TextEditingController();
  final _previewItemPrice = TextEditingController(text: '1000');

  CommissionType _commissionType = CommissionType.fixed;
  GlobalSettings? _loadedBaseline;
  bool _loading = true;
  String? _loadError;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final s = await _repo.loadGlobal();
      final effective = s ??
          const GlobalSettings(
            commissionType: CommissionType.fixed,
            commissionValue: 30,
            deliveryFee: 220,
            deliveryCut: 20,
          );
      _loadedBaseline = s;
      _commissionType = effective.commissionType;
      _commission.text = _fmt(effective.commissionValue);
      _deliveryFee.text = _fmt(effective.deliveryFee);
      _deliveryCut.text = _fmt(effective.deliveryCut);
    } catch (e) {
      _loadError = e.toString();
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  static String _fmt(num n) {
    if (n == n.roundToDouble()) return n.round().toString();
    return n.toString();
  }

  GlobalSettings _draftFromFields() {
    return GlobalSettings(
      commissionType: _commissionType,
      commissionValue: num.tryParse(_commission.text.trim()) ?? 0,
      deliveryFee: num.tryParse(_deliveryFee.text.trim()) ?? 0,
      deliveryCut: num.tryParse(_deliveryCut.text.trim()) ?? 0,
    );
  }

  OrderPricingSnapshot? _previewSnapshot() {
    final item = num.tryParse(_previewItemPrice.text.trim());
    if (item == null || item <= 0) return null;
    return computeOrderPricing(
      itemPrice: item,
      settings: _draftFromFields(),
    );
  }

  Future<void> _save() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final draft = _draftFromFields();
    final errors = validateGlobalSettings(draft);
    if (errors.isNotEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errors.join('\n'))),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await _repo.saveGlobal(
        next: draft,
        previous: _loadedBaseline,
        adminUid: user.uid,
      );
      _loadedBaseline = draft;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings saved.')),
      );
    } on SettingsValidationException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.errors.join('\n'))),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Save failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _commission.dispose();
    _deliveryFee.dispose();
    _deliveryCut.dispose();
    _previewItemPrice.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_loadError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_loadError!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton(onPressed: _load, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    final preview = _previewSnapshot();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_loadedBaseline == null)
                Text(
                  'No document yet — defaults are shown. Saving creates '
                  '`settings/global`.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              const SizedBox(height: 16),
              TextField(
                controller: _commission,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
                decoration: const InputDecoration(
                  labelText: 'Commission value',
                  border: OutlineInputBorder(),
                  helperText: 'Fixed LKR or percent (0–100) when type is %',
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Commission type',
                  border: OutlineInputBorder(),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<CommissionType>(
                    isExpanded: true,
                    value: _commissionType,
                    items: CommissionType.values
                        .map(
                          (e) => DropdownMenuItem(
                            value: e,
                            child: Text(
                              e == CommissionType.fixed ? 'Fixed' : 'Percentage',
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() => _commissionType = v);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _deliveryFee,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
                decoration: const InputDecoration(
                  labelText: 'Delivery fee (LKR)',
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _deliveryCut,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
                decoration: const InputDecoration(
                  labelText: 'Delivery cut — admin share (LKR)',
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _previewItemPrice,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
                decoration: const InputDecoration(
                  labelText: 'Preview — item subtotal (LKR)',
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 20),
              Builder(
                builder: (context) {
                  final glass = mndGlassChromeEnabled;
                  final previewBody = Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Preview',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        if (preview == null)
                          const Text('Enter a valid preview item price.')
                        else ...[
                          Text(
                            'Customer pays: ${preview.totalAmount} LKR',
                          ),
                          Text(
                            'Admin earns: ${preview.adminEarning} LKR',
                          ),
                          Text(
                            'Rider earns: ${preview.riderEarning} LKR',
                          ),
                        ],
                      ],
                    ),
                  );
                  if (glass) {
                    return MndGlassPanel(
                      borderRadius: BorderRadius.circular(16),
                      blurSigma: 22,
                      fillAlpha: 0.42,
                      child: previewBody,
                    );
                  }
                  return Card(child: previewBody);
                },
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save settings'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
