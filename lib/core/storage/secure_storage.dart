import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract final class StorageKeys {
  static const accessToken = 'access_token';
  static const refreshToken = 'refresh_token';
}

class SecureStorageService {
  SecureStorageService(this._storage);

  final FlutterSecureStorage _storage;

  static const _androidOptions = AndroidOptions(
    encryptedSharedPreferences: true,
  );

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      _storage.write(
        key: StorageKeys.accessToken,
        value: accessToken,
        aOptions: _androidOptions,
      ),
      _storage.write(
        key: StorageKeys.refreshToken,
        value: refreshToken,
        aOptions: _androidOptions,
      ),
    ]);
  }

  Future<String?> getAccessToken() async {
    return _storage.read(key: StorageKeys.accessToken, aOptions: _androidOptions);
  }

  Future<String?> getRefreshToken() async {
    return _storage.read(key: StorageKeys.refreshToken, aOptions: _androidOptions);
  }

  Future<void> clearTokens() async {
    await Future.wait([
      _storage.delete(key: StorageKeys.accessToken, aOptions: _androidOptions),
      _storage.delete(key: StorageKeys.refreshToken, aOptions: _androidOptions),
    ]);
  }

  Future<bool> hasValidToken() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
