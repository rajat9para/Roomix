import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:ui';
import 'package:provider/provider.dart';
import 'package:roomix/providers/auth_provider.dart';
import 'package:roomix/services/api_service.dart';
import 'package:roomix/models/market_item_model.dart';
import 'package:roomix/constants/app_colors.dart';
import 'package:roomix/widgets/loading_indicator.dart';
import 'package:roomix/widgets/filter_bottom_sheet.dart';
import 'package:roomix/widgets/sort_chip.dart';
import 'package:roomix/widgets/bookmark_button.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  late AuthProvider _authProvider;
  late TextEditingController _searchController;
  Timer? _searchDebounceTimer;
  List<MarketItemModel> _items = [];
  List<MarketItemModel> _filteredItems = [];
  bool _isLoading = true;
  String _errorMessage = '';
  int _currentPage = 1;
  int _totalPages = 1;
  final ScrollController _scrollController = ScrollController();
  double _minPrice = 0;
  double _maxPrice = 50000;
  double _selectedMinPrice = 0;
  double _selectedMaxPrice = 50000;
  String? _selectedCondition;
  String _sortBy = 'newest';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _scrollController.addListener(_onScroll);
    _fetchItems();
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      if (_currentPage < _totalPages) {
        _fetchItems(page: _currentPage + 1);
      }
    }
  }

  Future<void> _fetchItems({int page = 1}) async {
    if (page == 1) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });
    }

    try {
      final response = await ApiService.getMarketItems(page: page);
      
      if (response['items'] != null) {
        final newItems = (response['items'] as List)
            .map((e) => MarketItemModel.fromJson(e))
            .toList();
        
        setState(() {
          if (page == 1) {
            _items = newItems;
            _filteredItems = newItems;
            
            // Calculate price range from items
            if (newItems.isNotEmpty) {
              final prices = newItems.map((e) => e.price).toList();
              _minPrice = prices.reduce((a, b) => a < b ? a : b);
              _maxPrice = prices.reduce((a, b) => a > b ? a : b);
              _selectedMinPrice = _minPrice;
              _selectedMaxPrice = _maxPrice;
            }
          } else {
            _items.addAll(newItems);
          }
          _currentPage = response['pagination']?['currentPage'] ?? 1;
          _totalPages = response['pagination']?['totalPages'] ?? 1;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load items: ${e.toString()}';
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
    List<MarketItemModel> results = List.from(_items);
    
    // Search filter
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      results = results.where((item) => 
        item.title.toLowerCase().contains(query) ||
        (item.description?.toLowerCase().contains(query) ?? false)
      ).toList();
    }
    
    // Price filter
    results = results.where((item) => 
      item.price >= _selectedMinPrice && item.price <= _selectedMaxPrice
    ).toList();
    
    // Condition filter
    if (_selectedCondition != null) {
      results = results.where((item) => item.condition == _selectedCondition).toList();
    }
    
    _applySorting(results);
    
    setState(() {
      _filteredItems = results;
    });
  }

  void _applySorting(List<MarketItemModel> items) {
    switch (_sortBy) {
      case 'price-low':
        items.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price-high':
        items.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'newest':
      default:
        break;
    }
  }

  int _getActiveFilterCount() {
    int count = 0;
    if (_selectedCondition != null) count++;
    if (_selectedMinPrice > _minPrice || _selectedMaxPrice < _maxPrice) count++;
    return count;
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return FilterBottomSheet(
          title: 'Filter Items',
          sections: [
            FilterSection(
              title: 'Condition',
              type: 'radio',
              filterKey: 'condition',
              options: ['Any', 'New', 'Like New', 'Used'],
            ),
            FilterSection(
              title: 'Price Range',
              type: 'range',
              filterKey: 'price',
              minValue: _minPrice,
              maxValue: _maxPrice,
            ),
          ],
          initialFilters: {
            'condition': _selectedCondition ?? 'Any',
            'price_min': _selectedMinPrice,
            'price_max': _selectedMaxPrice,
          },
          onApply: (filters) {
            setState(() {
              final selectedCondition = filters['condition'] as String?;
              _selectedCondition = (selectedCondition == null || selectedCondition == 'Any')
                  ? null
                  : selectedCondition;
              _selectedMinPrice = (filters['price_min'] as num?)?.toDouble() ?? _minPrice;
              _selectedMaxPrice = (filters['price_max'] as num?)?.toDouble() ?? _maxPrice;
            });
            _applyFilters();
          },
          onReset: () {
            setState(() {
              _selectedCondition = null;
              _selectedMinPrice = _minPrice;
              _selectedMaxPrice = _maxPrice;
            });
            _applyFilters();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    _authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Buy & Sell',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
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
                      hintText: 'Search items...',
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

            // Sort chips
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
                    label: 'Price Low',
                    isActive: _sortBy == 'price-low',
                    onTap: () {
                      setState(() {
                        _sortBy = 'price-low';
                      });
                      _applyFilters();
                    },
                  ),
                  const SizedBox(width: 8),
                  SortChip(
                    label: 'Price High',
                    isActive: _sortBy == 'price-high',
                    onTap: () {
                      setState(() {
                        _sortBy = 'price-high';
                      });
                      _applyFilters();
                    },
                  ),
                ],
              ),
            ),

            // Results count
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Showing ${_filteredItems.length} items',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.6),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Items list
            Expanded(
              child: _isLoading && _filteredItems.isEmpty
                  ? const LoadingIndicator()
                  : _filteredItems.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          onRefresh: () => _fetchItems(page: 1),
                          child: ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _filteredItems.length + (_currentPage < _totalPages ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == _filteredItems.length) {
                                return const Padding(
                                  padding: EdgeInsets.all(16),
                                  child: LoadingIndicator(),
                                );
                              }
                              return _buildItemCard(_filteredItems[index]);
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_bag,
            size: 80,
            color: Colors.white.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            _searchController.text.isNotEmpty 
              ? 'No items match your search'
              : 'No items available',
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later or list your own item',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () => _fetchItems(page: 1),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Refresh',
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

  Widget _buildItemCard(MarketItemModel item) {
    return Container(
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
                // Item Image with sold badge
                Stack(
                  children: [
                    if (item.image != null)
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        child: AspectRatio(
                          aspectRatio: 16 / 9,
                          child: CachedNetworkImage(
                            imageUrl: item.image!,
                            placeholder: (context, url) => Container(
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
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    else
                      Container(
                        height: 180,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.1),
                              Colors.white.withOpacity(0.05),
                            ],
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.image,
                            size: 40,
                            color: Color(0xFF8B5CF6),
                          ),
                        ),
                      ),
                    // Sold Badge
                    if (item.sold)
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),
                          child: const Text(
                            'SOLD',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                
                // Item Details
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title, Price and Bookmark
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                            ).createShader(bounds),
                            child: Text(
                              '₹${item.price.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          BookmarkButton(
                            itemId: item.id,
                            type: 'market',
                            itemTitle: item.title,
                            itemImage: item.image,
                            itemPrice: item.price,
                            metadata: {
                              'condition': item.condition,
                              'seller': item.sellerName,
                              'sold': item.sold,
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      // Condition badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: item.condition.toLowerCase() == 'new'
                              ? Colors.green.withOpacity(0.2)
                              : Colors.orange.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: item.condition.toLowerCase() == 'new'
                                ? Colors.green.withOpacity(0.5)
                                : Colors.orange.withOpacity(0.5),
                          ),
                        ),
                        child: Text(
                          item.condition,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: item.condition.toLowerCase() == 'new'
                                ? Colors.green.shade300
                                : Colors.orange.shade300,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Seller Info
                      Row(
                        children: [
                          Icon(
                            Icons.person,
                            size: 14,
                            color: Colors.white.withOpacity(0.6),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            item.sellerName,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.7),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      // CTA
                      SizedBox(
                        width: double.infinity,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            gradient: item.sold
                                ? LinearGradient(
                                    colors: [
                                      Colors.grey.withOpacity(0.5),
                                      Colors.grey.withOpacity(0.4),
                                    ],
                                  )
                                : const LinearGradient(
                                    colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                                  ),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: item.sold ? null : () {},
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                child: Center(
                                  child: Text(
                                    item.sold ? 'Sold' : 'View Details',
                                    style: const TextStyle(
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
    );
  }
}
