import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:roomix/providers/auth_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _emailNotifications = true;
  bool _pushNotifications = true;
  bool _showLastSeen = true;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    final settings = auth.currentUser?.notificationSettings;
    final privacy = auth.currentUser?.privacySettings;
    _emailNotifications = settings?['emailNotifications'] ?? true;
    _pushNotifications = settings?['pushNotifications'] ?? true;
    _showLastSeen = privacy?['showLastSeen'] ?? true;
  }

  Future<void> _saveSettings() async {
    final auth = context.read<AuthProvider>();
    try {
      await auth.updateSettings({
        'notificationSettings': {
          'emailNotifications': _emailNotifications,
          'pushNotifications': _pushNotifications,
        },
        'privacySettings': {
          'showLastSeen': _showLastSeen,
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Settings saved')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SwitchListTile(
              title: const Text('Email Notifications'),
              value: _emailNotifications,
              onChanged: (v) => setState(() => _emailNotifications = v),
            ),
            SwitchListTile(
              title: const Text('Push Notifications'),
              value: _pushNotifications,
              onChanged: (v) => setState(() => _pushNotifications = v),
            ),
            const Divider(),
            SwitchListTile(
              title: const Text('Show Last Seen'),
              value: _showLastSeen,
              onChanged: (v) => setState(() => _showLastSeen = v),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _saveSettings, child: const Text('Save Settings')),
          ],
        ),
      ),
    );
  }
}
