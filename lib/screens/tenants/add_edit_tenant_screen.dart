import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/room.dart';
import '../../models/tenant.dart';
import '../../providers/room_provider.dart';
import '../../providers/tenant_provider.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_button.dart';

class AddEditTenantScreen extends ConsumerStatefulWidget {
  final String buildingId;
  final Tenant? tenant;

  const AddEditTenantScreen({
    super.key,
    required this.buildingId,
    this.tenant,
  });

  @override
  ConsumerState<AddEditTenantScreen> createState() =>
      _AddEditTenantScreenState();
}

class _AddEditTenantScreenState extends ConsumerState<AddEditTenantScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  bool get _isEditing => widget.tenant != null;

  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _idProofTypeController;
  late final TextEditingController _idProofNumberController;
  late final TextEditingController _emergencyContactController;
  late final TextEditingController _permanentAddressController;

  Room? _selectedRoom;
  DateTime _joinDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    final t = widget.tenant;
    _nameController = TextEditingController(text: t?.name ?? '');
    _phoneController = TextEditingController(text: t?.phone ?? '');
    _emailController = TextEditingController(text: t?.email ?? '');
    _idProofTypeController = TextEditingController(text: t?.idProofType ?? '');
    _idProofNumberController =
        TextEditingController(text: t?.idProofNumber ?? '');
    _emergencyContactController =
        TextEditingController(text: t?.emergencyContact ?? '');
    _permanentAddressController =
        TextEditingController(text: t?.permanentAddress ?? '');
    if (t != null) {
      _joinDate = t.joinDate;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _idProofTypeController.dispose();
    _idProofNumberController.dispose();
    _emergencyContactController.dispose();
    _permanentAddressController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _joinDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _joinDate = picked;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_isEditing && _selectedRoom == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a room')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final tenant = Tenant(
        tenantId: widget.tenant?.tenantId ?? '',
        roomId: widget.tenant?.roomId ?? _selectedRoom!.roomId,
        roomNumber: widget.tenant?.roomNumber ?? _selectedRoom!.roomNumber,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        joinDate: _joinDate,
        idProofType: _idProofTypeController.text.trim(),
        idProofNumber: _idProofNumberController.text.trim(),
        emergencyContact: _emergencyContactController.text.trim(),
        permanentAddress: _permanentAddressController.text.trim(),
        isActive: widget.tenant?.isActive ?? true,
      );

      final repo = ref.read(tenantRepositoryProvider(widget.buildingId));

      if (_isEditing) {
        await repo.updateTenant(tenant);
      } else {
        await repo.addTenant(tenant);
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final roomsAsync = ref.watch(roomsStreamProvider(widget.buildingId));

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Tenant' : 'Add Tenant'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Room Dropdown (only for new tenants)
              if (!_isEditing)
                roomsAsync.when(
                  data: (rooms) {
                    final availableRooms =
                        rooms.where((r) => !r.isFull).toList();
                    return DropdownButtonFormField<Room>(
                      value: _selectedRoom,
                      decoration: const InputDecoration(
                        labelText: 'Select Room',
                        prefixIcon: Icon(Icons.meeting_room),
                        border: OutlineInputBorder(),
                      ),
                      items: availableRooms.map((room) {
                        return DropdownMenuItem<Room>(
                          value: room,
                          child: Text(
                              'Room ${room.roomNumber} (Floor ${room.floor}, ${room.occupantCount}/${room.capacity})'),
                        );
                      }).toList(),
                      onChanged: (room) {
                        setState(() {
                          _selectedRoom = room;
                        });
                      },
                      validator: (value) =>
                          value == null ? 'Please select a room' : null,
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Text('Error loading rooms: $error'),
                ),
              if (!_isEditing) const SizedBox(height: 16),

              CustomTextField(
                controller: _nameController,
                label: 'Full Name',
                prefixIcon: Icons.person,
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter name'
                    : null,
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _phoneController,
                label: 'Phone Number',
                prefixIcon: Icons.phone,
                keyboardType: TextInputType.phone,
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter phone number'
                    : null,
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _emailController,
                label: 'Email (optional)',
                prefixIcon: Icons.email,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              // Join Date
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Join Date',
                    prefixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    '${_joinDate.day}/${_joinDate.month}/${_joinDate.year}',
                  ),
                ),
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _idProofTypeController,
                label: 'ID Proof Type (optional)',
                prefixIcon: Icons.badge,
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _idProofNumberController,
                label: 'ID Proof Number (optional)',
                prefixIcon: Icons.numbers,
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _emergencyContactController,
                label: 'Emergency Contact (optional)',
                prefixIcon: Icons.emergency,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _permanentAddressController,
                label: 'Permanent Address (optional)',
                prefixIcon: Icons.home,
                maxLines: 2,
              ),
              const SizedBox(height: 24),

              LoadingButton(
                label: _isEditing ? 'Update Tenant' : 'Add Tenant',
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
