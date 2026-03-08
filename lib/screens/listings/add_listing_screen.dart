import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/listing_model.dart';
import '../../providers/providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../directory/directory_screen.dart';

class AddListingScreen extends ConsumerStatefulWidget {
  final ListingModel? existingListing;
  const AddListingScreen({super.key, this.existingListing});

  @override
  ConsumerState<AddListingScreen> createState() => _AddListingScreenState();
}

class _AddListingScreenState extends ConsumerState<AddListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _contactController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _latController = TextEditingController();
  final _lngController = TextEditingController();
  String _selectedCategory = kCategories[1];
  bool _isLoading = false;

  bool get _isEditing => widget.existingListing != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final l = widget.existingListing!;
      _nameController.text = l.name;
      _addressController.text = l.address;
      _contactController.text = l.contact;
      _descriptionController.text = l.description;
      _latController.text = l.latitude.toString();
      _lngController.text = l.longitude.toString();
      _selectedCategory = l.category;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _contactController.dispose();
    _descriptionController.dispose();
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final authState = ref.read(authStateProvider).value;
    if (authState == null) return;

    try {
      final listing = ListingModel(
        id: _isEditing ? widget.existingListing!.id : '',
        name: _nameController.text.trim(),
        category: _selectedCategory,
        address: _addressController.text.trim(),
        contact: _contactController.text.trim(),
        description: _descriptionController.text.trim(),
        latitude: double.tryParse(_latController.text) ?? -1.9441,
        longitude: double.tryParse(_lngController.text) ?? 30.0619,
        createdBy: authState.uid,
        createdAt: _isEditing
            ? widget.existingListing!.createdAt
            : DateTime.now(),
      );

      if (_isEditing) {
        await ref.read(listingServiceProvider).updateListing(listing);
      } else {
        await ref.read(listingServiceProvider).createListing(listing);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing ? '✅ Listing updated!' : '✅ Listing saved to Firestore!',
              style: GoogleFonts.dmSans(),
            ),
            backgroundColor: AppTheme.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving listing: $e',
                style: GoogleFonts.dmSans()),
            backgroundColor: AppTheme.red,
          ),
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
        title: Text(
          _isEditing ? 'Edit Listing' : 'Add New Listing',
          style: GoogleFonts.syne(fontWeight: FontWeight.w700),
        ),
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppTheme.navyCard,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.arrow_back, size: 18),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppTextField(
                  label: 'Place / Service Name',
                  hint: 'e.g. Kimironko Café',
                  controller: _nameController,
                  validator: (v) => v == null || v.isEmpty ? 'Name is required' : null,
                ),

                // Category Dropdown
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CATEGORY',
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.muted,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.navyCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.navyBorder),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedCategory,
                          dropdownColor: AppTheme.navyCard,
                          style: GoogleFonts.dmSans(
                              color: AppTheme.white, fontSize: 14),
                          isExpanded: true,
                          items: kCategories
                              .where((c) => c != 'All')
                              .map((c) => DropdownMenuItem(
                                    value: c,
                                    child: Text(c),
                                  ))
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _selectedCategory = v!),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
                ),

                AppTextField(
                  label: 'Address',
                  hint: 'Sector, District, Kigali',
                  controller: _addressController,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Address is required' : null,
                ),

                AppTextField(
                  label: 'Contact Number',
                  hint: '+250 7XX XXX XXX',
                  controller: _contactController,
                  keyboardType: TextInputType.phone,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Contact is required' : null,
                ),

                AppTextField(
                  label: 'Description',
                  hint: 'Brief description of the place…',
                  controller: _descriptionController,
                  maxLines: 3,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Description is required' : null,
                ),

                // Coordinates
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        label: 'Latitude',
                        hint: '-1.9441',
                        controller: _latController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true, signed: true),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Required';
                          if (double.tryParse(v) == null) return 'Invalid';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppTextField(
                        label: 'Longitude',
                        hint: '30.0619',
                        controller: _lngController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true, signed: true),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Required';
                          if (double.tryParse(v) == null) return 'Invalid';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _save,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20, width: 20,
                            child: CircularProgressIndicator(
                                color: AppTheme.navy, strokeWidth: 2))
                        : Text(_isEditing ? '💾  Update Listing' : '💾  Save Listing'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
