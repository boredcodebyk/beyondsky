import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  final _secureStorage = const FlutterSecureStorage();

  AndroidOptions _getAndroidOptions() => const AndroidOptions(
        encryptedSharedPreferences: true,
      );

  Future<void> addLogin(String identifier, String password) async {
    await _secureStorage.write(
        key: identifier, value: password, aOptions: _getAndroidOptions());
  }

  Future<void> removeLogin(String identifier) async {
    await _secureStorage.delete(
        key: identifier, aOptions: _getAndroidOptions());
  }

  Future<List<String>> readAllSecureData() async {
    var allData = await _secureStorage.readAll(aOptions: _getAndroidOptions());
    List<String> list = allData.entries.map((e) => e.toString()).toList();
    return list;
  }
}

final storageServiceProvider = Provider((ref) => StorageService());
