import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:roomix/services/map_service.dart';

class MapSettingsScreen extends StatefulWidget {
  const MapSettingsScreen({super.key});

  @override
  State<MapSettingsScreen> createState() => _MapSettingsScreenState();
}

class _MapSettingsScreenState extends State<MapSettingsScreen> {
  final _controller = TextEditingController();
  String _status = '';

  @override
  void initState() {
    super.initState();
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    final p = await SharedPreferences.getInstance();
    final saved = p.getString('runtime_mapmyindia_key') ?? '';
    _controller.text = saved;
    // Apply saved runtime key immediately so preview and app use it
    MapService.runtimeKey = saved.isEmpty ? null : saved;
    setState(() {
      _status = saved.isEmpty ? '' : 'Loaded runtime key';
    });
  }

  Future<void> _saveKey() async {
    final key = _controller.text.trim();
    final p = await SharedPreferences.getInstance();
    await p.setString('runtime_mapmyindia_key', key);
    MapService.runtimeKey = key.isEmpty ? null : key;
    setState(() {
      _status = key.isEmpty ? 'Cleared runtime key' : 'Saved runtime key (for this device)';
    });
  }

  @override
  Widget build(BuildContext context) {
    final previewUrl = MapService.hasApiKey
        ? MapService.generatePreviewUrl(centerLat: 28.5244, centerLng: 77.1855)
        : '';

    return Scaffold(
      appBar: AppBar(title: const Text('Map Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Runtime MapMyIndia API Key (for local testing)'),
            const SizedBox(height: 8),
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter key to test map features',
              ),
            ),
            const SizedBox(height: 12),
            Row(children: [
              ElevatedButton(onPressed: _saveKey, child: const Text('Save & Apply')),
              const SizedBox(width: 12),
              Text(_status),
            ]),
            const SizedBox(height: 24),
            const Text('Preview'),
            const SizedBox(height: 8),
            Expanded(
              child: previewUrl.isEmpty
                  ? Center(child: Text('No API key configured.'))
                  : CachedNetworkImage(
                      imageUrl: previewUrl,
                      fit: BoxFit.cover,
                      placeholder: (c, _) => const Center(child: CircularProgressIndicator()),
                      errorWidget: (c, _, __) => const Center(child: Text('Preview failed to load')),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
