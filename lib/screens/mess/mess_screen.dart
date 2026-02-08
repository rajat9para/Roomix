import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:ui';
import 'package:provider/provider.dart';
import 'package:roomix/providers/auth_provider.dart';
import 'package:roomix/services/api_service.dart';
import 'package:roomix/models/mess_model.dart';
import 'package:roomix/constants/app_colors.dart';
import 'package:roomix/widgets/loading_indicator.dart';
import 'package:roomix/widgets/filter_bottom_sheet.dart';
import 'package:roomix/widgets/sort_chip.dart';
import 'package:roomix/screens/mess/mess_detail_screen.dart';
import 'package:roomix/utils/smooth_navigation.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MessScreen extends StatefulWidget {
  const MessScreen({super.key});

  @override
  State<MessScreen> createState() => _MessScreenState();
}

class _MessScreenState extends State<MessScreen> {
  late AuthProvider _authProvider;
  List<MessModel> _allMenuItems = [];
  List<MessModel> _filteredMenuItems = [];
  bool _isLoading = true;
  String _errorMessage = '';
  int _currentPage = 1;
  int _totalPages = 1;
  final ScrollController _scrollController = ScrollController();
  
  // Search and Filter state
  TextEditingController _searchController = TextEditingController();
  String _selectedSort = 'newest'; // newest, price_low, price_high, rating
  Timer? _searchDebounce;
  double _minPrice = 0;
  double _maxPrice = 10000;
  double _selectedMinPrice = 0;
  double _selectedMaxPrice = 10000;
  double? _minRating;
  Set<String> _selectedMealTypes = {'Breakfast', 'Lunch', 'Dinner', 'All Meals'};
  Set<String> _selectedDietaryPrefs = {'Veg', 'Non-Veg', 'Jain', 'Both'};
  bool _openNowOnly = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchChanged);
    _fetchMenu();
  }

  void _onSearchChanged() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      _applyFilters();
    });
  }

  void _applyFilters() {
    List<MessModel> filtered = List.from(_allMenuItems);
    final searchQuery = _searchController.text.toLowerCase();

    // Search filter
    if (searchQuery.isNotEmpty) {
      filtered = filtered
          .where((mess) =>
              mess.name.toLowerCase().contains(searchQuery) ||
              (mess.specialization?.toLowerCase().contains(searchQuery) ?? false) ||
              (mess.menuPreview?.toLowerCase().contains(searchQuery) ?? false) ||
              (mess.address?.toLowerCase().contains(searchQuery) ?? false))
          .toList();
    }

    // Price filter
    filtered = filtered
        .where((mess) {
          final messPrice = mess.price.toDouble();
          return messPrice >= _selectedMinPrice && messPrice <= _selectedMaxPrice;
        })
        .toList();

    // Rating filter
    if (_minRating != null) {
      filtered = filtered
          .where((mess) => mess.rating >= _minRating!)
          .toList();
    }

    // Apply sorting
    _applySorting(filtered);

    setState(() {
      _filteredMenuItems = filtered;
    });
  }

  void _applySorting(List<MessModel> items) {
    switch (_selectedSort) {
      case 'price_low':
        items.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_high':
        items.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'rating':
        items.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'newest':
      default:
        break;
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      if (_currentPage < _totalPages) {
        _fetchMenu(page: _currentPage + 1);
      }
    }
  }

  Future<void> _fetchMenu({int page = 1}) async {
    if (page == 1) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });
    }

    try {
      final response = await ApiService.getMessMenu(page: page);
      
      if (response['mess'] != null) {
        final newItems = (response['mess'] as List)
            .map((e) => MessModel.fromJson(e))
            .toList();
        
        setState(() {
          if (page == 1) {
            _allMenuItems = newItems;
            // Calculate price range
            if (_allMenuItems.isNotEmpty) {
              final prices = _allMenuItems.map((m) => m.price).toList();
              _minPrice = prices.reduce((a, b) => a < b ? a : b).toDouble();
              _maxPrice = prices.reduce((a, b) => a > b ? a : b).toDouble();
              _selectedMaxPrice = _maxPrice;
            }
          } else {
            _allMenuItems.addAll(newItems);
          }
          _currentPage = response['pagination']?['currentPage'] ?? 1;
          _totalPages = response['pagination']?['totalPages'] ?? 1;
        });
        _applyFilters();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load mess data: ${e.toString()}';
      });
    } finally {
      if (page == 1) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: const Text('Mess Services'),
        backgroundColor: AppColors.darkBackground,
        elevation: 0,
        actions: [
          Badge(
            label: Text('${_getActiveFilterCount()}'),
            isLabelVisible: _getActiveFilterCount() > 0,
            child: IconButton(
              icon: const Icon(Icons.tune),
              onPressed: _showFilterBottomSheet,
            ),
          ),
        ],
      ),
      body: Container(
        color: AppColors.darkBackground,
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search mess...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                  prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.6)),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          color: Colors.white.withOpacity(0.6),
                          onPressed: () {
                            _searchController.clear();
                            _applyFilters();
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 2),
                  ),
                ),
              ),
            ),

            // Sort chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  SortChip(
                    label: 'Newest',
                    icon: Icons.fiber_new,
                    isActive: _selectedSort == 'newest',
                    onTap: () {
                      setState(() => _selectedSort = 'newest');
                      _applyFilters();
                    },
                  ),
                  const SizedBox(width: 8),
                  SortChip(
                    label: 'Price: Low-High',
                    icon: Icons.trending_down,
                    isActive: _selectedSort == 'price_low',
                    onTap: () {
                      setState(() => _selectedSort = 'price_low');
                      _applyFilters();
                    },
                  ),
                  const SizedBox(width: 8),
                  SortChip(
                    label: 'Price: High-Low',
                    icon: Icons.trending_up,
                    isActive: _selectedSort == 'price_high',
                    onTap: () {
                      setState(() => _selectedSort = 'price_high');
                      _applyFilters();
                    },
                  ),
                  const SizedBox(width: 8),
                  SortChip(
                    label: 'Rating',
                    icon: Icons.star,
                    isActive: _selectedSort == 'rating',
                    onTap: () {
                      setState(() => _selectedSort = 'rating');
                      _applyFilters();
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Results count
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${_filteredMenuItems.length} mess${_filteredMenuItems.length != 1 ? 'es' : ''} found',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Mess list
            Expanded(
              child: _isLoading && _allMenuItems.isEmpty
                  ? const LoadingIndicator()
                  : _errorMessage.isNotEmpty
                      ? _buildErrorState()
                      : _filteredMenuItems.isEmpty
                          ? _buildEmptyState()
                          : RefreshIndicator(
                              onRefresh: () => _fetchMenu(page: 1),
                              child: ListView.builder(
                                controller: _scrollController,
                                padding: const EdgeInsets.all(16),
                                itemCount: _filteredMenuItems.length + (_currentPage < _totalPages ? 1 : 0),
                                itemBuilder: (context, index) {
                                  if (index == _filteredMenuItems.length) {
                                    return const Padding(
                                      padding: EdgeInsets.all(16),
                                      child: LoadingIndicator(),
                                    );
                                  }
                                  return _buildMenuItemCard(_filteredMenuItems[index]);
                                },
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }

  int _getActiveFilterCount() {
    int count = 0;
    if (_selectedMinPrice > _minPrice || _selectedMaxPrice < _maxPrice) count++;
    if (_minRating != null) count++;
    if (_searchController.text.isNotEmpty) count++;
    if (_openNowOnly) count++;
    return count;
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return FilterBottomSheet(
          title: 'Filter Mess',
          sections: [
            FilterSection(
              title: 'Price Range',
              type: 'range',
              filterKey: 'price',
              minValue: _minPrice,
              maxValue: _maxPrice,
            ),
            FilterSection(
              title: 'Rating',
              type: 'radio',
              filterKey: 'rating',
              options: ['Any', '3+ Stars', '4+ Stars', '4.5+ Stars'],
            ),
          ],
          initialFilters: {
            'price_min': _selectedMinPrice,
            'price_max': _selectedMaxPrice,
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
              _selectedMinPrice = (filters['price_min'] as num?)?.toDouble() ?? _minPrice;
              _selectedMaxPrice = (filters['price_max'] as num?)?.toDouble() ?? _maxPrice;

              final ratingString = filters['rating'] as String?;
              if (ratingString == 'Any') {
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
              _selectedMinPrice = _minPrice;
              _selectedMaxPrice = _maxPrice;
              _minRating = null;
              _openNowOnly = false;
            });
            _applyFilters();
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restaurant_menu,
            size: 80,
            color: Colors.white.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            _searchController.text.isNotEmpty ? 'No mess match your search' : 'No mess available',
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters or search criteria',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () {
              _searchController.clear();
              setState(() {
                _selectedMinPrice = _minPrice;
                _selectedMaxPrice = _maxPrice;
                _minRating = null;
              });
              _applyFilters();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Clear All Filters',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.white.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          const Text(
            'Error loading mess services',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: _fetchMenu,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Retry',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItemCard(MessModel item) {
    return GestureDetector(
      onTap: () => SmoothNavigation.push(context, MessDetailScreen(mess: item)),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Mess Image
                  if (item.image != null)
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                          child: CachedNetworkImage(
                            imageUrl: item.image!,
                            height: 160,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              height: 160,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white.withOpacity(0.1),
                                    Colors.white.withOpacity(0.05),
                                  ],
                                ),
                              ),
                              child: const Center(
                                child: SizedBox(
                                  width: 30,
                                  height: 30,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Color(0xFF8B5CF6),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              height: 160,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white.withOpacity(0.1),
                                    Colors.white.withOpacity(0.05),
                                  ],
                                ),
                              ),
                              child: const Icon(
                                Icons.image_not_supported,
                                size: 40,
                                color: Color(0xFF8B5CF6),
                              ),
                            ),
                          ),
                        ),
                        // Rating Badge
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star, size: 14, color: Colors.amber),
                                const SizedBox(width: 4),
                                Text(
                                  item.rating.toStringAsFixed(1),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Mess Name
                        Text(
                          item.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        
                        // Price
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                          ).createShader(bounds),
                          child: Text(
                            '₹${item.price.toStringAsFixed(0)}/month',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        
                        // Specialties
                        if (item.specialities != null && item.specialities!.isNotEmpty)
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: item.specialities!.take(2).map((spec) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: const Color(0xFF8B5CF6).withOpacity(0.5),
                                  width: 1,
                                ),
                                color: const Color(0xFF8B5CF6).withOpacity(0.1),
                              ),
                              child: Text(
                                spec,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            )).toList(),
                          ),
                        const SizedBox(height: 12),
                        
                        // Timings
                        if (item.openingTime != null && item.closingTime != null)
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 14,
                                color: Colors.white.withOpacity(0.6),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${item.openingTime} - ${item.closingTime}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        const SizedBox(height: 12),
                        
                        // CTA Button
                        SizedBox(
                          width: double.infinity,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              gradient: const LinearGradient(
                                colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                              ),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => SmoothNavigation.push(context, MessDetailScreen(mess: item)),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  child: Center(
                                    child: Text(
                                      'View Details',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
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
