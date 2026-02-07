import 'package:flutter/foundation.dart';
import 'package:roomix/services/api_service.dart';

class OwnerListingsProvider with ChangeNotifier {
  String? ownerId;

  bool loadingRooms = false;
  bool loadingMess = false;
  String? error;

  List<Map<String, dynamic>> rooms = [];
  List<dynamic> mess = [];

  OwnerListingsProvider([this.ownerId]) {
    if (ownerId != null) {
      fetchAll();
    }
  }

  Future<void> fetchAll() async {
    if (ownerId == null) return;
    await Future.wait([fetchRooms(), fetchMess()]);
  }

  Future<void> fetchRooms() async {
    if (ownerId == null) return;
    loadingRooms = true;
    notifyListeners();
    try {
      final response = await ApiService.dio.get('/rooms', queryParameters: {'ownerId': ownerId});
      final data = response.data;
      List<Map<String, dynamic>> list = [];
      if (data is Map && data['rooms'] is List) {
        list = (data['rooms'] as List).cast<Map<String, dynamic>>();
      } else if (data is List) {
        list = (data as List).cast<Map<String, dynamic>>();
      }
      rooms = list;
      error = null;
    } catch (e) {
      error = 'Failed to fetch rooms: $e';
    } finally {
      loadingRooms = false;
      notifyListeners();
    }
  }

  Future<void> fetchMess() async {
    if (ownerId == null) return;
    loadingMess = true;
    notifyListeners();
    try {
      final response = await ApiService.dio.get('/mess', queryParameters: {'ownerId': ownerId});
      final data = response.data;
      List<dynamic> list = [];
      if (data is Map && data['data'] is List) {
        list = data['data'] as List;
      } else if (data is List) {
        list = data as List;
      }
      mess = list;
      error = null;
    } catch (e) {
      error = 'Failed to fetch mess: $e';
    } finally {
      loadingMess = false;
      notifyListeners();
    }
  }

  Future<bool> deleteRoom(String id) async {
    try {
      await ApiService.dio.delete('/rooms/$id');
      rooms.removeWhere((r) => r['_id'] == id || r['id'] == id);
      notifyListeners();
      return true;
    } catch (e) {
      error = 'Failed to delete room: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteMess(String id) async {
    try {
      await ApiService.dio.delete('/mess/$id');
      mess.removeWhere((m) => m['_id'] == id || m['id'] == id);
      notifyListeners();
      return true;
    } catch (e) {
      error = 'Failed to delete mess: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> editRoom(String id, Map<String, dynamic> updates) async {
    try {
      await ApiService.dio.put('/rooms/$id', data: updates);
      await fetchRooms();
      return true;
    } catch (e) {
      error = 'Failed to update room: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> editMess(String id, Map<String, dynamic> updates) async {
    try {
      await ApiService.dio.put('/mess/$id', data: updates);
      await fetchMess();
      return true;
    } catch (e) {
      error = 'Failed to update mess: $e';
      notifyListeners();
      return false;
    }
  }
}
