import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:roomix/models/utility_model.dart';
import 'package:roomix/models/map_marker_model.dart';
import 'package:roomix/providers/utility_provider.dart';
import 'package:roomix/providers/map_provider.dart';
import 'package:roomix/providers/auth_provider.dart';
import 'package:roomix/constants/app_colors.dart';
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isAdmin = authProvider.currentUser?.role == 'admin';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Utilities'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
        actions: [
          if (isAdmin)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
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
                          size: 20, color: AppColors.primaryAccent),
                      const SizedBox(width: 4),
                      Text(
                        'Moderate',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primaryAccent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  if (value.isEmpty) {
                    Provider.of<UtilityProvider>(context, listen: false)
                        .fetchUtilities();
                  } else {
                    Provider.of<UtilityProvider>(context, listen: false)
                        .searchUtilities(value);
                  }
                },
                decoration: InputDecoration(
                  hintText: 'Search utilities...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            Provider.of<UtilityProvider>(context, listen: false)
                                .fetchUtilities();
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.grey, width: 1),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),

            // Category chips
            Consumer<UtilityProvider>(
              builder: (context, provider, _) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: provider.categories
                        .map((category) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                label: Text(category),
                                selected:
                                    provider.selectedCategory == null &&
                                            category == 'All' ||
                                        provider.selectedCategory == category,
                                onSelected: (selected) {
                                  if (selected) {
                                    provider.getUtilitiesByCategory(category);
                                  }
                                },
                                backgroundColor: Colors.white,
                                selectedColor: AppColors.primaryAccent,
                                labelStyle: TextStyle(
                                  color: provider.selectedCategory == null &&
                                              category == 'All' ||
                                          provider.selectedCategory == category
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

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
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    );
                  }

                  if (provider.filteredUtilities.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.location_off,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No utilities found',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: provider.filteredUtilities.length,
                    itemBuilder: (context, index) {
                      final utility = provider.filteredUtilities[index];
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
              // Convert utilities to map markers and pass to campus map
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
            backgroundColor: AppColors.primaryAccent,
            child: const Icon(Icons.map),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'add_fab',
            onPressed: () {
              SmoothNavigation.push(
                context,
                const AddUtilityScreen(),
              );
            },
            backgroundColor: AppColors.primaryAccent,
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
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
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
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[300],
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
                            color: Colors.grey[600],
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
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryAccent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            utility.category.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryAccent,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.star, size: 16, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text(
                              '${utility.rating.toStringAsFixed(1)} (${utility.reviews.length})',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
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
                    Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        utility.address!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
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
                      Icon(Icons.phone, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 6),
                      Text(
                        utility.contact!['phone'],
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
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
