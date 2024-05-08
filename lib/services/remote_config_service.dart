import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

class FirebaseRemoteConfigService {
  FirebaseRemoteConfigService._()
      : _remoteConfig = FirebaseRemoteConfig.instance;

  static FirebaseRemoteConfigService? _instance;
  factory FirebaseRemoteConfigService() =>
      _instance ??= FirebaseRemoteConfigService._();

  final FirebaseRemoteConfig _remoteConfig;

  Future<String> getString(String key) async {
    return _remoteConfig.getString(key);
  }

  Future<bool> getBool(String key) async {
    return _remoteConfig.getBool(key);
  }

  Future<int> getInt(String key) async {
    return _remoteConfig.getInt(key);
  }

  Future<double> getDouble(String key) async {
    return _remoteConfig.getDouble(key);
  }

  Future<void> _setConfigSettings() async => _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(minutes: 1),
          //TODO you may want to change this to a longer duration in production
          minimumFetchInterval: kDebugMode
              ? const Duration(seconds: 30)
              : const Duration(seconds: 30),
        ),
      );

  Future<void> fetchAndActivate() async {
    bool updated = await _remoteConfig.fetchAndActivate();

    _remoteConfig.getAll().forEach((key, value) {
      debugPrint('key: $key, value: ${value.asString()}');
    });

    if (updated) {
      debugPrint('The config has been updated.');
    } else {
      debugPrint('The config is not updated..');
    }
  }

  Future<void> _setDefaults() async => _remoteConfig.setDefaults(
        const {
          FirebaseRemoteConfigKeys.url: 'http://localhost:3000',
        },
      );

  Future<void> initialize() async {
    await _setConfigSettings();
    await _setDefaults();
    await fetchAndActivate();
  }
}

class FirebaseRemoteConfigKeys {
  static const String url = 'url';
}
