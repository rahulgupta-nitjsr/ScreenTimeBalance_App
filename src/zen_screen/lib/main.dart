import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';
import 'firebase_options.dart';
import 'utils/app_router.dart';
import 'utils/theme.dart';
import 'providers/navigation_provider.dart';
import 'providers/error_handler_provider.dart';
import 'services/platform_database_service.dart';
import 'widgets/error_boundary.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set up global error handler
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    if (kDebugMode) {
      print('Flutter Error: ${details.exception}');
      print('Stack Trace: ${details.stack}');
    }
  };
  
  // Initialize platform database service
  await PlatformDatabaseService.instance.initialize();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  
  runApp(const ProviderScope(child: ZenScreenApp()));
}

class ZenScreenApp extends ConsumerStatefulWidget {
  const ZenScreenApp({super.key, GoRouter? router}) : _router = router;

  final GoRouter? _router;

  @override
  ConsumerState<ZenScreenApp> createState() => _ZenScreenAppState();
}

class _ZenScreenAppState extends ConsumerState<ZenScreenApp> with WidgetsBindingObserver {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _router = widget._router ?? appRouterFactory(ref: ref);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(ui.AppLifecycleState state) {
    final lifecycleProvider = ref.read(appLifecycleProvider.notifier);
    
    switch (state) {
      case ui.AppLifecycleState.resumed:
        lifecycleProvider.setState(AppLifecycleState.resumed);
        break;
      case ui.AppLifecycleState.paused:
        lifecycleProvider.setState(AppLifecycleState.paused);
        break;
      case ui.AppLifecycleState.inactive:
        lifecycleProvider.setState(AppLifecycleState.inactive);
        break;
      case ui.AppLifecycleState.detached:
        lifecycleProvider.setState(AppLifecycleState.detached);
        break;
      case ui.AppLifecycleState.hidden:
        lifecycleProvider.setState(AppLifecycleState.paused);
        break;
    }
  }

  @override
  void didHaveMemoryPressure() {
    // Handle memory pressure by reducing timer precision
    // This is a system callback when memory is low
    super.didHaveMemoryPressure();
  }

  @override
  Widget build(BuildContext context) {
    // Initialize error handling
    initializeErrorHandling(ref);
    
    return ErrorBoundary(
      child: MaterialApp.router(
        title: 'ZenScreen',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: _router,
      ),
    );
  }
}
