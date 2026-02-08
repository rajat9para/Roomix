import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:ui';
import 'package:provider/provider.dart';
import 'package:roomix/models/utility_model.dart';
import 'package:roomix/models/map_marker_model.dart';
import 'package:roomix/providers/utility_provider.dart';
import 'package:roomix/providers/map_provider.dart';
import 'package:roomix/providers/auth_provider.dart';
import 'package:roomix/constants/app_colors.dart';
import 'package:roomix/widgets/filter_bottom_sheet.dart';
import 'package:roomix/widgets/sort_chip.dart';
import 'package:roomix/utils/smooth_navigation.dart';
import 'package:roomix/screens/utilities/add_utility_screen.dart';
import 'package:roomix/screens/utilities/utility_detail_screen.dart';
import 'package:roomix/screens/utilities/admin_utility_moderation_screen.dart';
import 'package:roomix/screens/map/campus_map_screen.dart';
import 'package:shimmer/shimmer.dart';

class UtilitiesScreen extends StatefulWidget {
  const UtilitiesScreen({super.key});

  @override
  State<UtilitiesScreen> createState() => _UtilitiesScreenState();
}

class _UtilitiesScreenState extends State<UtilitiesScreen> {
  late TextEditingController _searchController;
  Timer? _searchDebounceTimer;
  List<UtilityModel> _allUtilities = [];
  List<UtilityModel> _filteredUtilities = [];
  double? _minRating;
  String _sortBy = 'newest';
  bool _openNowOnly = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    
    Future.microtask(() {
      final provider = Provider.of<UtilityProvider>(context, listen: false);
      provider.fetchUtilities();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchDebounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      _applyFilters();
    });
  }

  void _applyFilters() {
    List<UtilityModel> results = List.from(_allUtilities);
    
    // Search filter
    if (_searchController.text.isNotEmpty) {
      results = results.where((utility) => 
        utility.name.toLowerCase().contains(_searchController.text.toLowerCase()) ||
        (utility.category.toLowerCase().contains(_searchController.text.toLowerCase()))
      ).toList();
    }
    
    // Rating filter
    if (_minRating != null) {
      results = results.where((utility) => utility.rating >= _minRating!).toList();
    }
    
    // Open now filter
    if (_openNowOnly) {
      results = results.where((utility) {
        final now = DateTime.now();
        // Implement actual open now logic based on utility opening hours if available
        return true; // Placeholder
      }).toList();
    }
    
    _applySorting(results);
    
    setState(() {
      _filteredUtilities = results;
    });
  }

  void _applySorting(List<UtilityModel> items) {
    switch (_sortBy) {
      case 'rating':
        items.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'newest':
      default:
        break;
    }
  }

  int _getActiveFilterCount() {
    int count = 0;
    if (_minRating != null) count++;
    if (_openNowOnly) count++;
    return count;
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return FilterBottomSheet(
          title: 'Filter Utilities',
          sections: [
            FilterSection(
              title: 'Rating',
              type: 'radio',
              filterKey: 'rating',
              options: ['Any', '3+ Stars', '4+ Stars', '4.5+ Stars'],
            ),
          ],
          initialFilters: {
            'rating': _minRating == null
                ? 'Any'
                : _minRating == 3.0
                    ? '3+ Stars'
                    : _minRating == 4.0
                        ? '4+ Stars'
                        : '4.5+ Stars',
          },
          onApply: (filters) {
            setState(() {
              final ratingString = filters['rating'] as String?;
              if (ratingString == null || ratingString == 'Any') {
                _minRating = null;
              } else if (ratingString == '3+ Stars') {
                _minRating = 3.0;
              } else if (ratingString == '4+ Stars') {
                _minRating = 4.0;
              } else if (ratingString == '4.5+ Stars') {
                _minRating = 4.5;
              }
            });
            _applyFilters();
          },
          onReset: () {
            setState(() {
              _minRating = null;
              _openNowOnly = false;
            });
            _applyFilters();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isAdmin = authProvider.currentUser?.role == 'admin';
    final isOwner = authProvider.currentUser?.role == 'owner';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Utilities'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Stack(
              children: [
                Center(
                  child: GestureDetector(
                    onTap: _showFilterBottomSheet,
                    child: const Icon(Icons.tune, size: 24),
                  ),
                ),
                if (_getActiveFilterCount() > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFFEC4899),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        _getActiveFilterCount().toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (isAdmin)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: GestureDetector(
                onTap: () {
                  SmoothNavigation.push(
                    context,
                    const AdminUtilityModerationScreen(),
                  );
                },
                child: Row(
                  children: [
                    Icon(Icons.admin_panel_settings,
                        size: 20, color: const Color(0xFF8B5CF6)),
                    const SizedBox(width: 4),
                    const Text(
                      'Moderate',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF8B5CF6),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      body: Container(
        color: const Color(0xFF0F172A),
        child: Column(
          children: [
            // Search bar with glassmorphism
            Padding(
              padding: const EdgeInsets.all(16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Search utilities...',
                      hintStyle: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.white.withOpacity(0.7),
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: Colors.white),
                              onPressed: () {
                                _searchController.clear();
                                _applyFilters();
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.white.withOpacity(0.2),
                          width: 1.5,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.white.withOpacity(0.2),
                          width: 1.5,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF8B5CF6),
                          width: 2,
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.08),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),

            // Sort chipspaseo
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  SortChip(
                    label: 'Newest',
                    isActive: _sortBy == 'newest',
                    onTap: () {
                      setState(() {
                        _sortBy = 'newest';
                      });
                      _applyFilters();
                    },
                  ),
                  const SizedBox(width: 8),
                  SortChip(
                    label: 'Top Rated',
                    isActive: _sortBy == 'rating',
                    onTap: () {
                      setState(() {
                        _sortBy = 'rating';
                      });
                      _applyFilters();
                    },
                  ),
                ],
              ),
            ),

            // Results count
            Consumer<UtilityProvider>(
              builder: (context, provider, _) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Showing ${_filteredUtilities.length} utilities',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            // Utilities list
            Expanded(
              child: Consumer<UtilityProvider>(
                builder: (context, provider, _) {
                  if (provider.isLoading) {
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: 5,
                      itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Shimmer.fromColors(
                          baseColor: Colors.grey[800]!,
                          highlightColor: Colors.grey[700]!,
                          child: Container(
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    );
                  }

                  if (_filteredUtilities.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.location_off,
                            size: 64,
                            color: Colors.white.withOpacity(0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchController.text.isNotEmpty 
                              ? 'No utilities match your search'
                              : 'No utilities found',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try adjusting your filters',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredUtilities.length,
                    itemBuilder: (context, index) {
                      final utility = _filteredUtilities[index];
                      return UtilityCard(utility: utility);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'map_fab',
            onPressed: () {
              final utilityProvider = Provider.of<UtilityProvider>(context, listen: false);
              final mapProvider = Provider.of<MapProvider>(context, listen: false);
              final markers = utilityProvider.getUtilitiesAsMapMarkers();
              mapProvider.addMarkers(markers);
              
              SmoothNavigation.push(
                context,
                const CampusMapScreen(
                  filterCategory: MarkerCategory.utility,
                ),
              );
            },
            backgroundColor: const Color(0xFF8B5CF6),
            child: const Icon(Icons.map),
          ),
          const SizedBox(height: 16),
          if (isOwner)
            FloatingActionButton(
              heroTag: 'add_fab',
              onPressed: () {
                SmoothNavigation.push(
                  context,
                  const AddUtilityScreen(),
                );
              },
              backgroundColor: const Color(0xFF8B5CF6),
              child: const Icon(Icons.add),
            ),
        ],
      ),
    );
  }
}

class UtilityCard extends StatelessWidget {
  final UtilityModel utility;

  const UtilityCard({
    super.key,
    required this.utility,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        SmoothNavigation.push(
          context,
          UtilityDetailScreen(utilityId: utility.id),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.15),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: Colors.white.withOpacity(0.05),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with name and category
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image or placeholder
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                          ),
                          image: utility.image != null
                              ? DecorationImage(
                                  image: NetworkImage(utility.image!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: utility.image == null
                            ? Icon(
                                Icons.location_on,
                                size: 32,
                                color: Colors.white.withOpacity(0.5),
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      // Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    utility.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (utility.verified)
                                  const Tooltip(
                                    message: 'Verified',
                                    child: Icon(
                                      Icons.verified,
                                      color: Colors.green,
                                      size: 20,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF8B5CF6).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: const Color(0xFF8B5CF6).withOpacity(0.4),
                                ),
                              ),
                              child: Text(
                                utility.category.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF8B5CF6),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.star, size: 14, color: Colors.amber),
                                const SizedBox(width: 4),
                                Text(
                                  '${utility.rating.toStringAsFixed(1)} (${utility.reviews.length})',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Address
                  if (utility.address != null)
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 14,
                          color: Colors.white.withOpacity(0.6),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            utility.address!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.6),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  // Contact info if available
                  if (utility.contact?['phone'] != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        children: [
                          Icon(
                            Icons.phone,
                            size: 14,
                            color: Colors.white.withOpacity(0.6),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            utility.contact!['phone'],
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.6),
                            ),
                          ),
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
}
