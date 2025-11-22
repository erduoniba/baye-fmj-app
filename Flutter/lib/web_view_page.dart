import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'offline_package_manager.dart';
import 'utils/log_utils.dart';
import 'utils/app_config.dart';
import 'utils/js_bridge.dart';
import 'utils/platform_utils.dart';


class WebViewPage extends StatefulWidget {
  const WebViewPage({super.key});

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  InAppWebViewController? _controller;
  String? _offlineDirPath;
  bool _isLoading = true;
  String? _currentUrl;
  final AppName _currentGame = AppConfig.shared.appName;
  bool _isOnChoosePage = false;
  Map<String, String> _libsList = {};
  bool _showLibSwitchButton = false;
  String? _currentModName;

  void _logGameEngineErrorContext(String? errorMessage) {
    if (errorMessage == null) return;
    
    // Parse error details
    if (errorMessage.contains('line:') && errorMessage.contains('column:')) {
      final lineMatch = RegExp(r'line:\s*(\d+)').firstMatch(errorMessage);
      final columnMatch = RegExp(r'column:\s*(\d+)').firstMatch(errorMessage);
      
      if (lineMatch != null && columnMatch != null) {
        final line = lineMatch.group(1);
        final column = columnMatch.group(1);
        LogUtils.d("Error location: Line $line, Column $column in baye.js");
      }
    }
    
    // Check for common error patterns
    if (errorMessage.contains('Cannot read properties of undefined')) {
      LogUtils.d("Possible cause: Accessing property on undefined object - may affect game features");
    }
  }

  void _loadUrl(String url) {
    if (_currentUrl != url && _controller != null) {
      // For 三国霸业, check if we're trying to load index.html and redirect to choose.html
      if (AppConfig.shared.appName == AppName.hdBayeApp && url.endsWith('/index.html')) {
        LogUtils.d("_loadUrl中检测到 index.html 请求，重定向到 choose.html");
        final newUrl = url.replaceAll('/index.html', '/choose.html');
        LogUtils.d("原始URL: $url -> 重定向URL: $newUrl");
        _currentUrl = newUrl;
        final fileUri = Uri.parse('file://$newUrl');
        _controller!.loadUrl(urlRequest: URLRequest(url: WebUri.uri(fileUri)));
      } else {
        LogUtils.d("_loadUrl正常加载: $url");
        _currentUrl = url;
        
        // 统一使用 loadUrl 方法加载所有游戏
        final fileUri = Uri.parse('file://$url');
        _controller!.loadUrl(urlRequest: URLRequest(url: WebUri.uri(fileUri)));
      }
    }
  }

