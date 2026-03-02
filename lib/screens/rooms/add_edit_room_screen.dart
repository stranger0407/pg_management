import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/room.dart';
import '../../providers/room_provider.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_button.dart';

class AddEditRoomScreen extends ConsumerStatefulWidget {
  final String buildingId;
  final Room? room;

  const AddEditRoomScreen({super.key, required this.buildingId, this.room});

  @override
  ConsumerState<AddEditRoomScreen> createState() => _AddEditRoomScreenState();
}

class _AddEditRoomScreenState extends ConsumerState<AddEditRoomScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _numberController;
  late final TextEditingController _floorController;
  late final TextEditingController _rentController;
  late final TextEditingController _capacityController;
  bool _isLoading = false;

  bool get _isEditing => widget.room != null;

  @override
  void initState() {
    super.initState();
    _numberController =
        TextEditingController(text: widget.room?.roomNumber ?? '');
    _floorController =
        TextEditingController(text: widget.room?.floor.toString() ?? '0');
    _rentController =
        TextEditingController(text: widget.room?.rentAmount.toString() ?? '');
    _capacityController =
        TextEditingController(text: widget.room?.capacity.toString() ?? '1');
  }

  @override
  void dispose() {
    _numberController.dispose();
    _floorController.dispose();
    _rentController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final repo = ref.read(roomRepositoryProvider(widget.buildingId));
      final room = Room(
        roomId: widget.room?.roomId ?? '',
        roomNumber: _numberController.text.trim(),
        floor: int.tryParse(_floorController.text) ?? 0,
        rentAmount: double.tryParse(_rentController.text) ?? 0.0,
        isOccupied: widget.room?.isOccupied ?? false,
        capacity: int.tryParse(_capacityController.text) ?? 1,
        createdAt: widget.room?.createdAt ?? DateTime.now(),
      );

      if (_isEditing) {
        await repo.updateRoom(room);
      } else {
        await repo.addRoom(room);
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
        title: Text(_isEditing ? 'Edit Room' : 'Add Room'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextField(
                controller: _numberController,
                label: 'Room Number *',
                prefixIcon: Icons.meeting_room,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Room number is required' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _floorController,
                label: 'Floor',
                prefixIcon: Icons.layers,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _rentController,
                label: 'Monthly Rent (\u20B9) *',
                prefixIcon: Icons.currency_rupee,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Rent amount is required';
                  if (double.tryParse(v) == null) return 'Enter a valid amount';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _capacityController,
                label: 'Capacity (beds/persons)',
                prefixIcon: Icons.people,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 32),
              LoadingButton(
                label: _isEditing ? 'Update Room' : 'Add Room',
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
