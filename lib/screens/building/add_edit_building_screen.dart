import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/building.dart';
import '../../providers/building_provider.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_button.dart';

class AddEditBuildingScreen extends ConsumerStatefulWidget {
  final Building? building;

  const AddEditBuildingScreen({super.key, this.building});

  @override
  ConsumerState<AddEditBuildingScreen> createState() =>
      _AddEditBuildingScreenState();
}

class _AddEditBuildingScreenState extends ConsumerState<AddEditBuildingScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _addressController;
  late final TextEditingController _phoneController;
  late final TextEditingController _fineController;
  late final TextEditingController _gstController;
  late final TextEditingController _dueDayController;
  bool _isLoading = false;

  bool get _isEditing => widget.building != null;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.building?.buildingName ?? '');
    _addressController =
        TextEditingController(text: widget.building?.address ?? '');
    _phoneController =
        TextEditingController(text: widget.building?.phone ?? '');
    _fineController = TextEditingController(
        text: widget.building?.finePerDay.toString() ?? '0');
    _gstController =
        TextEditingController(text: widget.building?.gstNumber ?? '');
    _dueDayController = TextEditingController(
        text: widget.building?.rentDueDay.toString() ?? '1');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _fineController.dispose();
    _gstController.dispose();
    _dueDayController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final repo = ref.read(buildingRepositoryProvider);
      final building = Building(
        buildingId: widget.building?.buildingId ?? '',
        buildingName: _nameController.text.trim(),
        address: _addressController.text.trim(),
        phone: _phoneController.text.trim(),
        finePerDay: double.tryParse(_fineController.text) ?? 0.0,
        gstNumber: _gstController.text.trim(),
        rentDueDay: int.tryParse(_dueDayController.text) ?? 1,
        createdAt: widget.building?.createdAt ?? DateTime.now(),
      );

      if (_isEditing) {
        await repo.updateBuilding(building);
      } else {
        await repo.addBuilding(building);
      }

      if (mounted) Navigator.of(context).pop();
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Building' : 'Add Building'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextField(
                controller: _nameController,
                label: 'Building Name *',
                prefixIcon: Icons.apartment,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Building name is required' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _addressController,
                label: 'Address *',
                prefixIcon: Icons.location_on,
                maxLines: 2,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Address is required' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _phoneController,
                label: 'Phone Number',
                prefixIcon: Icons.phone,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _dueDayController,
                label: 'Rent Due Day (1-28)',
                prefixIcon: Icons.calendar_today,
                keyboardType: TextInputType.number,
                validator: (v) {
                  final day = int.tryParse(v ?? '');
                  if (day == null || day < 1 || day > 28) {
                    return 'Enter a valid day (1-28)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _fineController,
                label: 'Late Fine Per Day (\u20B9)',
                prefixIcon: Icons.money,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _gstController,
                label: 'GST Number (Optional)',
                prefixIcon: Icons.receipt_long,
              ),
              const SizedBox(height: 32),
              LoadingButton(
                label: _isEditing ? 'Update Building' : 'Add Building',
                isLoading: _isLoading,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