  Future<void> _initializeGame() async {
    try {
      // 先检查服务器更新
      await _checkForOfflinePackageUpdate();
      
      // 然后解压离线包
      final dirPath = await OfflinePackageManager.unzipOfflinePackageIfNeeded();
      if (mounted) {
        setState(() {
          _offlineDirPath = dirPath;
          _isLoading = false;
          LogUtils.d('离线包目录路径: $dirPath');
          final indexPage = AppConfig.shared.indexPageName;
          final htmlPath = '$dirPath/$indexPage';
          LogUtils.d('HTML文件完整路径: $htmlPath');
          if (_controller != null) {
            _loadUrl(htmlPath);
          }
        });
      }
    } catch (e) {
      LogUtils.d('游戏初始化失败: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// 检查离线包更新
  Future<void> _checkForOfflinePackageUpdate() async {
    try {
      LogUtils.d('开始检查离线包更新...');
      
      final hasUpdate = await OfflinePackageManager.checkAndAutoUpdate(
        onStatusChange: (message) {
          LogUtils.d('更新状态: $message');
          // 可以在这里显示状态信息给用户
        },
        onProgress: (progress) {
          LogUtils.d('更新进度: ${(progress * 100).toInt()}%');
          // 可以在这里显示下载进度
        },
      );

      if (hasUpdate) {
        LogUtils.d('离线包已更新到最新版本');
        // 可以在这里显示更新成功的提示
      } else {
        LogUtils.d('当前已是最新版本，无需更新');
      }
    } catch (e) {
      LogUtils.d('检查离线包更新失败: $e');
      // 即使更新失败，也继续正常的初始化流程
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeModName();
    _initializeGame();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _initializeModName() {
    if (_currentGame == AppName.hdFmjApp) {
      final choiceLib = AppConfig.shared.choiceLib;
      final modKey = choiceLib['key'];
      
      // 优先使用 _libsList 中的 value，如果找不到则使用 choiceLib 中的 value
      if (modKey != null && _libsList.containsKey(modKey)) {
        _currentModName = _libsList[modKey];
      } else if (choiceLib['value'] != null) {
        _currentModName = choiceLib['value'];
      }
    }
  }

  bool _canGoBack = false;

  void _applyCurrentSettings() {
    final config = AppConfig.shared;

    // 首先重置所有激励效果（每次页面加载都重置）
    JSBridge.resetRewardEffects();

    // 只对伏魔记应用相关设置，避免干扰其他游戏
    if (config.appName == AppName.hdFmjApp) {
      JSBridge.updateColorFilter(config.selectedFilter);
      JSBridge.updateGameSpeed(config.gameSpeed);
      JSBridge.updatePortraitMode(config.portraitMode);
      JSBridge.updateMapDisplay(config.showMapContainer);
      JSBridge.updateCombatProbability(config.combatProbability);
    } else if (config.appName == AppName.hdBayeApp) {
      // 三国霸业只应用基本设置
      JSBridge.updateGameSpeed(config.gameSpeed);
    }
  }


  void _setFmjEngineVersionImmediate(InAppWebViewController controller) {
    // 立即同步设置localStorage，不等待异步操作
    final script = """
      console.log('=== FMJ Engine Debug Info ===');
      console.log('Before setting - localStorage fmjcorev2:', localStorage.getItem('fmjcorev2'));
      console.log('Before setting - window.fmjcorev2:', window.fmjcorev2);
      localStorage.setItem('fmjcorev2', 'true');
      console.log('After setting - localStorage fmjcorev2:', localStorage.getItem('fmjcorev2'));
      // 重新执行m-native-bridge.js中的逻辑
      window.fmjcorev2 = localStorage.getItem("fmjcorev2") === "true" || localStorage.getItem("fmjcorev2") === null;
      console.log('After logic - window.fmjcorev2:', window.fmjcorev2);
      console.log('=== End Debug Info ===');
    """;

    controller.evaluateJavascript(source: script).catchError((e) {
      LogUtils.d("立即设置伏魔记引擎版本失败: $e");
    });
  }

  Future<void> _setFmjEngineVersion() async {
    if (_controller == null) return;

    try {
      // 设置伏魔记引擎版本，始终使用新引擎
      final script = """
        window.fmjcorev2 = true;
        localStorage.setItem('fmjcorev2', 'true');
      """;

      await _controller!.evaluateJavascript(source: script);
      LogUtils.d("设置伏魔记引擎版本成功: 使用新引擎");
    } catch (e) {
      LogUtils.d("设置伏魔记引擎版本失败: $e");
    }
  }

  Future<void> _refreshLibInfo() async {
    LogUtils.d("_refreshLibInfo called - currentGame: $_currentGame, controller: ${_controller?.hashCode}");
    
    if (_currentGame != AppName.hdFmjApp || _controller == null) {
      LogUtils.d("跳过获取游戏列表 - 当前游戏: $_currentGame, WebView控制器: ${_controller?.hashCode}");
      return;
    }
    
    // 只有通过JavaScript API成功获取到游戏列表时才显示按钮
    try {
      final result = await _controller!.evaluateJavascript(source: "window.libsList && window.libsList()");
      if (result is Map && result.isNotEmpty) {
        final libsMap = Map<String, String>.from(result);
        setState(() {
          _libsList = libsMap;
          _showLibSwitchButton = true;
          // 更新标题显示
          _initializeModName();
        });
        LogUtils.d("成功获取到游戏列表: $_libsList");
      } else {
        LogUtils.d("JavaScript API返回空值或非Map类型，隐藏切换按钮");
        setState(() {
          _libsList = {};
          _showLibSwitchButton = false;
        });
      }
    } catch (e) {
      LogUtils.d("获取游戏列表失败，隐藏切换按钮: $e");
      setState(() {
        _libsList = {};
        _showLibSwitchButton = false;
      });
    }
  }

  Future<void> _showLibSwitchDialog() async {
    LogUtils.d("_showLibSwitchDialog called - libsList: $_libsList");
    
    if (_libsList.isEmpty) {
      LogUtils.d("游戏列表为空，无法显示对话框");
      return;
    }

    LogUtils.d("显示游戏切换对话框");
    await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        final sortedLibs = _libsList.entries.toList()..sort((a, b) => a.value.compareTo(b.value));

        return AlertDialog(
          title: const Text('切换游戏', style: TextStyle(fontSize: 18)),
          titlePadding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
          contentPadding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('切换前记得存档！', style: TextStyle(fontSize: 14)),
                const SizedBox(height: 8),
                // 游戏选项按钮
                ...sortedLibs.map((entry) => SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(true);
                          _performLibSwitch(entry.key, entry.value);
                        },
                        style: TextButton.styleFrom(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          minimumSize: const Size(0, 32),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          entry.value,
                          style: const TextStyle(fontSize: 15),
                        ),
                      ),
                    )),
              ],
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(10, 0, 10, 8),
          actions: [
            // 取消按钮
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('取消'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performLibSwitch(String key, String value) async {
    if (_controller == null) return;

    LogUtils.d("执行游戏切换: $key -> $value");
    
    try {
      // CRITICAL: Store the OLD MOD info before changing configuration
      final oldChoiceLib = Map<String, String>.from(AppConfig.shared.choiceLib);
      final oldModKey = oldChoiceLib['key'] ?? 'FMJ';
      final oldModName = oldChoiceLib['value'] ?? '伏魔记';
      
      LogUtils.d("保存当前MOD数据: $oldModKey ($oldModName) -> 切换到: $key ($value)");
      
      // Update current mod name from _libsList if available, otherwise use provided value
      setState(() {
        _currentModName = _libsList.containsKey(key) ? _libsList[key] : value;
      });
      
      // CRITICAL: Force save current game data with OLD MOD prefix
      // This ensures current save data is preserved with correct OLD MOD prefix
      if (_currentGame == AppName.hdFmjApp) {
        LogUtils.d("强制保存当前MOD存档数据 (使用旧MOD前缀: $oldModKey)...");
        
        // Force H5 to save current game state by calling a save trigger
        await _controller!.evaluateJavascript(source: """
          // Try to trigger game save if the function exists
          if (typeof window.forceSaveGame === 'function') {
            window.forceSaveGame();
          }
          // Manually save localStorage data to native with regular sysStorageSet
          var fmjSaveKeys = ['sav/fmjsave0', 'sav/fmjsave1', 'sav/fmjsave2', 'sav/fmjsave3', 'sav/fmjsave4'];
          for (var i = 0; i < fmjSaveKeys.length; i++) {
            var saveKey = fmjSaveKeys[i];
            var value = localStorage.getItem(saveKey);
            if (value && value.length > 0) {
              // Use regular sysStorageSet handler
              window.flutter_inappwebview.callHandler('sysStorageSet', {
                path: saveKey, 
                value: value
              });
            }
          }
        """);
        
        // Small delay to allow save operations to complete
        await Future.delayed(const Duration(milliseconds: 200));
        LogUtils.d("当前MOD存档数据保存完成 (使用旧MOD前缀: $oldModKey)");
      }
      
      // Update choice lib in AppConfig AFTER saving current data with old prefix
      AppConfig.shared.choiceLib = {'key': key, 'value': value};
      LogUtils.d("切换MOD配置: ${AppConfig.shared.choiceLib}");
      
      // Simple localStorage update
      await _controller!.evaluateJavascript(source: "localStorage.setItem('choiceLibName', '$key');");
      LogUtils.d("已设置localStorage: choiceLibName = $key");
      
      // Pre-inject FMJ cache data with new MOD before reload
      // This ensures save data is available immediately when H5 initializes
      if (_currentGame == AppName.hdFmjApp) {
        await JSBridge.injectFmjCacheJSHooks();
        LogUtils.d("Pre-injected FMJ cache for new MOD: $key");
      }
      
      // Force reload of the WebView to load new mod
      if (_offlineDirPath != null) {
        final indexPage = AppConfig.shared.indexPageName;
        final fullPath = '$_offlineDirPath/$indexPage';
        LogUtils.d("强制重新加载WebView以加载新mod: $fullPath");
        
        // Force reload by directly calling controller.loadUrl, bypassing _loadUrl cache check
        final fileUri = Uri.parse('file://$fullPath');
        await _controller!.loadUrl(urlRequest: URLRequest(url: WebUri.uri(fileUri)));
        _currentUrl = fullPath; // Update current URL
        
        // Re-apply FMJ settings after mod switch
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted && _currentGame == AppName.hdFmjApp) {
            // Re-set engine version for the new mod
            _setFmjEngineVersion();
          }
        });
        
        // Additional injection after page loads to ensure data consistency
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted && _currentGame == AppName.hdFmjApp) {
            JSBridge.injectFmjCacheJSHooks();
          }
        });
      }
      
      LogUtils.d("游戏切换完成: $value");
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('已切换到: $value'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
      
    } catch (e) {
      LogUtils.d("游戏切换失败: $e");
      
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('切换失败: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// 验证伏魔记核心文件完整性
  Future<void> _verifyFmjCoreFilesIntegrity() async {
    try {
      final isValid = await OfflinePackageManager.verifyFmjCoreFiles();
      
      if (!isValid) {
        LogUtils.d("❌ 伏魔记核心文件完整性验证失败");
        
        // 显示警告对话框
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('安全警告'),
                content: const Text('检测到游戏文件可能被篡改，为确保游戏正常运行，将重新初始化游戏文件。'),
                actions: [
                  TextButton(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      await _reinitializeFmjFiles();
                    },
                    child: const Text('重新初始化'),
                  ),
                ],
              );
            },
          );
        }
      } else {
        LogUtils.d("✅ 伏魔记核心文件完整性验证通过");
      }
    } catch (e) {
      LogUtils.d("验证伏魔记核心文件完整性失败: $e");
    }
  }

  /// 重新初始化伏魔记文件
  Future<void> _reinitializeFmjFiles() async {
    try {
      LogUtils.d("开始重新初始化伏魔记文件...");
      
      // 清除保存的哈希值
      await OfflinePackageManager.clearFmjCoreFilesHashes();
      
      // 清理当前游戏的离线包缓存，强制重新解压
      await OfflinePackageManager.clearCurrentGameCache();
      
      // 重新初始化游戏
      setState(() {
        _isLoading = true;
      });
      
      _controller = null;
      _offlineDirPath = null;
      _currentUrl = null;
      
      await _initializeGame();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('游戏文件已重新初始化'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      
      LogUtils.d("伏魔记文件重新初始化完成");
    } catch (e) {
      LogUtils.d("重新初始化伏魔记文件失败: $e");
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('重新初始化失败: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// Toggle map container display (controlled by reward ads only)
  Future<void> _toggleMapContainer() async {
    final config = AppConfig.shared;

    // Simple toggle - no usage limits, controlled by reward ads in about page
    final newState = !config.showMapContainer;
    setState(() {
      config.showMapContainer = newState;
    });

    // Update JS
    JSBridge.updateMapDisplay(newState);

    LogUtils.d("Map container toggled to: $newState");
  }


  @override
  Widget build(BuildContext context) {
    // 获取屏幕方向
    final orientation = MediaQuery.of(context).orientation;
    final isLandscape = orientation == Orientation.landscape;
    // 横屏模式下减小底部padding，竖屏模式保持原值
    final bottomPadding = isLandscape ? 0.0 : 40.0;

    return Scaffold(
      backgroundColor: AppConfig.shared.webViewBackgroundColor,
      appBar: AppBar(
        toolbarHeight: isLandscape ? 26.0 : kToolbarHeight,  // 横屏模式降低导航栏高度（40 - 16 = 24）
        title: Text(
          _currentModName ?? AppConfig.shared.title,
          style: TextStyle(
            color: AppConfig.shared.appBarForegroundColor,
            fontSize: isLandscape ? 14.0 : 18.0,  // 横屏和竖屏都减小字体
          ),
        ),
        backgroundColor: AppConfig.shared.appBarBackgroundColor,
        iconTheme: IconThemeData(
          size: isLandscape ? 20.0 : 24.0,  // 横屏模式减小图标
        ),
        leading: _currentGame == AppName.hdFmjApp && _showLibSwitchButton
            ? IconButton(
                iconSize: isLandscape ? 20.0 : 24.0,
                icon: Icon(Icons.swap_horiz, color: AppConfig.shared.appBarForegroundColor),
                onPressed: () {
                  LogUtils.d("切换按钮被点击");
                  _showLibSwitchDialog();
                },
                tooltip: '切换游戏',
              )
            : (_canGoBack && !_isOnChoosePage ? IconButton(
                iconSize: isLandscape ? 20.0 : 24.0,
                icon: const Icon(Icons.arrow_back),
                onPressed: () async {
                  final canGoBack = await _controller?.canGoBack() ?? false;
                  LogUtils.d("Current canGoBack value: $canGoBack, Controller: ${_controller?.hashCode}");
                  if (canGoBack && _controller != null) {
                    // For 三国霸业, index.html requests are already intercepted, so just go back normally
                    await _controller!.goBack();
                  }
                },
              ) : null),
        actions: [
          
        ],
      ),
      body: SafeArea(
        top: false,  // 禁用顶部安全区域，让WebView延伸到状态栏下方
        bottom: true,  // 保持底部安全区域
        child: Stack(
          children: [
            if (!_isLoading)
              Padding(
                padding: EdgeInsets.only(bottom: bottomPadding),
                child: InAppWebView(
              initialSettings: InAppWebViewSettings(
                useShouldOverrideUrlLoading: true,
                mediaPlaybackRequiresUserGesture: false,
                javaScriptEnabled: true,
                allowFileAccessFromFileURLs: true,
                allowUniversalAccessFromFileURLs: true,
                useOnLoadResource: true,
                useHybridComposition: true,
                useShouldInterceptRequest: true,
                allowFileAccess: true,
                allowContentAccess: true,
                domStorageEnabled: true,
              ),
              onWebViewCreated: (InAppWebViewController controller) {
                _controller = controller;
                JSBridge.setup(controller);
                LogUtils.d("InAppWebView onWebViewCreated with controller: ${controller.hashCode}");
                if (kDebugMode && PlatformUtils.isIOS) {
                  var settings = InAppWebViewSettings(isInspectable: true);
                  _controller?.setSettings(settings: settings);
                }
                
                // 为伏魔记预先设置引擎版本到localStorage - 必须在加载页面之前
                if (_currentGame == AppName.hdFmjApp) {
                  _setFmjEngineVersionImmediate(controller);
                  // 给JavaScript执行时间，然后再加载页面
                  Future.delayed(const Duration(milliseconds: 100), () {
                    if (_offlineDirPath != null) {
                      final indexPage = AppConfig.shared.indexPageName;
                      final fullPath = '$_offlineDirPath/$indexPage';
                      LogUtils.d("伏魔记WebView延迟加载页面: $fullPath");
                      _loadUrl(fullPath);
                    }
                  });
                } else {
                  // 非伏魔记游戏立即加载
                  if (_offlineDirPath != null) {
                    final indexPage = AppConfig.shared.indexPageName;
                    final fullPath = '$_offlineDirPath/$indexPage';
                    LogUtils.d("WebView创建完成，准备加载页面: $fullPath");
                    LogUtils.d("当前游戏: ${AppConfig.shared.appName}, 索引页面: $indexPage");
                    _loadUrl(fullPath);
                  }
                }
              },
              onLoadStart: (controller, url) {
                LogUtils.d("WebView onLoadStart - URL: ${url?.toString()}, Controller: ${controller.hashCode}");
                LogUtils.d("WebView onLoadStart - Scheme: ${url?.scheme}, Host: ${url?.host}, Path: ${url?.path}");
                
                // 为伏魔记检测页面刷新或重新加载
                if (_currentGame == AppName.hdFmjApp && url?.scheme == "file" && (url?.path.endsWith('/index.html') ?? false)) {
                  LogUtils.d("检测到伏魔记页面刷新，将进行核心文件验证");
                }
                
                // 为伏魔记在页面开始加载时立即设置引擎版本
                if (_currentGame == AppName.hdFmjApp && url?.scheme == "file") {
                  _setFmjEngineVersionImmediate(controller);
                }
                
                if (url?.scheme == "file") {
                  final path = url?.path ?? '';
                  
                  // For 三国霸业 game, intercept index.html in onLoadStart as well
                  if (AppConfig.shared.appName == AppName.hdBayeApp && path.endsWith('/index.html')) {
                    LogUtils.d("onLoadStart中拦截到 index.html 加载，停止加载并重定向到 choose.html");
                    if (_offlineDirPath != null) {
                      final chooseHtmlPath = '$_offlineDirPath/choose.html';
                      // 使用小延迟确保当前加载被停止
                      Future.delayed(const Duration(milliseconds: 50), () {
                        controller.stopLoading();
                        final fileUri = Uri.parse('file://$chooseHtmlPath');
                        controller.loadUrl(
                          urlRequest: URLRequest(url: WebUri.uri(fileUri)),
                        );
                      });
                    }
                    return;
                  }
                }
              },
              // Handle JavaScript alerts to prevent popups
              onJsAlert: (controller, jsAlertRequest) async {
                final message = jsAlertRequest.message;
                final url = jsAlertRequest.url;
                
                // Log the alert message instead of showing popup
                LogUtils.d("JavaScript Alert intercepted - URL: $url, Message: $message");
                
                // Check if it's an error message and log it properly
                if (message?.contains('Error:') == true || 
                    message?.contains('TypeError:') == true || 
                    message?.contains('Uncaught') == true) {
                  LogUtils.d("JavaScript Error caught: $message");
                  LogUtils.d("Error URL: ${url?.toString()}");
                  
                  // Extract more error details if available
                  if (message?.contains('baye.js') == true) {
                    LogUtils.d("Error in game engine file - this may affect game functionality");
                    // Try to get more context about the error
                    _logGameEngineErrorContext(message);
                  }
                }
                
                // Return JsAlertResponse to dismiss the alert without showing popup
                return JsAlertResponse(
                  handledByClient: true, // We handle it, don't show system alert
                );
              },
              
              // Handle JavaScript console messages
              onConsoleMessage: (controller, consoleMessage) {
                final message = consoleMessage.message;
                final level = consoleMessage.messageLevel;
                
                // Log console messages based on their level
                switch (level) {
                  case ConsoleMessageLevel.ERROR:
                    LogUtils.d("JavaScript Console Error: $message");
                    break;
                  case ConsoleMessageLevel.WARNING:
                    LogUtils.d("JavaScript Console Warning: $message");
                    break;
                  case ConsoleMessageLevel.LOG:
                    LogUtils.d("JavaScript Console Log: $message");
                    break;
                  case ConsoleMessageLevel.DEBUG:
                    LogUtils.d("JavaScript Console Debug: $message");
                    break;
                  default:
                    LogUtils.d("JavaScript Console: $message");
                }
              },
              
              onLoadStop: (controller, url) {
                LogUtils.d("WebView onLoadStop - URL: ${url?.toString()}, Controller: ${controller.hashCode}");
                controller.canGoBack().then((value) {
                  LogUtils.d("canGoBack value: $value, Controller: ${controller.hashCode}");
                  
                  // For 三国霸业, check if current page is choose.html to control back button visibility
                  final isOnChoosePage = AppConfig.shared.appName == AppName.hdBayeApp && 
                                        url != null && url.path.endsWith('/choose.html');
                  
                  setState(() {
                    _canGoBack = value;
                    _isOnChoosePage = isOnChoosePage;
                    LogUtils.d("_canGoBack state updated to: $_canGoBack");
                    LogUtils.d("_isOnChoosePage state updated to: $_isOnChoosePage");
                  });
                });
                
                // For 三国霸业, apply settings when choose.html loads
                if (AppConfig.shared.appName == AppName.hdBayeApp && 
                    url != null && url.path.endsWith('/choose.html')) {
                  LogUtils.d("三国霸业 choose.html 加载完成，应用最新设置");
                  // Small delay to ensure page is ready
                  Future.delayed(const Duration(milliseconds: 500), () {
                    _applyCurrentSettings();
                  });
                }
                
                // For 伏魔记, verify core files integrity when index.html loads
                if (AppConfig.shared.appName == AppName.hdFmjApp && 
                    url != null && url.path.endsWith('/index.html')) {
                  LogUtils.d("伏魔记 index.html 加载完成，验证核心文件完整性");
                  _verifyFmjCoreFilesIntegrity();
                }
                
                // Inject performance timing script
                controller.evaluateJavascript(source: JSBridge.performanceTimingScript);
                
                // Disable touch callout
                JSBridge.disableTouchCallout();
                
                // Apply current settings
                _applyCurrentSettings();
                
                // For 伏魔记, set engine version and refresh lib info after page loads
                if (_currentGame == AppName.hdFmjApp) {
                  // 设置伏魔记引擎版本
                  _setFmjEngineVersion();
                  
                  // 注入伏魔记缓存JS钩子
                  Future.delayed(const Duration(milliseconds: 800), () {
                    if (mounted) {
                      JSBridge.injectFmjCacheJSHooks();
                    }
                  });
                  
                  // 轻量级的延迟获取游戏列表，不干扰主要加载过程
                  Future.delayed(const Duration(milliseconds: 1500), () {
                    if (mounted && _controller != null) {
                      _refreshLibInfo();
                    }
                  });
                }
                
                // For 三国霸业, initialize MOD and inject cache hooks after page loads
                if (_currentGame == AppName.hdBayeApp) {
                  // 先初始化三国霸业MOD，然后注入存档
                  Future.delayed(const Duration(milliseconds: 500), () async {
                    if (mounted) {
                      await JSBridge.initializeBayeLib(); // 初始化MOD标识
                      await JSBridge.injectBayeCacheJSHooks(); // 注入对应MOD的存档
                    }
                  });
                }
                
                // For 伏魔记, initialize MOD and inject cache hooks after page loads
                if (_currentGame == AppName.hdFmjApp) {
                  // 先初始化伏魔记MOD，然后注入存档
                  Future.delayed(const Duration(milliseconds: 500), () async {
                    if (mounted) {
                      await JSBridge.initializeFmjLib(); // 初始化MOD标识
                      await JSBridge.injectFmjCacheJSHooks(); // 注入对应MOD的存档
                    }
                  });
                }
              },
              shouldOverrideUrlLoading: (controller, navigationAction) async {
                LogUtils.d("shouldOverrideUrlLoading triggered - Controller: ${controller.hashCode}");
                var uri = navigationAction.request.url;
                if (uri == null) {
                  LogUtils.d("URL is null, cancelling navigation");
                  return NavigationActionPolicy.CANCEL;
                }
                
                LogUtils.d("Processing URL: ${uri.toString()}");
                if (uri.scheme == "file") {
                  final path = uri.path;
                  LogUtils.d("Processing file path: $path");
                  
                  // For 三国霸业 game, completely prevent index.html loading and load choose.html instead
                  if (AppConfig.shared.appName == AppName.hdBayeApp && path.endsWith('/index.html')) {
                    LogUtils.d("shouldOverrideUrlLoading中拦截 index.html 加载请求，直接加载 choose.html");
                    LogUtils.d("原始请求路径: $path");
                    // Cancel the original request and load choose.html immediately
                    if (_offlineDirPath != null) {
                      final chooseHtmlPath = '$_offlineDirPath/choose.html';
                      LogUtils.d("重定向到: $chooseHtmlPath");
                      final fileUri = Uri.parse('file://$chooseHtmlPath');
                      controller.loadUrl(
                        urlRequest: URLRequest(url: WebUri.uri(fileUri)),
                      );
                    } else {
                      LogUtils.d("警告: _offlineDirPath 为空，无法重定向");
                    }
                    return NavigationActionPolicy.CANCEL;
                  }
                  
                  // For 三国霸业 game, allow choose.html to load normally
                  if (AppConfig.shared.appName == AppName.hdBayeApp && path.endsWith('/choose.html')) {
                    LogUtils.d("允许 choose.html 正常加载");
                    return NavigationActionPolicy.ALLOW;
                  }
                }
                return NavigationActionPolicy.ALLOW;
              },
              onLoadResource: (controller, resource) {
                LogUtils.d("Loading resource: ${resource.url}");
                // Note: LoadedResource doesn't have statusCode, only url and initiatorType
              },
              shouldInterceptRequest: (controller, request) async {
                LogUtils.d("Intercepting request: ${request.url}");
                return null; // 允许正常处理
              },
            ),
              ),  // 关闭Padding widget
          if (_isLoading)
            Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  _currentGame == AppName.hdFmjApp 
                      ? Colors.white  // 伏魔记使用白色进度条
                      : Theme.of(context).colorScheme.primary,  // 三国霸业使用主题色
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}