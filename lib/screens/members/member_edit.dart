import 'dart:convert';
import 'dart:io' show File;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:societas/models/member.dart';
import 'package:societas/providers/member_provider.dart';

class MemberEditPage extends StatefulWidget {
  final Member member;

  const MemberEditPage({super.key, required this.member});

  @override
  State<MemberEditPage> createState() => _MemberEditPageState();
}

class _MemberEditPageState extends State<MemberEditPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;
  XFile? _selectedImage;
  String? _imageData; // Base64 or network URL

  // Controllers for text fields
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _positionController;
  late TextEditingController _addressController;
  late TextEditingController _dobController;
  late TextEditingController _occupationController;
  late TextEditingController _skillsController;
  late TextEditingController _membershipTypeController;
  late TextEditingController _emergencyNameController;
  late TextEditingController _emergencyPhoneController;
  late TextEditingController _emergencyRelationshipController;
  late TextEditingController _publicprofilepictureurlController;

  // Dropdown values
  late MemberStatus _selectedStatus;
  late String _selectedGender;

  final List<String> _genderOptions = [
    'Male',
    'Female',
    'Other',
    'Prefer not to say',
  ];

  @override
  void initState() {
    super.initState();

    _imageData = widget.member.profilepicture;

    // Split full name into first and last names
    final nameParts = widget.member.membername.split(' ');
    final firstName = nameParts.isNotEmpty ? nameParts.first : '';
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

    _selectedGender = _genderOptions.contains(widget.member.gender)
        ? widget.member.gender!
        : _genderOptions.first;

    _firstNameController = TextEditingController(text: firstName);
    _lastNameController = TextEditingController(text: lastName);
    _emailController = TextEditingController(text: widget.member.email ?? '');
    _phoneController = TextEditingController(text: widget.member.phone ?? '');
    _positionController = TextEditingController(
      text: widget.member.position ?? '',
    );
    _addressController = TextEditingController(
      text: widget.member.memberaddress ?? '',
    );
    _dobController = TextEditingController(
      text: widget.member.dateofbirth != null
          ? DateFormat('yyyy-MM-dd').format(widget.member.dateofbirth!)
          : '',
    );
    _occupationController = TextEditingController(
      text: widget.member.occupation ?? '',
    );
    _skillsController = TextEditingController(
      text: widget.member.otherskills ?? '',
    );
    _selectedStatus = widget.member.status;
    _membershipTypeController = TextEditingController(
      text: widget.member.membershiptype,
    );
    _emergencyNameController = TextEditingController(
      text: widget.member.emergencycontactname ?? '',
    );
    _emergencyPhoneController = TextEditingController(
      text: widget.member.emergencycontactphone ?? '',
    );
    _emergencyRelationshipController = TextEditingController(
      text: widget.member.emergencycontactrelationship ?? '',
    );
    _publicprofilepictureurlController = TextEditingController(
      text: widget.member.publicprofilepictureurl ?? 'avatar.png',
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _positionController.dispose();
    _addressController.dispose();
    _dobController.dispose();
    _occupationController.dispose();
    _skillsController.dispose();
    _membershipTypeController.dispose();
    _emergencyNameController.dispose();
    _emergencyPhoneController.dispose();
    _emergencyRelationshipController.dispose();
    _publicprofilepictureurlController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 90,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = pickedFile;
        });
      }
    } catch (e) {
      _showErrorSnackBar('Error picking image: ${e.toString()}');
    }
  }

  Future<String?> _prepareBase64Image() async {
    if (_selectedImage == null) return null;

    try {
      // Read the original image bytes
      final bytes = await _selectedImage!.readAsBytes();

      // Decode the image
      final decoded = img.decodeImage(bytes);
      if (decoded == null) return null;

      // Resize the image to 300x300 while maintaining aspect ratio
      final resized = img.copyResize(
        decoded,
        width: 300,
        height: 300,
        maintainAspect: true,
      );

      // Encode the resized image as JPEG with good quality
      final encodedJpg = img.encodeJpg(resized, quality: 85);

      // Create the full base64 URL
      final base64String = base64Encode(encodedJpg);
      return 'data:image/jpeg;base64,$base64String';
    } catch (e) {
      _showErrorSnackBar('Error processing image: ${e.toString()}');
      return null;
    }
  }

  Future<void> _updateMember() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      DateTime? parsedDate;
      if (_dobController.text.isNotEmpty) {
        parsedDate = DateTime.tryParse(_dobController.text);
        if (parsedDate == null) {
          _showErrorSnackBar('Invalid date format. Please use YYYY-MM-DD');
          return;
        }
      }

      String? base64Image = await _prepareBase64Image();

      final updatedMember = widget.member.copyWith(
        membername:
            '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}',
        firstname: _firstNameController.text.trim(),
        lastname: _lastNameController.text.trim(),
        gender: _selectedGender,
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        position: _positionController.text.trim().isEmpty
            ? null
            : _positionController.text.trim(),
        memberaddress: _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
        dateofbirth: parsedDate,
        occupation: _occupationController.text.trim().isEmpty
            ? null
            : _occupationController.text.trim(),
        otherskills: _skillsController.text.trim().isEmpty
            ? null
            : _skillsController.text.trim(),
        status: _selectedStatus,
        membershiptype: _membershipTypeController.text.trim(),
        emergencycontactname: _emergencyNameController.text.trim().isEmpty
            ? null
            : _emergencyNameController.text.trim(),
        emergencycontactphone: _emergencyPhoneController.text.trim().isEmpty
            ? null
            : _emergencyPhoneController.text.trim(),
        emergencycontactrelationship:
            _emergencyRelationshipController.text.trim().isEmpty
            ? null
            : _emergencyRelationshipController.text.trim(),
        profilepicture: base64Image ?? widget.member.profilepicture,
        publicprofilepictureurl: _publicprofilepictureurlController.text.trim(),
      );

      await Provider.of<MemberProvider>(
        context,
        listen: false,
      ).updateMember(updatedMember);

      _showSuccessSnackBar('Member updated successfully');
      Navigator.pop(context);
    } catch (e) {
      _showErrorSnackBar('Failed to update member: ${e.toString()}');
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: widget.member.dateofbirth ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _dobController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Widget _buildProfileImageSection() {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey[300],
                child: _buildImageWidget(),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: _pickImage,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: _pickImage,
            icon: const Icon(Icons.upload),
            label: const Text('Change Photo'),
          ),
        ],
      ),
    );
  }

  Widget _buildImageWidget() {
    if (_selectedImage != null) {
      return ClipOval(child: _buildSelectedImageWidget());
    }

    if (_imageData != null && _imageData!.isNotEmpty) {
      // Check if it's a URL or base64
      if (_imageData!.startsWith('http')) {
        return ClipOval(
          child: Image.network(
            _imageData!,
            width: 120,
            height: 120,
            fit: BoxFit.cover,
          ),
        );
      } else {
        try {
          final bytes = base64Decode(_imageData!);
          return ClipOval(
            child: Image.memory(
              bytes,
              width: 120,
              height: 120,
              fit: BoxFit.cover,
            ),
          );
        } catch (_) {}
      }
    }

    return const Icon(Icons.person, size: 60, color: Colors.grey);
  }

  Widget _buildSelectedImageWidget() {
    if (kIsWeb) {
      return Image.network(
        _selectedImage!.path,
        width: 300,
        height: 300,
        fit: BoxFit.cover,
      );
    } else {
      return Image.file(
        File(_selectedImage!.path),
        width: 300,
        height: 300,
        fit: BoxFit.cover,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Member'), elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildProfileImageSection(),
              const SizedBox(height: 24),

              const Text(
                'Basic Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _firstNameController,
                      decoration: const InputDecoration(
                        labelText: 'First Name*',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _lastNameController,
                      decoration: const InputDecoration(
                        labelText: 'Last Name*',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _selectedGender,
                decoration: const InputDecoration(
                  labelText: 'Gender*',
                  border: OutlineInputBorder(),
                ),
                items: _genderOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() => _selectedGender = newValue);
                  }
                },
                validator: (value) => value == null ? 'Required' : null,
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    if (!RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    ).hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _positionController,
                decoration: const InputDecoration(
                  labelText: 'Position',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _dobController,
                decoration: InputDecoration(
                  labelText: 'Date of Birth',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context),
                  ),
                ),
                readOnly: true,
                onTap: () => _selectDate(context),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _publicprofilepictureurlController,
                decoration: const InputDecoration(
                  labelText: 'Profile Picture URL',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey,
                ),
                readOnly: true,
                enabled: false,
              ),

              const SizedBox(height: 32),
              const Text(
                'Emergency Contact',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _emergencyNameController,
                decoration: const InputDecoration(
                  labelText: 'Contact Name',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _emergencyPhoneController,
                decoration: const InputDecoration(
                  labelText: 'Contact Phone',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _emergencyRelationshipController,
                decoration: const InputDecoration(
                  labelText: 'Relationship',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 40),

              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _updateMember,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Update Member',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

/* import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:societas/models/member.dart';
import 'package:societas/providers/member_provider.dart';
import 'package:societas/services/cloudinary_service.dart';
import 'dart:io' show File;

// Platform-specific imports
import 'dart:io' if (dart.library.html) 'dart:html' as html;

class MemberEditPage extends StatefulWidget {
  final Member member;

  const MemberEditPage({super.key, required this.member});

  @override
  State<MemberEditPage> createState() => _MemberEditPageState();
}

class _MemberEditPageState extends State<MemberEditPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;
  XFile? _selectedImage;
  String? _imageUrl;
  String? _previousImagePublicId;
  bool _isUploadingImage = false;
  bool _imageChanged = false;

  // Controllers for text fields
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _positionController;
  late TextEditingController _addressController;
  late TextEditingController _dobController;
  late TextEditingController _occupationController;
  late TextEditingController _skillsController;
  late TextEditingController _membershipTypeController;
  late TextEditingController _emergencyNameController;
  late TextEditingController _emergencyPhoneController;
  late TextEditingController _emergencyRelationshipController;

  // Dropdown values
  late MemberStatus _selectedStatus;
  late String _selectedGender;

  final List<String> _genderOptions = [
    'Male',
    'Female',
    'Other',
    'Prefer not to say',
  ];

  @override
  void initState() {
    super.initState();
    // Initialize with existing image if available
    _imageUrl = widget.member.profilepicture;
    _previousImagePublicId = _extractPublicIdFromUrl(
      widget.member.profilepicture,
    );

    // Split full name into first and last names
    final nameParts = widget.member.membername.split(' ');
    final firstName = nameParts.isNotEmpty ? nameParts.first : '';
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

    // Initialize gender with proper validation
    _selectedGender = _genderOptions.contains(widget.member.gender)
        ? widget.member.gender!
        : _genderOptions.first;

    // Initialize controllers with member data
    _firstNameController = TextEditingController(text: firstName);
    _lastNameController = TextEditingController(text: lastName);
    _emailController = TextEditingController(text: widget.member.email ?? '');
    _phoneController = TextEditingController(text: widget.member.phone ?? '');
    _positionController = TextEditingController(
      text: widget.member.position ?? '',
    );
    _addressController = TextEditingController(
      text: widget.member.memberaddress ?? '',
    );
    _dobController = TextEditingController(
      text: widget.member.dateofbirth != null
          ? DateFormat('yyyy-MM-dd').format(widget.member.dateofbirth!)
          : '',
    );
    _occupationController = TextEditingController(
      text: widget.member.occupation ?? '',
    );
    _skillsController = TextEditingController(
      text: widget.member.otherskills ?? '',
    );
    _selectedStatus = widget.member.status;
    _membershipTypeController = TextEditingController(
      text: widget.member.membershiptype,
    );
    _emergencyNameController = TextEditingController(
      text: widget.member.emergencycontactname ?? '',
    );
    _emergencyPhoneController = TextEditingController(
      text: widget.member.emergencycontactphone ?? '',
    );
    _emergencyRelationshipController = TextEditingController(
      text: widget.member.emergencycontactrelationship ?? '',
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _positionController.dispose();
    _addressController.dispose();
    _dobController.dispose();
    _occupationController.dispose();
    _skillsController.dispose();
    _membershipTypeController.dispose();
    _emergencyNameController.dispose();
    _emergencyPhoneController.dispose();
    _emergencyRelationshipController.dispose();
    super.dispose();
  }

  // Extract public ID from Cloudinary URL for deletion
  String? _extractPublicIdFromUrl(String? url) {
    if (url == null || url.isEmpty) return null;

    try {
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;

      // Find the upload segment and extract public ID
      final uploadIndex = pathSegments.indexOf('upload');
      if (uploadIndex != -1 && uploadIndex + 2 < pathSegments.length) {
        final publicIdWithExtension = pathSegments
            .sublist(uploadIndex + 2)
            .join('/');
        // Remove file extension
        final lastDotIndex = publicIdWithExtension.lastIndexOf('.');
        return lastDotIndex != -1
            ? publicIdWithExtension.substring(0, lastDotIndex)
            : publicIdWithExtension;
      }
    } catch (e) {
      print('Error extracting public ID: $e');
    }

    return null;
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = pickedFile;
          _imageChanged = true;
        });
        await _uploadImage();
      }
    } catch (e) {
      _showErrorSnackBar('Error picking image: ${e.toString()}');
    }
  }

  Future<void> _uploadImage() async {
    if (_selectedImage == null) return;

    setState(() => _isUploadingImage = true);

    try {
      // Generate a unique public ID for the image
      final publicId =
          'member_${widget.member.id}_${DateTime.now().millisecondsSinceEpoch}';

      // Upload new image with transformations
      final response = await CloudinaryService.uploadImage(
        _selectedImage!,
        publicId: publicId,
        folder: 'members/profiles',
        transformation: {
          'width': 400,
          'height': 400,
          'crop': 'fill',
          'gravity': 'face',
          'quality': 'auto',
          'format': 'auto',
        },
      );

      if (response != null && response['secure_url'] != null) {
        // If upload successful, delete previous image if it exists
        if (_previousImagePublicId != null &&
            _previousImagePublicId!.isNotEmpty) {
          await _deletePreviousImage(_previousImagePublicId!);
        }

        setState(() {
          _imageUrl = response['secure_url'];
          _previousImagePublicId = response['public_id'];
        });

        _showSuccessSnackBar('Profile image updated successfully');
      } else {
        _showErrorSnackBar('Failed to upload image');
      }
    } catch (e) {
      _showErrorSnackBar('Error uploading image: ${e.toString()}');
    } finally {
      setState(() => _isUploadingImage = false);
    }
  }

  Future<void> _deletePreviousImage(String publicId) async {
    try {
      await CloudinaryService.deleteImage(publicId);
      print('Previous image deleted successfully: $publicId');
    } catch (e) {
      print('Error deleting previous image: $e');
      // Don't show error to user as this is a background operation
    }
  }

  Future<void> _deleteCurrentImage() async {
    if (_imageUrl == null) return;

    final confirmed = await _showDeleteConfirmationDialog();
    if (!confirmed) return;

    setState(() => _isUploadingImage = true);

    try {
      if (_previousImagePublicId != null) {
        await CloudinaryService.deleteImage(_previousImagePublicId!);
      }

      setState(() {
        _imageUrl = null;
        _selectedImage = null;
        _previousImagePublicId = null;
        _imageChanged = true;
      });

      _showSuccessSnackBar('Profile image deleted successfully');
    } catch (e) {
      _showErrorSnackBar('Error deleting image: ${e.toString()}');
    } finally {
      setState(() => _isUploadingImage = false);
    }
  }

  Future<bool> _showDeleteConfirmationDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Delete Profile Image'),
              content: const Text(
                'Are you sure you want to delete the profile image?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('Delete'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  Future<void> _updateMember() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Parse date safely
      DateTime? parsedDate;
      if (_dobController.text.isNotEmpty) {
        parsedDate = DateTime.tryParse(_dobController.text);
        if (parsedDate == null) {
          _showErrorSnackBar('Invalid date format. Please use YYYY-MM-DD');
          return;
        }
      }

      final updatedMember = widget.member.copyWith(
        membername:
            '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}',
        firstname: _firstNameController.text.trim(),
        lastname: _lastNameController.text.trim(),
        gender: _selectedGender,
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        position: _positionController.text.trim().isEmpty
            ? null
            : _positionController.text.trim(),
        memberaddress: _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
        dateofbirth: parsedDate,
        occupation: _occupationController.text.trim().isEmpty
            ? null
            : _occupationController.text.trim(),
        otherskills: _skillsController.text.trim().isEmpty
            ? null
            : _skillsController.text.trim(),
        status: _selectedStatus,
        membershiptype: _membershipTypeController.text.trim(),
        emergencycontactname: _emergencyNameController.text.trim().isEmpty
            ? null
            : _emergencyNameController.text.trim(),
        emergencycontactphone: _emergencyPhoneController.text.trim().isEmpty
            ? null
            : _emergencyPhoneController.text.trim(),
        emergencycontactrelationship:
            _emergencyRelationshipController.text.trim().isEmpty
            ? null
            : _emergencyRelationshipController.text.trim(),
        profilepicture: _imageUrl,
      );

      await Provider.of<MemberProvider>(
        context,
        listen: false,
      ).updateMember(updatedMember);

      _showSuccessSnackBar('Member updated successfully');
      Navigator.pop(context);
    } catch (e) {
      _showErrorSnackBar('Failed to update member: ${e.toString()}');
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: widget.member.dateofbirth ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _dobController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Widget _buildProfileImageSection() {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey[300],
                child: _buildImageWidget(),
              ),
              if (_isUploadingImage)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(60),
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),
                ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: _isUploadingImage ? null : _pickImage,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton.icon(
                onPressed: _isUploadingImage ? null : _pickImage,
                icon: const Icon(Icons.upload),
                label: const Text('Change Photo'),
              ),
              if (_imageUrl != null) ...[
                const SizedBox(width: 16),
                TextButton.icon(
                  onPressed: _isUploadingImage ? null : _deleteCurrentImage,
                  icon: const Icon(Icons.delete, color: Colors.red),
                  label: const Text(
                    'Delete Photo',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImageWidget() {
    // Priority: Network image (uploaded) > Selected image > Default
    if (_imageUrl != null && _imageUrl!.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          _imageUrl!,
          width: 120,
          height: 120,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.person, size: 60, color: Colors.grey);
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            );
          },
        ),
      );
    } else if (_selectedImage != null) {
      return ClipOval(child: _buildSelectedImageWidget());
    } else {
      return const Icon(Icons.person, size: 60, color: Colors.grey);
    }
  }

  Widget _buildSelectedImageWidget() {
    if (kIsWeb) {
      // For web, use Image.network with the blob URL
      return Image.network(
        _selectedImage!.path,
        width: 120,
        height: 120,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.person, size: 60, color: Colors.grey);
        },
      );
    } else {
      // For mobile, use Image.file
      return Image.file(
        File(_selectedImage!.path),
        width: 120,
        height: 120,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.person, size: 60, color: Colors.grey);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Member'), elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Profile Image Section
              _buildProfileImageSection(),
              const SizedBox(height: 24),

              // Basic Information
              const Text(
                'Basic Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _firstNameController,
                      decoration: const InputDecoration(
                        labelText: 'First Name*',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _lastNameController,
                      decoration: const InputDecoration(
                        labelText: 'Last Name*',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _selectedGender,
                decoration: const InputDecoration(
                  labelText: 'Gender*',
                  border: OutlineInputBorder(),
                ),
                items: _genderOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedGender = newValue;
                    });
                  }
                },
                validator: (value) => value == null ? 'Required' : null,
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    if (!RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    ).hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _positionController,
                decoration: const InputDecoration(
                  labelText: 'Position',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _dobController,
                decoration: InputDecoration(
                  labelText: 'Date of Birth',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context),
                  ),
                ),
                readOnly: true,
                onTap: () => _selectDate(context),
              ),

              // Emergency Contact
              const SizedBox(height: 32),
              const Text(
                'Emergency Contact',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _emergencyNameController,
                decoration: const InputDecoration(
                  labelText: 'Contact Name',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _emergencyPhoneController,
                decoration: const InputDecoration(
                  labelText: 'Contact Phone',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _emergencyRelationshipController,
                decoration: const InputDecoration(
                  labelText: 'Relationship',
                  border: OutlineInputBorder(),
                ),
              ),

              // Submit Button
              const SizedBox(height: 40),

              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _updateMember,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Update Member',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
 */
