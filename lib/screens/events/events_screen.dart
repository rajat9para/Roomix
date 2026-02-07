import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:roomix/providers/auth_provider.dart';
import 'package:roomix/services/api_service.dart';
import 'package:roomix/models/event_model.dart';
import 'package:roomix/constants/app_colors.dart';
import 'package:roomix/widgets/loading_indicator.dart';
import 'package:roomix/widgets/bookmark_button.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  late AuthProvider _authProvider;
  List<EventModel> _events = [];
  bool _isLoading = true;
  String _errorMessage = '';
  int _currentPage = 1;
  int _totalPages = 1;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _fetchEvents();
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      if (_currentPage < _totalPages) {
        _fetchEvents(page: _currentPage + 1);
      }
    }
  }

  Future<void> _fetchEvents({int page = 1}) async {
    if (page == 1) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });
    }

    try {
      final response = await ApiService.getEvents(page: page);
      
      if (response['events'] != null) {
        final newEvents = (response['events'] as List)
            .map((e) => EventModel.fromJson(e))
            .toList();
        
        setState(() {
          if (page == 1) {
            _events = newEvents;
          } else {
            _events.addAll(newEvents);
          }
          _currentPage = response['pagination']?['currentPage'] ?? 1;
          _totalPages = response['pagination']?['totalPages'] ?? 1;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load events: ${e.toString()}';
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

  @override
  Widget build(BuildContext context) {
    _authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Events',
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
        child: _isLoading && _events.isEmpty
            ? const LoadingIndicator()
            : _events.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
                    onRefresh: () => _fetchEvents(page: 1),
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: _events.length + (_currentPage < _totalPages ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _events.length) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: LoadingIndicator(),
                          );
                        }
                        return _buildEventCard(_events[index]);
                      },
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
          const Icon(
            Icons.event_available,
            size: 80,
            color: AppColors.textSubtle,
          ),
          const SizedBox(height: 16),
          Text(
            'No events scheduled',
            style: TextStyle(
              fontSize: 18,
              color: AppColors.textSubtle,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later for new events',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textGray,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _fetchEvents(page: 1),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Refresh'),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(EventModel event) {
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
          // Event Image
          if (event.image != null)
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: CachedNetworkImage(
                imageUrl: event.image!,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 180,
                  color: Colors.grey[300],
                  child: const Center(child: SizedBox(height: 40, width: 40, child: CircularProgressIndicator())),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 180,
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
                  // Title and Bookmark
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          event.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      BookmarkButton(
                        itemId: event.id,
                        type: 'event',
                        itemTitle: event.title,
                        itemImage: event.image,
                        metadata: {
                          'location': event.location ?? '',
                          'date': event.eventDate.toString(),
                          'description': event.description,
                          'tags': event.tags,
                        },
                      ),
                    ],
                  children: [
                    const Icon(Icons.calendar_today, size: 16, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('MMM dd, yyyy').format(event.eventDate),
                      style: const TextStyle(fontSize: 14, color: AppColors.textGray),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                // Location
                if (event.location != null)
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          event.location!,
                          style: const TextStyle(fontSize: 14, color: AppColors.textGray),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 12),
                
                // Description
                if (event.description.isNotEmpty)
                  Text(
                    event.description,
                    style: const TextStyle(fontSize: 13, color: AppColors.textGray),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 12),
                
                // Tags and CTA
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (event.tags.isNotEmpty)
                      Wrap(
                        spacing: 4,
                        children: event.tags.take(2).map((tag) => Chip(
                          label: Text(tag, style: const TextStyle(fontSize: 11)),
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                        )).toList(),
                      )
                    else
                      const SizedBox.shrink(),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      child: const Text('View Details', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
