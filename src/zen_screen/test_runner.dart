import 'dart:io';

void main() async {
  print('🚀 ZenScreen Test Runner - Systematic Testing Approach');
  print('====================================================');
  
  // Test cases to run individually
  final testCases = [
    // Feature 6 - Already 100% passing
    {'name': 'Feature 6 - All Tests', 'file': 'test/feature6_screen_time_display_test.dart', 'timeout': 15},
    
    // Feature 7 - Individual tests
    {'name': 'TC061 - Timer Display Format', 'file': 'test/feature7_timer_system_test.dart', 'pattern': 'TC061', 'timeout': 15},
    {'name': 'TC062 - Timer Start', 'file': 'test/feature7_timer_system_test.dart', 'pattern': 'TC062', 'timeout': 15},
    {'name': 'TC063 - Timer Stop', 'file': 'test/feature7_timer_system_test.dart', 'pattern': 'TC063', 'timeout': 15},
    {'name': 'TC064 - Timer Pause/Resume', 'file': 'test/feature7_timer_system_test.dart', 'pattern': 'TC064', 'timeout': 15},
    {'name': 'TC065 - Background Continuation', 'file': 'test/feature7_timer_system_test.dart', 'pattern': 'TC065', 'timeout': 15},
    
    // Feature 8 - Individual tests
    {'name': 'TC071 - Single Timer Enforcement', 'file': 'test/feature8_single_activity_enforcement_test.dart', 'pattern': 'TC071', 'timeout': 15},
    {'name': 'TC072 - Conflict Prevention', 'file': 'test/feature8_single_activity_enforcement_test.dart', 'pattern': 'TC072', 'timeout': 15},
  ];
  
  int passed = 0;
  int failed = 0;
  int skipped = 0;
  
  for (final testCase in testCases) {
    print('\n🧪 Running: ${testCase['name']}');
    print('⏱️  Timeout: ${testCase['timeout']}s');
    
    try {
      final result = await Process.run(
        'flutter',
        [
          'test',
          testCase['file'] as String,
          '--timeout=${testCase['timeout']}s',
          if (testCase['pattern'] != null) '--plain-name=${testCase['pattern']}',
        ],
      );
      
      if (result.exitCode == 0) {
        print('✅ PASSED');
        passed++;
      } else {
        print('❌ FAILED');
        print('Error: ${result.stderr}');
        failed++;
      }
    } catch (e) {
      print('⏰ TIMEOUT/SKIPPED: $e');
      skipped++;
    }
  }
  
  print('\n📊 Test Results Summary');
  print('======================');
  print('✅ Passed: $passed');
  print('❌ Failed: $failed');
  print('⏰ Skipped: $skipped');
  print('📈 Success Rate: ${((passed / (passed + failed + skipped)) * 100).toStringAsFixed(1)}%');
}
