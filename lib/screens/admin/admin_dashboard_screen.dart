import 'package:flutter/material.dart';
import 'package:roomix/constants/app_colors.dart';
import 'package:roomix/services/api_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _tabIndex = 0;
  bool _loadingUsers = true;
  bool _loadingNotifications = true;
  List<dynamic> _users = [];
  List<dynamic> _notifications = [];
  final TextEditingController _notificationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _loadNotifications();
  }

  Future<void> _loadUsers() async {
    try {
      final response = await ApiService.getAdminUsers();
      setState(() {
        _users = response['users'] ?? [];
        _loadingUsers = false;
      });
    } catch (_) {
      setState(() {
        _loadingUsers = false;
      });
    }
  }

  Future<void> _loadNotifications() async {
    try {
      final response = await ApiService.getAdminNotifications();
      setState(() {
        _notifications = response['notifications'] ?? [];
        _loadingNotifications = false;
      });
    } catch (_) {
      setState(() {
        _loadingNotifications = false;
      });
    }
  }

  Future<void> _toggleBlockUser(String userId, bool isBlocked) async {
    try {
      if (isBlocked) {
        await ApiService.unblockUser(userId);
      } else {
        await ApiService.blockUser(userId);
      }
      await _loadUsers();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e')),
      );
    }
  }

  Future<void> _createNotification() async {
    if (_notificationController.text.trim().isEmpty) return;
    try {
      await ApiService.createAdminNotification(_notificationController.text.trim());
      _notificationController.clear();
      await _loadNotifications();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e')),
      );
    }
  }

  @override
  void dispose() {
    _notificationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: AppColors.primary,
      ),
      body: Column(
        children: [
          Row(
            children: [
              _buildTab('Users', 0),
              _buildTab('Notifications', 1),
              _buildTab('Moderation', 2),
            ],
          ),
          Expanded(
            child: _tabIndex == 0
                ? _buildUsersTab()
                : _tabIndex == 1
                    ? _buildNotificationsTab()
                    : _buildModerationTab(),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String title, int index) {
    final isActive = _tabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tabIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isActive ? AppColors.primary : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isActive ? AppColors.primary : AppColors.textGray,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUsersTab() {
    if (_loadingUsers) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_users.isEmpty) {
      return const Center(child: Text('No users found'));
    }
    return ListView.builder(
      itemCount: _users.length,
      itemBuilder: (context, index) {
        final user = _users[index];
        final isBlocked = user['isBlocked'] == true;
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: AppColors.primary.withOpacity(0.2),
            child: Text(
              (user['name'] ?? 'U').toString().substring(0, 1).toUpperCase(),
              style: const TextStyle(color: AppColors.primary),
            ),
          ),
          title: Text(user['name'] ?? 'Unknown'),
          subtitle: Text('${user['email'] ?? ''} - ${user['role'] ?? ''}'),
          trailing: TextButton(
            onPressed: () => _toggleBlockUser(user['_id'], isBlocked),
            child: Text(isBlocked ? 'Unblock' : 'Block'),
          ),
        );
      },
    );
  }

  Widget _buildNotificationsTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _notificationController,
            decoration: InputDecoration(
              hintText: 'Global notification message',
              suffixIcon: IconButton(
                icon: const Icon(Icons.send_rounded),
                onPressed: _createNotification,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _loadingNotifications
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) {
                      final note = _notifications[index];
                      return Card(
                        child: ListTile(
                          title: Text(note['message'] ?? ''),
                          subtitle: Text(note['createdAt']?.toString() ?? ''),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildModerationTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildModerationCard('Room ID', 'Delete Room', (id) async {
          await ApiService.dio.delete('/admin/rooms/$id');
        }),
        const SizedBox(height: 12),
        _buildModerationCard('Mess ID', 'Delete Mess', (id) async {
          await ApiService.dio.delete('/admin/mess/$id');
        }),
        const SizedBox(height: 12),
        _buildModerationCard('Lost Item ID', 'Delete Lost Item', (id) async {
          await ApiService.dio.delete('/admin/lost/$id');
        }),
        const SizedBox(height: 12),
        _buildModerationCard('Market Item ID', 'Delete Market Item', (id) async {
          await ApiService.dio.delete('/admin/market/$id');
        }),
      ],
    );
  }

  Widget _buildModerationCard(
    String hint,
    String actionLabel,
    Future<void> Function(String id) onDelete,
  ) {
    final controller = TextEditingController();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hint,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (controller.text.trim().isEmpty) return;
                  try {
                    await onDelete(controller.text.trim());
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('$actionLabel success')),
                    );
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed: $e')),
                    );
                  }
                },
                child: Text(actionLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
