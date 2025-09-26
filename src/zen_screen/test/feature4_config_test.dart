import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:zen_screen/models/algorithm_config.dart';
import 'package:zen_screen/services/algorithm_config_service.dart';

void main() {
  // Initialize Flutter binding for tests
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('Feature 4: Algorithm Config Service Tests', () {
    late AlgorithmConfigService configService;
    late String testConfigPath;

    setUp(() {
      testConfigPath = 'test_earning_algorithm.json';
      configService = AlgorithmConfigService(assetPath: testConfigPath);
    });

    tearDown(() {
      configService.dispose();
      // Clean up test file if it exists
      final testFile = File(testConfigPath);
      if (testFile.existsSync()) {
        testFile.deleteSync();
      }
    });

    group('TC031: Algorithm config load + validation', () {
      test('Should load valid JSON config successfully', () async {
        // Create a valid test config file
        final validConfig = {
          "version": "1.0.0-test",
          "updatedAt": "2025-09-26T00:00:00.000Z",
          "powerPlus": {
            "bonusMinutes": 30,
            "requiredGoals": 3,
            "goals": {
              "sleep": 420,
              "exercise": 45,
              "outdoor": 30,
              "productive": 120
            }
          },
          "categories": {
            "sleep": {
              "label": "Sleep",
              "minutesPerHour": 25,
              "maxMinutes": 540,
              "penalties": {
                "underMinutes": 360,
                "overMinutes": 540,
                "penaltyMinutes": 20
              }
            },
            "exercise": {
              "label": "Exercise",
              "minutesPerHour": 20,
              "maxMinutes": 120
            },
            "outdoor": {
              "label": "Outdoor",
              "minutesPerHour": 15,
              "maxMinutes": 120
            },
            "productive": {
              "label": "Productive",
              "minutesPerHour": 10,
              "maxMinutes": 240
            }
          },
          "dailyCaps": {
            "baseMinutes": 120,
            "powerPlusMinutes": 150
          }
        };

        final testFile = File(testConfigPath);
        await testFile.writeAsString(json.encode(validConfig));

        final config = await configService.loadConfig();

        expect(config.version, equals('1.0.0-test'));
        expect(config.powerPlus.bonusMinutes, equals(30));
        expect(config.categories['sleep']?.minutesPerHour, equals(25));
        expect(config.dailyCaps.baseMinutes, equals(120));
      });

      test('Should validate config schema correctly', () async {
        final validConfig = {
          "version": "1.0.0",
          "updatedAt": "2025-09-26T00:00:00.000Z",
          "powerPlus": {
            "bonusMinutes": 30,
            "requiredGoals": 3,
            "goals": {
              "sleep": 420,
              "exercise": 45,
              "outdoor": 30,
              "productive": 120
            }
          },
          "categories": {
            "sleep": {
              "label": "Sleep",
              "minutesPerHour": 25,
              "maxMinutes": 540,
              "penalties": {
                "underMinutes": 360,
                "overMinutes": 540,
                "penaltyMinutes": 20
              }
            },
            "exercise": {
              "label": "Exercise",
              "minutesPerHour": 20,
              "maxMinutes": 120
            },
            "outdoor": {
              "label": "Outdoor",
              "minutesPerHour": 15,
              "maxMinutes": 120
            },
            "productive": {
              "label": "Productive",
              "minutesPerHour": 10,
              "maxMinutes": 240
            }
          },
          "dailyCaps": {
            "baseMinutes": 120,
            "powerPlusMinutes": 150
          }
        };

        final testFile = File(testConfigPath);
        await testFile.writeAsString(json.encode(validConfig));

        final config = await configService.loadConfig();

        // Verify all required fields are present and valid
        expect(config.version, isNotEmpty);
        expect(config.powerPlus.bonusMinutes, greaterThan(0));
        expect(config.powerPlus.requiredGoals, greaterThan(0));
        expect(config.categories.length, equals(4));
        expect(config.dailyCaps.baseMinutes, greaterThan(0));
        expect(config.dailyCaps.powerPlusMinutes, greaterThan(config.dailyCaps.baseMinutes));
      });
    });

    group('TC032: Config fallback behavior', () {
      test('Should fall back to defaults when config file is missing', () async {
        // Don't create the config file, so it will be missing
        final config = await configService.loadConfig();

        // Should use fallback configuration
        expect(config.version, contains('fallback'));
        expect(config.powerPlus.bonusMinutes, equals(30));
        expect(config.categories.length, equals(4));
        expect(config.dailyCaps.baseMinutes, equals(120));
      });

      test('Should fall back to defaults when config file is corrupted', () async {
        // Create a corrupted JSON file
        final testFile = File(testConfigPath);
        await testFile.writeAsString('{ "invalid": json }');

        final config = await configService.loadConfig();

        // Should use fallback configuration
        expect(config.version, contains('fallback'));
        expect(config.powerPlus.bonusMinutes, equals(30));
      });

      test('Should fall back to defaults when config has invalid schema', () async {
        // Create config with missing required fields
        final invalidConfig = {
          "version": "1.0.0",
          // Missing required fields
        };

        final testFile = File(testConfigPath);
        await testFile.writeAsString(json.encode(invalidConfig));

        final config = await configService.loadConfig();

        // Should use fallback configuration
        expect(config.version, contains('fallback'));
        expect(config.powerPlus.bonusMinutes, equals(30));
      });

      test('Should not crash when fallback is used', () async {
        // Test that the service doesn't crash when using fallback
        expect(() async {
          final config = await configService.loadConfig();
          expect(config, isNotNull);
          expect(config.version, isNotEmpty);
        }, returnsNormally);
      });
    });

    group('Config Caching', () {
      test('Should cache config after first load', () async {
        final validConfig = {
          "version": "1.0.0-cache-test",
          "updatedAt": "2025-09-26T00:00:00.000Z",
          "powerPlus": {
            "bonusMinutes": 30,
            "requiredGoals": 3,
            "goals": {
              "sleep": 420,
              "exercise": 45,
              "outdoor": 30,
              "productive": 120
            }
          },
          "categories": {
            "sleep": {
              "label": "Sleep",
              "minutesPerHour": 25,
              "maxMinutes": 540
            },
            "exercise": {
              "label": "Exercise",
              "minutesPerHour": 20,
              "maxMinutes": 120
            },
            "outdoor": {
              "label": "Outdoor",
              "minutesPerHour": 15,
              "maxMinutes": 120
            },
            "productive": {
              "label": "Productive",
              "minutesPerHour": 10,
              "maxMinutes": 240
            }
          },
          "dailyCaps": {
            "baseMinutes": 120,
            "powerPlusMinutes": 150
          }
        };

        final testFile = File(testConfigPath);
        await testFile.writeAsString(json.encode(validConfig));

        // First load
        final config1 = await configService.loadConfig();
        expect(config1.version, equals('1.0.0-cache-test'));

        // Second load should use cache
        final config2 = await configService.loadConfig();
        expect(config2.version, equals('1.0.0-cache-test'));
        expect(config2, same(config1)); // Should be the same instance
      });

      test('Should force reload when requested', () async {
        final initialConfig = {
          "version": "1.0.0-initial",
          "updatedAt": "2025-09-26T00:00:00.000Z",
          "powerPlus": {
            "bonusMinutes": 30,
            "requiredGoals": 3,
            "goals": {
              "sleep": 420,
              "exercise": 45,
              "outdoor": 30,
              "productive": 120
            }
          },
          "categories": {
            "sleep": {
              "label": "Sleep",
              "minutesPerHour": 25,
              "maxMinutes": 540
            },
            "exercise": {
              "label": "Exercise",
              "minutesPerHour": 20,
              "maxMinutes": 120
            },
            "outdoor": {
              "label": "Outdoor",
              "minutesPerHour": 15,
              "maxMinutes": 120
            },
            "productive": {
              "label": "Productive",
              "minutesPerHour": 10,
              "maxMinutes": 240
            }
          },
          "dailyCaps": {
            "baseMinutes": 120,
            "powerPlusMinutes": 150
          }
        };

        final testFile = File(testConfigPath);
        await testFile.writeAsString(json.encode(initialConfig));

        // First load
        final config1 = await configService.loadConfig();
        expect(config1.version, equals('1.0.0-initial'));

        // Update the config file
        final updatedConfig = Map<String, dynamic>.from(initialConfig);
        updatedConfig['version'] = '1.0.0-updated';
        await testFile.writeAsString(json.encode(updatedConfig));

        // Force reload
        final config2 = await configService.loadConfig(forceReload: true);
        expect(config2.version, equals('1.0.0-updated'));
      });
    });

    group('Config Stream', () {
      test('Should emit config updates through stream', () async {
        final validConfig = {
          "version": "1.0.0-stream-test",
          "updatedAt": "2025-09-26T00:00:00.000Z",
          "powerPlus": {
            "bonusMinutes": 30,
            "requiredGoals": 3,
            "goals": {
              "sleep": 420,
              "exercise": 45,
              "outdoor": 30,
              "productive": 120
            }
          },
          "categories": {
            "sleep": {
              "label": "Sleep",
              "minutesPerHour": 25,
              "maxMinutes": 540
            },
            "exercise": {
              "label": "Exercise",
              "minutesPerHour": 20,
              "maxMinutes": 120
            },
            "outdoor": {
              "label": "Outdoor",
              "minutesPerHour": 15,
              "maxMinutes": 120
            },
            "productive": {
              "label": "Productive",
              "minutesPerHour": 10,
              "maxMinutes": 240
            }
          },
          "dailyCaps": {
            "baseMinutes": 120,
            "powerPlusMinutes": 150
          }
        };

        final testFile = File(testConfigPath);
        await testFile.writeAsString(json.encode(validConfig));

        // Listen to the stream
        final configs = <AlgorithmConfig>[];
        final subscription = configService.configStream.listen((config) {
          configs.add(config);
        });

        // Load config
        await configService.loadConfig();

        // Wait a bit for the stream to emit
        await Future.delayed(Duration(milliseconds: 100));

        // Should have received the config
        expect(configs.length, greaterThanOrEqualTo(1));
        expect(configs.first.version, equals('1.0.0-stream-test'));

        await subscription.cancel();
      });
    });
  });
}
