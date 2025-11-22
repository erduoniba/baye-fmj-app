import 'package:flutter/material.dart';
import 'web_view_page.dart';
import 'utils/app_config.dart';
import 'services/orientation_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AppConfig.shared.initialize();

  // 立即启动应用，不等待其他初始化
  runApp(const MyApp());

  // 后台异步初始化IAP和屏幕方向（不阻塞UI显示）
  _initializeServicesInBackground();
}

/// 在后台异步初始化服务，不阻塞应用启动
Future<void> _initializeServicesInBackground() async {
  try {
    // 并行初始化IAP和屏幕方向
    await Future.wait([
      OrientationService.instance.initialize(
        portraitMode: AppConfig.shared.portraitMode,
      ),
    ]);
  } catch (e) {
    debugPrint('Background services initialization error: $e');
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // 监听AppConfig变化来更新主题
    AppConfig.shared.addListener(_updateTheme);
  }

  @override
  void dispose() {
    AppConfig.shared.removeListener(_updateTheme);
    super.dispose();
  }

  void _updateTheme() {
    setState(() {
      // 触发重建以应用新主题
    });
  }

  @override
  Widget build(BuildContext context) {
    final config = AppConfig.shared;

    return MaterialApp(
      title: config.title,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: config.primaryColor),
        scaffoldBackgroundColor: config.backgroundColor,
        appBarTheme: AppBarTheme(
          backgroundColor: config.appBarBackgroundColor,
          foregroundColor: config.appBarForegroundColor,
          elevation: 1,
        ),
      ),
      // 使用游戏名称作为key，当游戏切换时会重建WebViewPage
      home: WebViewPage(key: ValueKey(config.appName)),
    );
  }
}