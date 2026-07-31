import 'package:injectable/injectable.dart';
import 'package:pnestaffapp/core/constants/app_constants.dart';
import 'package:pnestaffapp/core/storage/secure_storage_service.dart';

/// The single source of truth for auth tokens. The Dio [AuthInterceptor], the
/// router's auth guard, and the auth feature all read/write session state here.
@lazySingleton
class TokenStorage {
  TokenStorage(this._secure);

  final SecureStorageService _secure;

  Future<String?> readAccessToken() => _secure.read(StorageKeys.accessToken);

  Future<String?> readRefreshToken() => _secure.read(StorageKeys.refreshToken);

  Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    await _secure.write(StorageKeys.accessToken, accessToken);
    if (refreshToken != null) {
      await _secure.write(StorageKeys.refreshToken, refreshToken);
    }
  }

  /// Whether a (non-empty) access token is present.
  Future<bool> hasSession() async {
    final token = await readAccessToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> clear() async {
    await _secure.delete(StorageKeys.accessToken);
    await _secure.delete(StorageKeys.refreshToken);
  }
}
