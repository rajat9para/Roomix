import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:roomix/constants/app_colors.dart';
import 'package:roomix/models/university_model.dart';
import 'package:roomix/providers/auth_provider.dart';
import 'package:roomix/providers/user_preferences_provider.dart';
import 'package:roomix/services/map_service.dart';
import 'package:roomix/utils/smooth_navigation.dart';
import 'package:roomix/screens/home/home_screen.dart';

class StudentOnboardingScreen extends StatefulWidget {
  final UniversityModel university;

  const StudentOnboardingScreen({
    super.key,
    required this.university,
  });

  @override
  State<StudentOnboardingScreen> createState() => _StudentOnboardingScreenState();
}

class _StudentOnboardingScreenState extends State<StudentOnboardingScreen>
    with SingleTickerProviderStateMixin {
  late TextEditingController _nameController;
  late TextEditingController _courseController;
  late TextEditingController _collegeController;
  late TextEditingController _contactController;
  late TextEditingController _locationController;
  String _selectedYear = '1st Year';
  bool _isSaving = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<String> _yearOptions = [
    '1st Year',
    '2nd Year',
    '3rd Year',
    '4th Year',
    'PG / Masters',
  ];

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    _nameController = TextEditingController(text: auth.currentUser?.name ?? '');
    _courseController = TextEditingController();
    _collegeController = TextEditingController(text: widget.university.name);
    _contactController = TextEditingController();
    _locationController = TextEditingController(text: widget.university.address);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _courseController.dispose();
    _collegeController.dispose();
    _contactController.dispose();
    _locationController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _saveOnboarding() async {
    if (_nameController.text.trim().isEmpty ||
        _courseController.text.trim().isEmpty ||
        _collegeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final prefs = context.read<UserPreferencesProvider>();
      final auth = context.read<AuthProvider>();

      // Geocode location (fallback to university coordinates)
      double latitude = widget.university.location.latitude;
      double longitude = widget.university.location.longitude;
      final locationText = _locationController.text.trim();

      if (locationText.isNotEmpty) {
        final coords = await MapService.getCoordinatesFromAddress(locationText);
        if (coords != null) {
          latitude = coords['latitude'] ?? latitude;
          longitude = coords['longitude'] ?? longitude;
        }
      }

      await prefs.saveCampusLocation(
        latitude: latitude,
        longitude: longitude,
        address: locationText.isNotEmpty ? locationText : widget.university.address,
      );

      await prefs.saveStudentProfile(
        course: _courseController.text.trim(),
        year: _selectedYear,
        college: _collegeController.text.trim(),
        contact: _contactController.text.trim().isEmpty
            ? null
            : _contactController.text.trim(),
      );

      await auth.updateProfile({
        'name': _nameController.text.trim(),
        'selectedUniversity': widget.university.id,
        'course': _courseController.text.trim(),
        'year': _selectedYear,
        'collegeName': _collegeController.text.trim(),
        'contactNumber': _contactController.text.trim(),
        'campusLatitude': latitude,
        'campusLongitude': longitude,
        'campusAddress': locationText.isNotEmpty ? locationText : widget.university.address,
        'isOnboardingComplete': true,
      });

      await prefs.completeOnboarding();

      if (mounted) {
        SmoothNavigation.pushReplacement(context, const HomeScreen());
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save onboarding: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildGlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFieldLabel('Full Name'),
                        _buildInputField(
                          controller: _nameController,
                          hint: 'Your name',
                          icon: Icons.person,
                        ),
                        const SizedBox(height: 16),
                        _buildFieldLabel('Course'),
                        _buildInputField(
                          controller: _courseController,
                          hint: 'e.g., B.Tech, BCA',
                          icon: Icons.book_rounded,
                        ),
                        const SizedBox(height: 16),
                        _buildFieldLabel('Year'),
                        _buildDropdown(),
                        const SizedBox(height: 16),
                        _buildFieldLabel('College Name'),
                        _buildInputField(
                          controller: _collegeController,
                          hint: 'Your college',
                          icon: Icons.school_rounded,
                        ),
                        const SizedBox(height: 16),
                        _buildFieldLabel('Contact Number (optional)'),
                        _buildInputField(
                          controller: _contactController,
                          hint: 'Phone number',
                          icon: Icons.call_rounded,
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 16),
                        _buildFieldLabel('Campus Area / Location'),
                        _buildInputField(
                          controller: _locationController,
                          hint: 'Campus or nearby area',
                          icon: Icons.location_on_rounded,
                        ),
                        const SizedBox(height: 24),
                        _buildSaveButton(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Complete Your Profile',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'We use this to personalize your campus map and matches.',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.4)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textDark,
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.primary),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedYear,
          isExpanded: true,
          items: _yearOptions.map((year) {
            return DropdownMenuItem(
              value: year,
              child: Text(year),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => _selectedYear = value);
            }
          },
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveOnboarding,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isSaving
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Finish Setup',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}
