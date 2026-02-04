import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:roomix/providers/auth_provider.dart';
import 'package:roomix/services/api_service.dart';
import 'package:roomix/models/lost_item_model.dart';
import 'package:roomix/constants/app_colors.dart';
import 'package:roomix/widgets/loading_indicator.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

class LostFoundScreen extends StatefulWidget {
  const LostFoundScreen({super.key});

  @override
  State<LostFoundScreen> createState() => _LostFoundScreenState();
}

class _LostFoundScreenState extends State<LostFoundScreen> {
  late AuthProvider _authProvider;
  List<LostItemModel> _items = [];
  bool _isLoading = true;
  String _errorMessage = '';
  String _filterStatus = 'all';
  int _currentPage = 1;
  int _totalPages = 1;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
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
      final response = await ApiService.getLostItems(page: page);
      
      if (response['items'] != null) {
        final newItems = (response['items'] as List)
            .map((e) => LostItemModel.fromJson(e))
            .toList();
        
        setState(() {
          if (page == 1) {
            _items = newItems;
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
    super.dispose();
  }

  List<LostItemModel> _getFilteredItems() {
    if (_filterStatus == 'all') return _items;
    return _items.where((item) => item.status.toLowerCase() == _filterStatus.toLowerCase()).toList();
  }

  @override
  Widget build(BuildContext context) {
    _authProvider = Provider.of<AuthProvider>(context);
    final filteredItems = _getFilteredItems();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Lost & Found',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: Container(
        color: AppColors.background,
        child: _isLoading && _items.isEmpty
            ? const LoadingIndicator()
            : Column(
                children: [
                  // Filter Section
                  _buildFilterSection(),
                  const SizedBox(height: 16),
                  
                  // Items List
                  Expanded(
                    child: filteredItems.isEmpty
                        ? _buildEmptyState()
                        : RefreshIndicator(
                            onRefresh: () => _fetchItems(page: 1),
                            child: ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.all(16),
                              itemCount: filteredItems.length + (_currentPage < _totalPages ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == filteredItems.length) {
                                  return const Padding(
                                    padding: EdgeInsets.all(16),
                                    child: LoadingIndicator(),
                                  );
                                }
                                return _buildItemCard(filteredItems[index]);
                              },
                            ),
                          ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const Text(
            'Filter:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(width: 12),
          _buildFilterChip('All', 'all'),
          const SizedBox(width: 8),
          _buildFilterChip('Lost', 'lost'),
          const SizedBox(width: 8),
          _buildFilterChip('Found', 'found'),
          const SizedBox(width: 8),
          _buildFilterChip('Claimed', 'claimed'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String status) {
    return FilterChip(
      label: Text(label),
      selected: _filterStatus == status,
      onSelected: (bool selected) {
        setState(() {
          _filterStatus = selected ? status : 'all';
        });
      },
      backgroundColor: AppColors.background,
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(
        color: _filterStatus == status ? Colors.white : AppColors.textDark,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.search_off,
            size: 80,
            color: AppColors.textSubtle,
          ),
          const SizedBox(height: 16),
          Text(
            _filterStatus == 'all' ? 'No items found' : 'No ${_filterStatus.toLowerCase()} items',
            style: TextStyle(
              fontSize: 18,
              color: AppColors.textSubtle,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later or report a new item',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textGray,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _fetchItems,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Refresh'),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(LostItemModel item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Item Image
          if (item.image != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: CachedNetworkImage(
                imageUrl: item.image!,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 160,
                  color: Colors.grey[300],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 160,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image_not_supported, size: 40),
                ),
              ),
            ),
          
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildStatusChip(item.status),
                  ],
                ),
                const SizedBox(height: 8),
                
                // Claim Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: item.claimStatus == 'Claimed' ? Colors.green.shade100 : Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Claim: ${item.claimStatus}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: item.claimStatus == 'Claimed' ? Colors.green.shade700 : Colors.orange.shade700,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Description
                if (item.description.isNotEmpty)
                  Text(
                    item.description,
                    style: const TextStyle(fontSize: 13, color: AppColors.textGray),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 12),

                // Date and Contact
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 14, color: AppColors.textGray),
                    const SizedBox(width: 6),
                    Text(
                      DateFormat('MMM dd, yyyy').format(item.date),
                      style: const TextStyle(fontSize: 12, color: AppColors.textGray),
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.phone, size: 14, color: AppColors.textGray),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        item.contact,
                        style: const TextStyle(fontSize: 12, color: AppColors.textGray),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // CTA
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                    child: const Text('View Details'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String? status) {
    Color chipColor;
    Color textColor;
    
    switch (status?.toLowerCase()) {
      case 'lost':
        chipColor = AppColors.warning;
        textColor = Colors.white;
        break;
      case 'found':
        chipColor = AppColors.success;
        textColor = Colors.white;
        break;
      case 'claimed':
        chipColor = AppColors.info;
        textColor = Colors.white;
        break;
      default:
        chipColor = AppColors.textSubtle;
        textColor = Colors.white;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status ?? 'Unknown',
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
