import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:roomix/providers/auth_provider.dart';
import 'package:roomix/providers/user_preferences_provider.dart';
import 'package:roomix/providers/map_provider.dart';
import 'package:roomix/screens/auth/login_screen.dart';
import 'package:roomix/screens/rooms/room_screen.dart';
import 'package:roomix/screens/mess/mess_screen.dart';
import 'package:roomix/screens/lost_found/lost_found_screen.dart';
import 'package:roomix/screens/events/events_screen.dart';
import 'package:roomix/screens/market/market_screen.dart';
import 'package:roomix/screens/utilities/utilities_screen.dart';
import 'package:roomix/screens/map/campus_map_screen.dart';
import 'package:roomix/screens/roommate_finder/roommate_finder_screen.dart';
import 'package:roomix/screens/profile/profile_screen.dart';
import 'package:roomix/screens/settings/settings_screen.dart';
import 'package:roomix/screens/admin/admin_dashboard_screen.dart';
import 'package:roomix/constants/app_colors.dart';
import 'package:roomix/widgets/module_card.dart';
import 'package:roomix/models/user_model.dart';
import 'package:roomix/utils/smooth_navigation.dart';
import 'package:roomix/services/map_service.dart';
import 'package:roomix/services/api_service.dart';
import 'package:roomix/models/map_marker_model.dart';
import 'package:roomix/models/room_model.dart';
import 'package:roomix/models/mess_model.dart';
import 'package:roomix/models/utility_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isLoading = true;
  bool _statsLoading = true;
  int _studentsCount = 0;
  int _pgOwnersCount = 0;
  int _messOwnersCount = 0;
  List<dynamic> _notifications = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
    
    // Simulate loading
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    });

    _loadDashboardStats();
    _loadNotifications();
    _applyCampusCenter();
    _loadMapMarkers();
  }

  Future<void> _applyCampusCenter() async {
    final prefs = context.read<UserPreferencesProvider>();
    if (prefs.isLoading) {
      await prefs.loadUserPreferences();
    }
    final lat = prefs.campusLat;
    final lng = prefs.campusLng;
    if (lat != null && lng != null) {
      context.read<MapProvider>().updateMapView(lat, lng, 15);
    }
  }

  Future<void> _loadDashboardStats() async {
    try {
      final stats = await ApiService.getDashboardStats();
      setState(() {
        _studentsCount = (stats['students'] as num?)?.toInt() ?? 0;
        _pgOwnersCount = (stats['pgOwners'] as num?)?.toInt() ?? 0;
        _messOwnersCount = (stats['messOwners'] as num?)?.toInt() ?? 0;
        _statsLoading = false;
      });
    } catch (e) {
      setState(() {
        _studentsCount = 0;
        _pgOwnersCount = 0;
        _messOwnersCount = 0;
        _statsLoading = false;
      });
    }
  }

  Future<void> _loadNotifications() async {
    try {
      final response = await ApiService.getNotifications();
      setState(() {
        _notifications = (response['notifications'] as List?) ?? [];
      });
    } catch (e) {
      setState(() {
        _notifications = [];
      });
    }
  }

  Future<void> _loadMapMarkers() async {
    try {
      final mapProvider = context.read<MapProvider>();
      mapProvider.clearMarkers();

      final roomsJson = await ApiService.getRooms();
      final roomMarkers = roomsJson
          .map((r) => RoomModel.fromJson(r))
          .where((r) => r.latitude != null && r.longitude != null)
          .map((room) => MapMarkerModel(
                id: room.id,
                title: room.title,
                description: room.location,
                latitude: room.latitude!,
                longitude: room.longitude!,
                category: MarkerCategory.pg,
                imageUrl: room.image,
                address: room.location,
                metadata: room,
              ))
          .toList();

      final messResponse = await ApiService.getMessMenu();
      final messJson = messResponse['mess'] as List? ?? [];
      final messMarkers = messJson
          .map((m) => MessModel.fromJson(m))
          .where((m) => m.latitude != null && m.longitude != null)
          .map((mess) => MapMarkerModel(
                id: mess.id,
                title: mess.name,
                description: mess.specialization ?? 'Mess',
                latitude: mess.latitude!,
                longitude: mess.longitude!,
                category: MarkerCategory.mess,
                imageUrl: mess.image,
                address: mess.address,
                metadata: mess,
              ))
          .toList();

      final prefs = context.read<UserPreferencesProvider>();
      List<UtilityModel> utilities = [];
      try {
        if (prefs.campusLat != null && prefs.campusLng != null) {
          utilities = await ApiService.getUtilitiesNearby(
            prefs.campusLat!,
            prefs.campusLng!,
            radiusMeters: 8000,
          );
        } else {
          utilities = await ApiService.getUtilities();
        }
      } catch (_) {}

      final utilityMarkers = utilities
          .map((utility) => MapMarkerModel(
                id: utility.id,
                title: utility.name,
                description: utility.category,
                latitude: utility.latitude,
                longitude: utility.longitude,
                category: MarkerCategory.utility,
                imageUrl: utility.image,
                address: utility.address,
                metadata: utility,
              ))
          .toList();

      mapProvider.addMarkers([...roomMarkers, ...messMarkers, ...utilityMarkers]);
    } catch (_) {}
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                // Custom App Bar
                _buildAppBar(authProvider, user),
                
                // Scrollable Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Welcome Section
                        _isLoading ? _buildWelcomeSectionShimmer() : _buildWelcomeSection(user),
                        const SizedBox(height: 24),

                        if (_notifications.isNotEmpty) ...[
                          _buildNotificationBanner(),
                          const SizedBox(height: 24),
                        ],

                        // Stats Cards
                        (_isLoading || _statsLoading) ? _buildStatsRowShimmer() : _buildStatsRow(),
                        const SizedBox(height: 28),

                        // Quick Access Title
                        _buildSectionTitle('Quick Access'),
                        const SizedBox(height: 16),

                        // Module Grid
                        _buildModuleGrid(context),
                        
                        const SizedBox(height: 28),

                        // Campus Map Preview
                        _buildSectionTitle('Nearby Places'),
                        const SizedBox(height: 16),
                        _buildCampusMapPreview(context),
                        
                        const SizedBox(height: 28),
                        
                        // Recent Activity Section
                        _buildSectionTitle('Your Activity'),
                        const SizedBox(height: 16),
                        _isLoading ? _buildActivityCardShimmer() : _buildActivityCard(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(AuthProvider authProvider, UserModel? user) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo and Title with Gradient
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8B5CF6).withOpacity(0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/images/roomix_logo.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.home_work_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Roomix',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          
          // Profile and Logout
          Row(
            children: [
              // User Avatar
              GestureDetector(
                onTap: () => _showProfileMenu(context, authProvider),
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: AppColors.secondaryGradient,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFF59E0B).withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: user?.name != null
                      ? Center(
                          child: Text(
                            user!.name.substring(0, 1).toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        )
                      : const Icon(Icons.person, color: Colors.white, size: 24),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showProfileMenu(BuildContext context, AuthProvider authProvider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                
                // User Info
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          authProvider.currentUser?.name.substring(0, 1).toUpperCase() ?? 'U',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            authProvider.currentUser?.name ?? 'User',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                          Text(
                            authProvider.currentUser?.email ?? '',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              authProvider.currentUser?.role.toUpperCase() ?? 'STUDENT',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                if (authProvider.currentUser?.role == 'admin') ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
                        );
                      },
                      icon: const Icon(Icons.admin_panel_settings, size: 20),
                      label: const Text('Admin Dashboard'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                
                // Profile & Settings Buttons
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ProfileScreen()),
                      );
                    },
                    icon: const Icon(Icons.person_outline, size: 20),
                    label: const Text('View Profile'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const SettingsScreen()),
                      );
                    },
                    icon: const Icon(Icons.settings_outlined, size: 20),
                    label: const Text('Settings'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textDark,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Logout Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _showLogoutDialog(context, authProvider);
                    },
                    icon: const Icon(Icons.logout_rounded, size: 20),
                    label: const Text('Sign Out'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSectionShimmer() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade700,
        highlightColor: Colors.grey.shade600,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.grey.shade600,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 80,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.grey.shade600,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 150,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.grey.shade600,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: 100,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.grey.shade600,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRowShimmer() {
    return Row(
      children: [
        Expanded(child: _buildStatCardShimmer()),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCardShimmer()),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCardShimmer()),
      ],
    );
  }

  Widget _buildStatCardShimmer() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade700,
        highlightColor: Colors.grey.shade600,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade600,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.grey.shade600,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 22,
                decoration: BoxDecoration(
                  color: Colors.grey.shade600,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: 60,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.grey.shade600,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityCardShimmer() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade700,
        highlightColor: Colors.grey.shade600,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey.shade600,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey.shade600,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 150,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade600,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 200,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade600,
                        borderRadius: BorderRadius.circular(4),
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

  Widget _buildWelcomeSection(UserModel? user) {
    final hour = DateTime.now().hour;
    String greeting = 'Good Morning';
    if (hour >= 12 && hour < 17) {
      greeting = 'Good Afternoon';
    } else if (hour >= 17) {
      greeting = 'Good Evening';
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF8B5CF6).withOpacity(0.2),
                const Color(0xFFEC4899).withOpacity(0.15),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8B5CF6).withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user?.name ?? 'Student',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getRoleIcon(user?.role ?? 'student'),
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      user?.role.toUpperCase() ?? 'STUDENT',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
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

  IconData _getRoleIcon(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Icons.admin_panel_settings_rounded;
      case 'owner':
        return Icons.business_rounded;
      default:
        return Icons.school_rounded;
    }
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(child: _buildStatCard('Students', _studentsCount.toString(), Icons.school_rounded)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('PG Owners', _pgOwnersCount.toString(), Icons.business_rounded)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('Mess Owners', _messOwnersCount.toString(), Icons.restaurant_rounded)),
      ],
    );
  }

  Widget _buildNotificationBanner() {
    final notification = _notifications.first;
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              const Icon(Icons.campaign_rounded, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  notification['message']?.toString() ?? 'New update available',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: Colors.white, size: 24),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                title,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _buildModuleGrid(BuildContext context) {
    final modules = [
      ModuleData(
        title: 'Rooms / PG',
        icon: Icons.home_work_rounded,
        route: () => const RoomScreen(),
        color: const Color(0xFF3B82F6),
      ),
      ModuleData(
        title: 'Mess',
        icon: Icons.restaurant_rounded,
        route: () => const MessScreen(),
        color: const Color(0xFF10B981),
      ),
      ModuleData(
        title: 'Find Room Partner',
        icon: Icons.people_alt_rounded,
        route: () => const RoommateFinderScreen(),
        color: const Color(0xFF8B5CF6),
      ),
      ModuleData(
        title: 'Lost & Found',
        icon: Icons.search_rounded,
        route: () => const LostFoundScreen(),
        color: const Color(0xFFF59E0B),
      ),
      ModuleData(
        title: 'Events',
        icon: Icons.event_rounded,
        route: () => const EventsScreen(),
        color: const Color(0xFF8B5CF6),
      ),
      ModuleData(
        title: 'Buy & Sell',
        icon: Icons.shopping_cart_rounded,
        route: () => const MarketScreen(),
        color: const Color(0xFFEC4899),
      ),
      ModuleData(
        title: 'Utilities',
        icon: Icons.miscellaneous_services_rounded,
        route: () => const UtilitiesScreen(),
        color: const Color(0xFF06B6D4),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 1.1,
      ),
      itemCount: modules.length,
      itemBuilder: (context, index) {
        return _buildModuleCard(context, modules[index], index);
      },
    );
  }

  Widget _buildModuleCard(BuildContext context, ModuleData module, int index) {
    return GestureDetector(
      onTap: () {
        SmoothNavigation.push(context, module.route());
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: module.color.withOpacity(0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Color accent
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: module.color.withOpacity(0.15),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(60),
                      ),
                    ),
                  ),
                ),
                // Content
                Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        module.icon,
                        size: 32,
                        color: module.color,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        module.title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            'Explore',
                            style: TextStyle(
                              fontSize: 12,
                              color: module.color,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 14,
                            color: module.color,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCampusMapPreview(BuildContext context) {
    final prefs = context.watch<UserPreferencesProvider>();
    final centerLat = prefs.campusLat ?? 28.5244;
    final centerLng = prefs.campusLng ?? 77.1855;
    final mapProvider = context.watch<MapProvider>();
    final markers = mapProvider.filteredMarkers.length > 10
        ? mapProvider.filteredMarkers.take(10).toList()
        : mapProvider.filteredMarkers;

    final mapPreviewUrl = MapService.generateStaticMapUrl(
      centerLat: centerLat,
      centerLng: centerLng,
      zoomLevel: 14,
      width: 600,
      height: 300,
      markers: markers,
    );

    return GestureDetector(
      onTap: () {
        SmoothNavigation.push(
          context,
          const CampusMapScreen(),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Map background image
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey.shade800,
                borderRadius: BorderRadius.circular(20),
              ),
              child: mapPreviewUrl.isEmpty
                  ? Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF8B5CF6).withOpacity(0.2),
                            const Color(0xFFEC4899).withOpacity(0.2),
                          ],
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.map_rounded,
                          color: Colors.white,
                          size: 48,
                        ),
                      ),
                    )
                  : Image.network(
                      mapPreviewUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                const Color(0xFF8B5CF6).withOpacity(0.2),
                                const Color(0xFFEC4899).withOpacity(0.2),
                              ],
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.map_rounded,
                              color: Colors.white,
                              size: 48,
                            ),
                          ),
                        );
                      },
                    ),
            ),

            // Gradient overlay
            Container(
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.6),
                  ],
                ),
              ),
            ),

            // Content
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Explore Campus Map',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'View PGs, Messes & Services nearby',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: AppColors.cardGradient,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF8B5CF6).withOpacity(0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8B5CF6).withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8B5CF6).withOpacity(0.3),
                      blurRadius: 15,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.history_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'No recent activity',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    Text(
                      'Start exploring to see your activity here',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
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

  void _showLogoutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Sign Out',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await authProvider.logout();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Logout failed: $e')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Sign Out', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
