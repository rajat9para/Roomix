import 'package:flutter/material.dart';
import 'package:roomix/models/bookmark_model.dart';
import 'package:roomix/services/api_service.dart';

class BookmarksProvider extends ChangeNotifier {
  List<BookmarkModel> _bookmarks = [];
  List<BookmarkModel> _filteredBookmarks = [];
  bool _isLoading = false;
  String _errorMessage = '';

  // Getters
  List<BookmarkModel> get bookmarks => _bookmarks;
  List<BookmarkModel> get filteredBookmarks => _filteredBookmarks;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  // Filter by type
  List<BookmarkModel> getBookmarksByType(String type) {
    return _bookmarks.where((b) => b.type == type).toList();
  }

  // Check if item is bookmarked
  bool isBookmarked(String itemId) {
    return _bookmarks.any((b) => b.itemId == itemId);
  }

  // Count bookmarks by type
  int getCountByType(String type) {
    return _bookmarks.where((b) => b.type == type).length;
  }

  // Get all bookmarks count
  int getTotalCount() => _bookmarks.length;

  // Fetch all bookmarks
  Future<void> fetchBookmarks() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await ApiService.dio.get('/bookmarks');

      if (response.statusCode == 200) {
        final data = response.data['bookmarks'] as List? ?? [];
        _bookmarks = data
            .map((item) => BookmarkModel.fromJson(item as Map<String, dynamic>))
            .toList();
        _filteredBookmarks = List.from(_bookmarks);
      }
    } catch (e) {
      _errorMessage = 'Failed to fetch bookmarks: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add bookmark
  Future<bool> addBookmark({
    required String itemId,
    required String type,
    required String itemTitle,
    String? itemImage,
    double? itemPrice,
    double? rating,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final payload = {
        'itemId': itemId,
        'type': type,
        'itemTitle': itemTitle,
        'itemImage': itemImage,
        'itemPrice': itemPrice,
        'rating': rating,
        'metadata': metadata,
      };

      final response = await ApiService.dio.post('/bookmarks', data: payload);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final bookmark =
            BookmarkModel.fromJson(response.data['bookmark'] ?? {});
        _bookmarks.add(bookmark);
        _filteredBookmarks = List.from(_bookmarks);
        notifyListeners();
        return true;
      }
    } catch (e) {
      _errorMessage = 'Failed to add bookmark: ${e.toString()}';
      notifyListeners();
      return false;
    }
    return false;
  }

  // Remove bookmark
  Future<bool> removeBookmark(String bookmarkId) async {
    try {
      final response = await ApiService.dio.delete('/bookmarks/$bookmarkId');

      if (response.statusCode == 200 || response.statusCode == 204) {
        _bookmarks.removeWhere((b) => b.id == bookmarkId);
        _filteredBookmarks = List.from(_bookmarks);
        notifyListeners();
        return true;
      }
    } catch (e) {
      _errorMessage = 'Failed to remove bookmark: ${e.toString()}';
      notifyListeners();
      return false;
    }
    return false;
  }

  // Remove bookmark by item ID (for quick toggle)
  Future<bool> removeBookmarkByItemId(String itemId) async {
    final bookmark = _bookmarks.firstWhere(
      (b) => b.itemId == itemId,
      orElse: () => BookmarkModel(
        id: '',
        userId: '',
        itemId: '',
        type: '',
        itemTitle: '',
        createdAt: DateTime.now(),
      ),
    );

    if (bookmark.id.isNotEmpty) {
      return removeBookmark(bookmark.id);
    }
    return false;
  }

  // Filter bookmarks
  void filterBookmarks(String query) {
    if (query.isEmpty) {
      _filteredBookmarks = List.from(_bookmarks);
    } else {
      _filteredBookmarks = _bookmarks
          .where((b) =>
              b.itemTitle.toLowerCase().contains(query.toLowerCase()) ||
              b.type.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  // Filter by type and search
  void filterByType(String type, {String? query}) {
    _filteredBookmarks =
        _bookmarks.where((b) => b.type == type).toList();

    if (query != null && query.isNotEmpty) {
      _filteredBookmarks = _filteredBookmarks
          .where((b) =>
              b.itemTitle.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }

    notifyListeners();
  }

  // Sort bookmarks
  void sortBookmarks(String sortBy) {
    switch (sortBy) {
      case 'newest':
        _filteredBookmarks
            .sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'oldest':
        _filteredBookmarks
            .sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case 'price-low':
        _filteredBookmarks.sort((a, b) =>
            (a.itemPrice ?? 0).compareTo(b.itemPrice ?? 0));
        break;
      case 'price-high':
        _filteredBookmarks.sort((a, b) =>
            (b.itemPrice ?? 0).compareTo(a.itemPrice ?? 0));
        break;
      case 'rating':
        _filteredBookmarks.sort((a, b) =>
            (b.rating ?? 0).compareTo(a.rating ?? 0));
        break;
    }
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}
