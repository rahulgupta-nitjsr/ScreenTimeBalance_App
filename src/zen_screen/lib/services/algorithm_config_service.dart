import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as path;

import '../models/algorithm_config.dart';

/// Service responsible for loading, validating, and caching the earning algorithm configuration.
class AlgorithmConfigService {
  AlgorithmConfigService({
    AlgorithmConfigValidator? validator,
    String? assetPath,
  })  : _validator = validator ?? const AlgorithmConfigValidator(),
        _assetPath = assetPath ?? 'assets/config/earning_algorithm.json';

  final AlgorithmConfigValidator _validator;
  final String _assetPath;

  AlgorithmConfig? _cachedConfig;
  StreamController<AlgorithmConfig>? _controller;
  StreamSubscription<FileSystemEvent>? _fileWatcher;

  Stream<AlgorithmConfig> get configStream {
    _controller ??= StreamController<AlgorithmConfig>.broadcast(onListen: () {
      if (_cachedConfig != null) {
        _controller!.add(_cachedConfig!);
      }
    });
    return _controller!.stream;
  }

  AlgorithmConfig? get cachedConfig => _cachedConfig;

  Future<AlgorithmConfig> loadConfig({bool forceReload = false}) async {
    if (!forceReload && _cachedConfig != null) {
      return _cachedConfig!;
    }

    try {
      final String contents;
      if (kIsWeb) {
        contents = await rootBundle.loadString(_assetPath);
      } else {
        final file = File(_resolveAssetPath(_assetPath));
        if (await file.exists()) {
          contents = await file.readAsString();
        } else {
          contents = await rootBundle.loadString(_assetPath);
        }
      }

      final Map<String, dynamic> jsonMap = json.decode(contents) as Map<String, dynamic>;
      final config = AlgorithmConfig.fromJson(jsonMap);
      _validator.validate(config);
      _cache(config);
      return config;
    } catch (error) {
      // Log error for developer resolution
      if (kDebugMode) {
        print('🚨 AlgorithmConfig Error: $error');
        print('📁 Asset path: $_assetPath');
        print('🔄 Falling back to default configuration');
      }
      
      final fallback = _buildFallbackConfig();
      _cache(fallback);
      return fallback;
    }
  }

  Future<void> refresh() async {
    await loadConfig(forceReload: true);
  }

  /// Enables hot reload for development - watches config file for changes
  void enableHotReload() {
    if (!kDebugMode) return;
    
    try {
      final configFile = File(_resolveAssetPath(_assetPath));
      if (configFile.existsSync()) {
        _fileWatcher = configFile.parent.watch(events: FileSystemEvent.modify).listen((event) {
          if (event.path.endsWith('earning_algorithm.json')) {
            if (kDebugMode) {
              print('🔄 Config file changed, reloading...');
            }
            loadConfig(forceReload: true);
          }
        });
        
        if (kDebugMode) {
          print('✅ Hot reload enabled for algorithm config');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Could not enable hot reload: $e');
      }
    }
  }


  void dispose() {
    _controller?.close();
    _fileWatcher?.cancel();
  }

  void _cache(AlgorithmConfig config) {
    _cachedConfig = config;
    if (_controller != null && !_controller!.isClosed) {
      _controller!.add(config);
    }
  }

  AlgorithmConfig _buildFallbackConfig() {
    final fallback = AlgorithmConfig(
      version: '1.0.0-fallback',
      updatedAt: DateTime.now(),
      powerPlus: PowerPlusConfig(
        bonusMinutes: 30,
        requiredGoals: 3,
        goals: const {
          'sleep': 420,
          'exercise': 45,
          'outdoor': 30,
          'productive': 120,
        },
      ),
      categories: {
        'sleep': CategoryConfig(
          label: 'Sleep',
          minutesPerHour: 25,
          maxMinutes: 540,
          penalties: PenaltyConfig(
            underMinutes: 360,
            overMinutes: 540,
            penaltyMinutes: 20,
          ),
        ),
        'exercise': CategoryConfig(
          label: 'Exercise',
          minutesPerHour: 20,
          maxMinutes: 120,
        ),
        'outdoor': CategoryConfig(
          label: 'Outdoor',
          minutesPerHour: 15,
          maxMinutes: 120,
        ),
        'productive': CategoryConfig(
          label: 'Productive',
          minutesPerHour: 10,
          maxMinutes: 240,
        ),
      },
      dailyCaps: DailyCaps(
        baseMinutes: 120,
        powerPlusMinutes: 150,
      ),
    );
    return fallback;
  }

  String _resolveAssetPath(String assetRelativePath) {
    final scriptDir = File.fromUri(Uri.parse(Platform.script.toString())).parent;
    // go up to project root by finding `pubspec.yaml`
    Directory current = scriptDir;
    while (!File(path.join(current.path, 'pubspec.yaml')).existsSync()) {
      final parent = current.parent;
      if (parent.path == current.path) {
        break;
      }
      current = parent;
    }
    return path.join(current.path, assetRelativePath);
  }
}
