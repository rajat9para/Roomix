import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:roomix/providers/auth_provider.dart';
import 'package:roomix/constants/app_colors.dart';
import 'package:roomix/widgets/custom_text_field.dart';
import 'package:roomix/widgets/custom_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _collegeController = TextEditingController();
  final _phoneController = TextEditingController();
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    final user = auth.currentUser;
    _nameController.text = user?.name ?? '';
    _bioController.text = user?.bio ?? '';
    _collegeController.text = user?.college ?? '';
    _phoneController.text = user?.phone ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _collegeController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_imageFile == null) return;
    final auth = context.read<AuthProvider>();
    setState(() => _isLoading = true);
    try {
      await auth.uploadProfilePicture(_imageFile!.path);
      setState(() => _imageFile = null);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile picture updated'),
            backgroundColor: Colors.green,
          ),
        );
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

  Future<void> _saveProfile() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name cannot be empty')),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    setState(() => _isLoading = true);
    try {
      await auth.updateProfile({
        'name': _nameController.text.trim(),
        'bio': _bioController.text.trim(),
        'college': _collegeController.text.trim(),
        'phone': _phoneController.text.trim(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
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
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text(
          'My Profile',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.backgroundGradient,
          ),
          child: Column(
            children: [
              // Profile Picture Section
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _isLoading ? null : _pickImage,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF8B5CF6).withOpacity(0.5),
                                width: 2,
                              ),
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFF8B5CF6).withOpacity(0.2),
                                  const Color(0xFFEC4899).withOpacity(0.2),
                                ],
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 55,
                              backgroundImage: _imageFile != null
                                  ? FileImage(_imageFile!) as ImageProvider
                                  : (user?.profilePicture != null && user!.profilePicture!.isNotEmpty)
                                      ? NetworkImage(user.profilePicture!)
                                      : null,
                              child: (_imageFile == null && (user?.profilePicture == null || user!.profilePicture!.isEmpty))
                                  ? Icon(
                                      Icons.person,
                                      size: 50,
                                      color: Colors.white.withOpacity(0.6),
                                    )
                                  : null,
                            ),
                          ),
                          if (!_isLoading)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                                  ),
                                  border: Border.all(
                                    color: const Color(0xFF0F172A),
                                    width: 2,
                                  ),
                                ),
                                padding: const EdgeInsets.all(8),
                                child: const Icon(
                                  Icons.camera_alt,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      user?.email ?? '',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),

              // Update Picture Button
              if (_imageFile != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: CustomButton(
                    text: 'Update Picture',
                    onPressed: _isLoading ? null : _uploadImage,
                    style: ButtonStyle.gradient,
                    isLoading: _isLoading,
                  ),
                ),

              // Form Section
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name Field
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Full Name',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 8),
                          CustomTextField(
                            controller: _nameController,
                            hintText: 'Enter your full name',
                            prefixIcon: Icons.person,
                            style: CustomTextFieldStyle.glass,
                            enabled: !_isLoading,
                          ),
                        ],
                      ),
                    ),

                    // Email Field (Read-only)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Email',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 8),
                          CustomTextField(
                            controller: TextEditingController(text: user?.email ?? ''),
                            hintText: 'Your email',
                            prefixIcon: Icons.email,
                            style: CustomTextFieldStyle.glass,
                            enabled: false,
                          ),
                        ],
                      ),
                    ),

                    // Phone Field
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Phone Number',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 8),
                          CustomTextField(
                            controller: _phoneController,
                            hintText: 'Enter your phone number',
                            prefixIcon: Icons.phone,
                            style: CustomTextFieldStyle.glass,
                            enabled: !_isLoading,
                            keyboardType: TextInputType.phone,
                          ),
                        ],
                      ),
                    ),

                    // College Field
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'College',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 8),
                          CustomTextField(
                            controller: _collegeController,
                            hintText: 'Your college name',
                            prefixIcon: Icons.school,
                            style: CustomTextFieldStyle.glass,
                            enabled: !_isLoading,
                          ),
                        ],
                      ),
                    ),

                    // Bio Field
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bio',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 8),
                          CustomTextField(
                            controller: _bioController,
                            hintText: 'Tell us about yourself...',
                            prefixIcon: Icons.info,
                            maxLines: 4,
                            style: CustomTextFieldStyle.glass,
                            enabled: !_isLoading,
                          ),
                        ],
                      ),
                    ),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: CustomButton(
                        text: 'Save Changes',
                        onPressed: _isLoading ? null : _saveProfile,
                        style: ButtonStyle.gradient,
                        isLoading: _isLoading,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

