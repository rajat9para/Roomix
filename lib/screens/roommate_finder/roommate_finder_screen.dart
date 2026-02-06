import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:roomix/constants/app_colors.dart';
import 'package:roomix/models/chat_message_model.dart';
import 'package:roomix/models/roommate_profile_model.dart';
import 'package:roomix/providers/roommate_provider.dart';
import 'package:roomix/screens/roommate_finder/profile_creation_screen.dart';
import 'package:roomix/screens/roommate_finder/chat_screen.dart';
import 'package:roomix/utils/smooth_navigation.dart';

class RoommateFinderScreen extends StatefulWidget {
  const RoommateFinderScreen({super.key});

  @override
  State<RoommateFinderScreen> createState() => _RoommateFinderScreenState();
}

class _RoommateFinderScreenState extends State<RoommateFinderScreen> {
  int _selectedTabIndex = 0;
  String _filterGender = 'All';
  String _filterYear = 'All';
  String _filterCollege = '';
  String _sortBy = 'Best Match';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<RoommateProvider>();
      provider.getMyProfile();
      provider.getMatches();
      provider.getConversations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Room Partner'),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        elevation: 0,
        actions: [
          Consumer<RoommateProvider>(
            builder: (context, provider, _) => Padding(
              padding: const EdgeInsets.all(16),
              child: GestureDetector(
                onTap: () {
                  if (provider.profileComplete) {
                    _showProfileMenu(context, provider);
                  } else {
                    SmoothNavigation.push(
                      context,
                      const ProfileCreationScreen(),
                    );
                  }
                },
                child: CircleAvatar(
                  backgroundColor: Colors.white.withOpacity(0.3),
                  child: Icon(
                    provider.profileComplete ? Icons.person : Icons.add,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Consumer<RoommateProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            );
          }

          if (!provider.profileComplete) {
            return _buildNoProfileState(context);
          }

          return Column(
            children: [
              // Tab bar
              Container(
                color: AppColors.background,
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedTabIndex = 0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: _selectedTabIndex == 0
                                    ? AppColors.primary
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'Matches (${provider.matches.length})',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: _selectedTabIndex == 0
                                    ? AppColors.primary
                                    : AppColors.textGray,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedTabIndex = 1),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: _selectedTabIndex == 1
                                    ? AppColors.primary
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                          ),
                          child: Center(
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                const Text(
                                  'Chats',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (provider.conversations.any((c) => c.unreadCount > 0))
                                  Positioned(
                                    right: 10,
                                    top: 8,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Text(
                                        '${provider.conversations.where((c) => c.unreadCount > 0).length}',
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
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: _selectedTabIndex == 0
                    ? _buildMatchesTab(context, provider)
                    : _buildChatsTab(context, provider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNoProfileState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.person_add_rounded,
              size: 64,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Create Your Profile',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Start by creating your profile to find\ncompatible roommates',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textGray,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              SmoothNavigation.push(
                context,
                const ProfileCreationScreen(),
              );
            },
            icon: const Icon(Icons.add_rounded),
            label: const Text('Create Profile'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchesTab(BuildContext context, RoommateProvider provider) {
    final filtered = _applyFilters(provider.matches);

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_search_rounded,
              size: 64,
              color: AppColors.textGray.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No matches yet',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textGray,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        _buildFilterBar(),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final match = filtered[index];
              return _buildMatchCard(context, match, provider);
            },
          ),
        ),
      ],
    );
  }

  List<RoommateProfile> _applyFilters(List<RoommateProfile> matches) {
    var filtered = matches.toList();
    if (_filterGender != 'All') {
      filtered = filtered
          .where((m) => m.gender.toLowerCase() == _filterGender.toLowerCase())
          .toList();
    }
    if (_filterYear != 'All') {
      filtered = filtered.where((m) => m.courseYear == _filterYear).toList();
    }
    if (_filterCollege.isNotEmpty) {
      filtered = filtered
          .where((m) =>
              m.college.toLowerCase().contains(_filterCollege.toLowerCase()))
          .toList();
    }

    switch (_sortBy) {
      case 'Year':
        filtered.sort((a, b) => a.courseYear.compareTo(b.courseYear));
        break;
      case 'College':
        filtered.sort((a, b) => a.college.compareTo(b.college));
        break;
      case 'Best Match':
      default:
        filtered.sort((a, b) => (b.compatibility ?? 0).compareTo(a.compatibility ?? 0));
        break;
    }
    return filtered;
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildDropdown(_filterGender, ['All', 'girls', 'boys', 'other'], (v) {
                setState(() => _filterGender = v);
              })),
              const SizedBox(width: 8),
              Expanded(child: _buildDropdown(_filterYear, ['All', '1st Year', '2nd Year', '3rd Year', '4th Year', 'PG / Masters'], (v) {
                setState(() => _filterYear = v);
              })),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Filter by college',
                    prefixIcon: const Icon(Icons.school_rounded, size: 18),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (val) => setState(() => _filterCollege = val),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 130,
                child: _buildDropdown(_sortBy, ['Best Match', 'Year', 'College'], (v) {
                  setState(() => _sortBy = v);
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(String value, List<String> options, ValueChanged<String> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          items: options.map((opt) => DropdownMenuItem(value: opt, child: Text(opt))).toList(),
          onChanged: (val) {
            if (val != null) onChanged(val);
          },
        ),
      ),
    );
  }

  Widget _buildMatchCard(
    BuildContext context,
    RoommateProfile match,
    RoommateProvider provider,
  ) {
    final compatibility = match.compatibility ?? _calculateCompatibility(match, provider.myProfile);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.background,
              AppColors.background.withOpacity(0.8),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        match.userName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        match.userEmail,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textGray,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$compatibility% match',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              match.bio,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textGray,
              ),
            ),
            const SizedBox(height: 12),
            if (match.interests.isNotEmpty)
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: match.interests.take(3).map((interest) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      interest,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.primary,
                      ),
                    ),
                  );
                }).toList(),
              ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  provider.selectedConversationId == match.userId
                      ? SmoothNavigation.push(
                          context,
                          ChatScreen(
                            conversationId: match.userId,
                            userName: match.userName,
                          ),
                        )
                      : SmoothNavigation.push(
                          context,
                          ChatScreen(
                            conversationId: match.userId,
                            userName: match.userName,
                          ),
                        );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Message',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatsTab(BuildContext context, RoommateProvider provider) {
    if (provider.conversations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline_rounded,
              size: 64,
              color: AppColors.textGray.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No conversations yet',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textGray,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.conversations.length,
      itemBuilder: (context, index) {
        final conversation = provider.conversations[index];
        return _buildConversationTile(context, conversation, provider);
      },
    );
  }

  Widget _buildConversationTile(
    BuildContext context,
    ChatConversation conversation,
    RoommateProvider provider,
  ) {
    return GestureDetector(
      onTap: () {
        SmoothNavigation.push(
          context,
          ChatScreen(
            conversationId: conversation.userId,
            userName: conversation.userName,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.border,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.primary.withOpacity(0.3),
              child: Text(
                conversation.userName.isNotEmpty
                    ? conversation.userName[0].toUpperCase()
                    : 'U',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    conversation.userName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    conversation.lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textGray,
                    ),
                  ),
                ],
              ),
            ),
            if (conversation.unreadCount > 0)
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${conversation.unreadCount}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showProfileMenu(BuildContext context, RoommateProvider provider) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_rounded),
              title: const Text('Edit Profile'),
              onTap: () {
                Navigator.pop(context);
                SmoothNavigation.push(
                  context,
                  const ProfileCreationScreen(isEditing: true),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_rounded, color: Colors.red),
              title: const Text('Delete Profile', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(context, provider);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, RoommateProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Profile?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await provider.deleteProfile();
              Navigator.pop(context);
              setState(() {});
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  int _calculateCompatibility(
    RoommateProfile match,
    RoommateProfile? currentUser,
  ) {
    if (currentUser == null) {
      return 70;
    }

    final currentInterests = currentUser.interests.toSet();
    final matchInterests = match.interests.toSet();
    if (currentInterests.isEmpty || matchInterests.isEmpty) {
      return 70;
    }

    final shared = currentInterests.intersection(matchInterests).length;
    final total = currentInterests.union(matchInterests).length;
    final score = (shared / total * 100).round();
    return score.clamp(40, 98);
  }
}
