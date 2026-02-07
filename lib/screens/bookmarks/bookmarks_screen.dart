import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import 'package:roomix/models/bookmark_model.dart';
import 'package:roomix/providers/bookmarks_provider.dart';
import 'package:roomix/constants/app_colors.dart';
import 'package:roomix/widgets/loading_indicator.dart';
import 'package:cached_network_image/cached_network_image.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  String _selectedType = 'all';
  String _sortBy = 'newest';
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, String>> _types = [
    {'label': 'All', 'value': 'all'},
    {'label': 'Rooms', 'value': 'room'},
    {'label': 'Mess', 'value': 'mess'},
    {'label': 'Utilities', 'value': 'utility'},
    {'label': 'Market', 'value': 'market'},
    {'label': 'Roommates', 'value': 'roommate'},
    {'label': 'Events', 'value': 'event'},
  ];

  final List<Map<String, String>> _sortOptions = [
    {'label': 'Newest', 'value': 'newest'},
    {'label': 'Oldest', 'value': 'oldest'},
    {'label': 'Price Low', 'value': 'price-low'},
    {'label': 'Price High', 'value': 'price-high'},
    {'label': 'Top Rating', 'value': 'rating'},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookmarksProvider>().fetchBookmarks();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: const Text('My Bookmarks'),
        backgroundColor: AppColors.darkBackground,
        elevation: 0,
        centerTitle: true,
      ),
      body: Consumer<BookmarksProvider>(
        builder: (context, bookmarksProvider, _) {
          final bookmarks = _buildFilteredBookmarks(bookmarksProvider);

          return Column(
            children: [
              // Search Bar
              _buildSearchBar(),

              // Type Filter Chips
              _buildTypeFilter(bookmarksProvider),

              // Sort Option
              _buildSortOption(),

              // Bookmarks Count
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Showing ${bookmarks.length} bookmarks',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (bookmarks.isNotEmpty)
                      GestureDetector(
                        onTap: _showClearAllDialog,
                        child: Text(
                          'Clear all',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFFEF4444),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Bookmarks List
              Expanded(
                child: bookmarksProvider.isLoading
                    ? const Center(
                        child: LoadingIndicator(
                          style: LoadingStyle.gradient,
                          sizeVariant: LoadingSize.large,
                        ),
                      )
                    : bookmarks.isEmpty
                        ? _buildEmptyState()
                        : RefreshIndicator(
                            onRefresh: () =>
                                bookmarksProvider.fetchBookmarks(),
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: bookmarks.length,
                              itemBuilder: (context, index) =>
                                  _buildBookmarkCard(bookmarks[index]),
                            ),
                          ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.15),
                width: 1,
              ),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                context.read<BookmarksProvider>().filterBookmarks(value);
              },
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search bookmarks...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                prefixIcon: Icon(Icons.search,
                    color: Colors.white.withOpacity(0.6)),
                suffixIcon: _searchController.text.isNotEmpty
                    ? GestureDetector(
                        onTap: () {
                          _searchController.clear();
                          context
                              .read<BookmarksProvider>()
                              .filterBookmarks('');
                        },
                        child: Icon(Icons.clear,
                            color: Colors.white.withOpacity(0.6)),
                      )
                    : null,
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeFilter(BookmarksProvider bookmarksProvider) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: _types.map((type) {
          final isSelected = _selectedType == type['value'];
          final count = type['value'] == 'all'
              ? bookmarksProvider.getTotalCount()
              : bookmarksProvider.getCountByType(type['value']!);

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text('${type['label']} ($count)'),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedType = type['value']!;
                });
                if (type['value'] == 'all') {
                  bookmarksProvider.filterBookmarks(_searchController.text);
                } else {
                  bookmarksProvider.filterByType(
                    type['value']!,
                    query: _searchController.text.isEmpty
                        ? null
                        : _searchController.text,
                  );
                }
              },
              backgroundColor: Colors.transparent,
              selectedColor: Color(0xFF8B5CF6).withOpacity(0.3),
              side: BorderSide(
                color: isSelected
                    ? Color(0xFF8B5CF6).withOpacity(0.5)
                    : Colors.white.withOpacity(0.2),
                width: 1.5,
              ),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSortOption() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Sort by',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _sortOptions.map((option) {
                final isSelected = _sortBy == option['value'];
                return Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _sortBy = option['value']!;
                      });
                      context
                          .read<BookmarksProvider>()
                          .sortBookmarks(_sortBy);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Color(0xFF8B5CF6).withOpacity(0.3)
                            : Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isSelected
                              ? Color(0xFF8B5CF6).withOpacity(0.5)
                              : Colors.white.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        option['label']!,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : Colors.white.withOpacity(0.6),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookmarkCard(BookmarkModel bookmark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.15),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                // Image
                if (bookmark.itemImage != null)
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: bookmark.itemImage!,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => Container(
                        width: 100,
                        height: 100,
                        color: Colors.white.withOpacity(0.05),
                        child: const Icon(Icons.image_not_supported,
                            color: Color(0xFF8B5CF6)),
                      ),
                    ),
                  ),

                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Type Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getTypeColor(bookmark.type)
                                .withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: _getTypeColor(bookmark.type)
                                  .withOpacity(0.5),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            bookmark.type.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: _getTypeColor(bookmark.type),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),

                        // Title
                        Text(
                          bookmark.itemTitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),

                        // Price & Rating
                        Row(
                          children: [
                            if (bookmark.itemPrice != null) ...[
                              Text(
                                '₹${bookmark.itemPrice?.toStringAsFixed(0) ?? 'N/A'}',
                                style: TextStyle(
                                  color: Color(0xFF8B5CF6),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 12),
                            ],
                            if (bookmark.rating != null)
                              Row(
                                children: [
                                  Icon(Icons.star,
                                      size: 14,
                                      color: Colors.amber.withOpacity(0.8)),
                                  const SizedBox(width: 4),
                                  Text(
                                    bookmark.rating?.toStringAsFixed(1) ??
                                        'N/A',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),

                        // Saved date
                        const SizedBox(height: 6),
                        Text(
                          'Saved ${_formatDate(bookmark.createdAt)}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Remove button
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: GestureDetector(
                    onTap: () => _removeBookmark(context, bookmark.id),
                    child: Icon(
                      Icons.close,
                      color: Colors.white.withOpacity(0.6),
                      size: 20,
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bookmark_border,
            size: 80,
            color: Colors.white.withOpacity(0.2),
          ),
          const SizedBox(height: 16),
          Text(
            'No bookmarks yet',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start bookmarking your favorite items',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  List<BookmarkModel> _buildFilteredBookmarks(
      BookmarksProvider bookmarksProvider) {
    List<BookmarkModel> bookmarks = bookmarksProvider.filteredBookmarks;

    // Apply type filter if not 'all'
    if (_selectedType != 'all') {
      bookmarks =
          bookmarks.where((b) => b.type == _selectedType).toList();
    }

    return bookmarks;
  }

  void _removeBookmark(BuildContext context, String bookmarkId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text(
          'Remove Bookmark?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'This bookmark will be removed from your saved items.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<BookmarksProvider>().removeBookmark(bookmarkId);
              Navigator.pop(context);
            },
            child: const Text(
              'Remove',
              style: TextStyle(color: Color(0xFFEF4444)),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text(
          'Clear All Bookmarks?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'This will remove all your bookmarked items permanently.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Implement clear all logic
              Navigator.pop(context);
            },
            child: const Text(
              'Clear All',
              style: TextStyle(color: Color(0xFFEF4444)),
            ),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'room':
        return const Color(0xFF3B82F6);
      case 'mess':
        return const Color(0xFF10B981);
      case 'utility':
        return const Color(0xFF06B6D4);
      case 'market':
        return const Color(0xFFEC4899);
      case 'roommate':
        return const Color(0xFF8B5CF6);
      case 'event':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF8B5CF6);
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'today';
    } else if (diff.inDays == 1) {
      return 'yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else if (diff.inDays < 30) {
      return '${(diff.inDays / 7).floor()} weeks ago';
    } else {
      return '${(diff.inDays / 30).floor()} months ago';
    }
  }
}
