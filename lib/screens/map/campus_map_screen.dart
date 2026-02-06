import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:roomix/constants/app_colors.dart';
import 'package:roomix/models/map_marker_model.dart';
import 'package:roomix/providers/map_provider.dart';
import 'package:roomix/providers/user_preferences_provider.dart';
import 'package:roomix/services/map_service.dart';
import 'package:roomix/utils/smooth_navigation.dart';

class CampusMapScreen extends StatefulWidget {
  final List<MapMarkerModel>? initialMarkers;
  final MarkerCategory? filterCategory;

  const CampusMapScreen({
    super.key,
    this.initialMarkers,
    this.filterCategory,
  });

  @override
  State<CampusMapScreen> createState() => _CampusMapScreenState();
}

class _CampusMapScreenState extends State<CampusMapScreen>
    with SingleTickerProviderStateMixin {
  late TextEditingController _searchController;
  late AnimationController _animationController;
  bool _showFilters = false;
  bool _showMarkerDetails = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Initialize map provider with markers
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prefs = context.read<UserPreferencesProvider>();
      final lat = prefs.campusLat;
      final lng = prefs.campusLng;
      if (lat != null && lng != null) {
        context.read<MapProvider>().updateMapView(lat, lng, 15);
      }
      if (widget.initialMarkers != null) {
        context.read<MapProvider>().addMarkers(widget.initialMarkers!);
      }
      if (widget.filterCategory != null) {
        final provider = context.read<MapProvider>();
        provider.resetView();
        provider.setCategories({widget.filterCategory!});
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Stack(
        children: [
          // Map background
          _buildMapBackground(),

          // Top navigation and search
          _buildTopBar(),

          // Filter chips
          _buildFilterChips(),

          // Map markers and clusters
          _buildMapMarkers(),

          // Bottom sheet for marker details
          if (_showMarkerDetails) _buildMarkerDetailsSheet(),

          // Floating action buttons
          _buildFloatingActions(),
        ],
      ),
    );
  }

  Widget _buildMapBackground() {
    return Consumer<MapProvider>(
      builder: (context, mapProvider, _) {
        final markers = mapProvider.filteredMarkers.length > 20
            ? mapProvider.filteredMarkers.take(20).toList()
            : mapProvider.filteredMarkers;

        final mapUrl = MapService.generateStaticMapUrl(
          centerLat: mapProvider.centerLat,
          centerLng: mapProvider.centerLng,
          zoomLevel: mapProvider.zoomLevel,
          width: 1200,
          height: 1600,
          markers: markers,
        );

        return Stack(
          fit: StackFit.expand,
          children: [
            mapUrl.isEmpty
                ? Container(
                    color: AppColors.darkBackground,
                    child: Center(
                      child: Text(
                        'TomTom key missing. Set TOMTOM_API_KEY.',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  )
                : CachedNetworkImage(
                    imageUrl: mapUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, _) => Container(
                      color: AppColors.darkBackground,
                      child: const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    ),
                    errorWidget: (context, _, __) => Container(
                      color: AppColors.darkBackground,
                      child: Center(
                        child: Text(
                          'Map failed to load',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.55),
                    Colors.transparent,
                    Colors.black.withOpacity(0.3),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Back button
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(12),
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Search bar
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Search locations...',
                          hintStyle: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                          ),
                          border: InputBorder.none,
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          prefixIconConstraints: const BoxConstraints(
                            minWidth: 40,
                            minHeight: 40,
                          ),
                        ),
                        onChanged: (query) {
                          context.read<MapProvider>().searchMarkers(query);
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Positioned(
      top: 100,
      left: 0,
      right: 0,
      child: Consumer<MapProvider>(
        builder: (context, mapProvider, _) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ...MarkerCategory.values.map((category) {
                  final isSelected =
                      mapProvider.selectedCategories.contains(category);
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () =>
                          context.read<MapProvider>().toggleCategory(category),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? category == MarkerCategory.pg
                                  ? const Color(0xFF3B82F6)
                                  : category == MarkerCategory.mess
                                      ? const Color(0xFF10B981)
                                      : category == MarkerCategory.service
                                          ? const Color(0xFFF59E0B)
                                          : category == MarkerCategory.event
                                              ? const Color(0xFF8B5CF6)
                                              : const Color(0xFF06B6D4)
                              : Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? Colors.white
                                : Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              category == MarkerCategory.pg
                                  ? '🏠'
                                  : category == MarkerCategory.mess
                                      ? '🍛'
                                      : category == MarkerCategory.service
                                          ? '🔧'
                                          : category == MarkerCategory.event
                                              ? '📅'
                                              : '🏥',
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              category == MarkerCategory.pg
                                  ? 'PG'
                                  : category == MarkerCategory.mess
                                      ? 'Mess'
                                      : category == MarkerCategory.service
                                          ? 'Services'
                                          : category == MarkerCategory.event
                                              ? 'Events'
                                              : 'Utilities',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMapMarkers() {
    return Consumer<MapProvider>(
      builder: (context, mapProvider, _) {
        if (mapProvider.filteredMarkers.isEmpty) {
          return Positioned.fill(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_off_rounded,
                    color: Colors.white.withOpacity(0.5),
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No locations found',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  @Deprecated('Markers are now handled by TomTom SDK')
  Widget _buildMarkerPin(MapMarkerModel marker) {
    return const SizedBox.shrink();
  }

  @Deprecated('Markers are now handled by TomTom SDK')
  Widget _buildClusterPin(MapCluster cluster) {
    return const SizedBox.shrink();
  }

  Widget _buildMarkerDetailsSheet() {
    return Consumer<MapProvider>(
      builder: (context, mapProvider, _) {
        final marker = mapProvider.selectedMarker;
        if (marker == null) return const SizedBox.shrink();

        return Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Handle
                    Padding(
                      padding: const EdgeInsets.only(top: 12, bottom: 16),
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),

                    // Close button
                    Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: GestureDetector(
                          onTap: () {
                            setState(() => _showMarkerDetails = false);
                            context.read<MapProvider>().selectMarker('');
                          },
                          child: const Icon(
                            Icons.close_rounded,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                    ),

                    // Marker details
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Image
                          if (marker.imageUrl != null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: CachedNetworkImage(
                                imageUrl: marker.imageUrl!,
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            )
                          else
                            Container(
                              height: 200,
                              decoration: BoxDecoration(
                                color: marker.getCategoryColor()
                                    .withOpacity(0.15),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Center(
                                child: Icon(
                                  marker.getCategoryIcon(),
                                  size: 64,
                                  color: marker.getCategoryColor(),
                                ),
                              ),
                            ),
                          const SizedBox(height: 16),

                          // Title
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: marker.getCategoryColor()
                                      .withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  marker.getCategoryName(),
                                  style: TextStyle(
                                    color: marker.getCategoryColor(),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            marker.title,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),

                          // Description
                          if (marker.description != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                marker.description!,
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 14,
                                ),
                              ),
                            ),

                          // Address
                          if (marker.address != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.location_on_rounded,
                                    color: AppColors.primary,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      marker.address!,
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // Coordinates
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.navigation_rounded,
                                  color: AppColors.primary,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${marker.latitude.toStringAsFixed(4)}, ${marker.longitude.toStringAsFixed(4)}',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Action button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                // Navigate to detail screen based on category
                                Navigator.pop(context);
                              },
                              icon: const Icon(Icons.arrow_forward_rounded),
                              label: const Text('View Details'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: marker.getCategoryColor(),
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFloatingActions() {
    return Positioned(
      bottom: 24,
      right: 16,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Filter button
          FloatingActionButton.small(
            onPressed: () {
              setState(() => _showFilters = !_showFilters);
            },
            backgroundColor: AppColors.primary,
            child: const Icon(Icons.tune_rounded),
          ),
          const SizedBox(height: 12),

          // Center location button
          FloatingActionButton.small(
            onPressed: () {
              context.read<MapProvider>().updateMapView(28.5244, 77.1855, 14);
            },
            backgroundColor: AppColors.primary,
            child: const Icon(Icons.my_location_rounded),
          ),
        ],
      ),
    );
  }
}
