import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../components/common_card.dart';
import '../components/settings_cells.dart';
import '../utils/app_config.dart';
import '../utils/js_bridge.dart';
import 'save_list_page.dart';
import 'feedback_page.dart';

class EnhancedAboutPage extends StatefulWidget {
  const EnhancedAboutPage({super.key});

  @override
  State<EnhancedAboutPage> createState() => _EnhancedAboutPageState();
}

class _EnhancedAboutPageState extends State<EnhancedAboutPage> {
  String _version = '';
  String _buildNumber = '';
  String _offlinePackageVersion = '';

  final List<Map<String, String>> _developers = [
    {'name': 'Kevin', 'homepage': 'https://gitee.com/kvinwang'},
    {'name': 'BlackSky', 'homepage': 'https://gitee.com/null_331_1413'},
    {'name': '天际边工作室', 'homepage': 'http://www.skysidestudio.com'},
    {'name': '旭哥传奇', 'homepage': 'https://b23.tv/jFjqLIB'},
    {'name': 'Harry', 'homepage': 'https://gitee.com/harrydeng'}
  ];

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    await _loadOfflinePackageVersion();
    setState(() {
      _version = packageInfo.version;
      _buildNumber = packageInfo.buildNumber;
    });
  }

  Future<void> _loadOfflinePackageVersion() async {
    final prefs = await SharedPreferences.getInstance();
    final appName = AppConfig.shared.appName;
    final versionKey = 'offlinePackageVersion_${appName.toString()}';
    final version = prefs.getString(versionKey);
    
    if (version != null && version.isNotEmpty) {
      _offlinePackageVersion = version;
    } else {
      _offlinePackageVersion = AppConfig.shared.offlineZipName;
    }
  }



  Future<void> _launchUrl(String urlString) async {
    final url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  void _openAppStore() {
    _launchUrl(AppConfig.shared.appStoreUrl);
  }

  void _shareApp() {
    final shareText = AppConfig.shared.getRandomShareText();
    final shareUrl = AppConfig.shared.shareUrl;
    final fullShareContent = '$shareText\n\n$shareUrl';

    // Show share dialog or use platform specific sharing
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('分享应用'),
        content: Text(fullShareContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final scaffoldMessenger = ScaffoldMessenger.of(context);

              navigator.pop();

              // 复制到剪贴板
              try {
                await Clipboard.setData(ClipboardData(text: fullShareContent));
                if (mounted) {
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text('分享内容已复制到剪贴板'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text('复制失败: $e'),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
              }
            },
            child: const Text('复制'),
          ),
        ],
      ),
    );
  }

  void _showGameSwitchDialog() {
    final currentGame = AppConfig.shared.appName;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('切换游戏'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '切换游戏将重启应用，当前游戏进度请记得存档！',
              style: TextStyle(fontSize: 14, color: Colors.red),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(
                Icons.castle,
                color: currentGame == AppName.hdBayeApp
                    ? AppConfig.shared.primaryColor
                    : Colors.grey,
              ),
              title: const Text('三国霸业'),
              trailing: currentGame == AppName.hdBayeApp
                  ? Icon(Icons.check, color: AppConfig.shared.primaryColor)
                  : null,
              onTap: () {
                if (currentGame != AppName.hdBayeApp) {
                  Navigator.pop(context);
                  _switchGame(AppName.hdBayeApp);
                }
              },
            ),
            ListTile(
              leading: Icon(
                Icons.sports_martial_arts,
                color: currentGame == AppName.hdFmjApp
                    ? AppConfig.shared.primaryColor
                    : Colors.grey,
              ),
              title: const Text('伏魔记'),
              trailing: currentGame == AppName.hdFmjApp
                  ? Icon(Icons.check, color: AppConfig.shared.primaryColor)
                  : null,
              onTap: () {
                if (currentGame != AppName.hdFmjApp) {
                  Navigator.pop(context);
                  _switchGame(AppName.hdFmjApp);
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
        ],
      ),
    );
  }

  Future<void> _switchGame(AppName newGame) async {
    try {
      // 保存游戏选择
      await AppConfig.shared.switchToGame(newGame);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('正在切换到${newGame == AppName.hdBayeApp ? "三国霸业" : "伏魔记"}...'),
            duration: const Duration(seconds: 2),
          ),
        );

        // 延迟一下让用户看到提示
        await Future.delayed(const Duration(milliseconds: 500));

        // 返回到主页面并重新加载
        if (mounted) {
          // 弹出当前页面，返回WebView页面
          Navigator.of(context).pop();

          // 通知需要重新加载（这里需要配合主页面的刷新机制）
          // 可以通过发送通知或使用状态管理来触发WebView页面重新加载
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('切换游戏失败: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('关于'),
        backgroundColor: AppConfig.shared.appBarBackgroundColor,
        foregroundColor: AppConfig.shared.appBarForegroundColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareApp,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),  // 减少顶部和底部padding
        children: [
          // Logo部分
          Container(
            height: 180,
            alignment: Alignment.center,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                AppConfig.shared.appName == AppName.hdBayeApp ? 'assets/about_logo_baye.png' : 'assets/about_logo_fmj.png',
                width: 160,
                height: 160,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.gamepad,
                      size: 80,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
            ),
          ),
          
          // 宗旨部分
          CommonCard(
            title: '宗旨',
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  '没有最好，只有更好。不求回报，只求快乐。\n时间带不走我们的热情，时代改变不了我们的执着！\n不知道还有多少人还记得曾经的这里。。感谢您以前的支持，感谢时光不在，您却还在~',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),

          // 游戏切换
          CommonCard(
            title: '游戏选择',
            children: [
              ListTile(
                dense: true,
                leading: Icon(
                  AppConfig.shared.appName == AppName.hdBayeApp
                      ? Icons.castle
                      : Icons.sports_martial_arts,
                  color: AppConfig.shared.primaryColor,
                ),
                title: const Text('当前游戏'),
                subtitle: Text(AppConfig.shared.title),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _showGameSwitchDialog(),
              ),
            ],
          ),

          // 版本信息
          CommonCard(
            title: '版本信息',
            children: [
              ListTile(
                dense: true,  // 使用紧凑模式
                title: Text('当前版本'),
                subtitle: Text('$_version ($_buildNumber)'),
                onTap: _openAppStore,
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              ),
              ListTile(
                dense: true,  // 使用紧凑模式
                title: Text('离线包版本'),
                subtitle: Text(_offlinePackageVersion),
              ),
            ],
          ),

          // 存档管理
          CommonCard(
            title: '存档管理',
            children: [
              ListTile(
                dense: true,  // 使用紧凑模式
                leading: const Icon(Icons.save_outlined, color: Colors.blue),
                title: const Text('存档列表'),
                subtitle: const Text('查看和管理游戏存档'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SaveListPage()),
                  );
                },
              ),
              ListTile(
                dense: true,  // 使用紧凑模式
                leading: const Icon(Icons.feedback_outlined, color: Colors.green),
                title: const Text('意见反馈'),
                subtitle: const Text('报告问题或提出建议'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const FeedbackPage()),
                  );
                },
              ),
            ],
          ),

          // 页面设置 (FMJ 和 Baye 都显示)
          CommonCard(
            title: '页面设置',
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 2),
                child: PortraitModeCell(
                  initialValue: AppConfig.shared.portraitMode,
                  onChanged: (value) {
                    AppConfig.shared.portraitMode = value;
                    JSBridge.updatePortraitMode(value);
                  },
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 2),
                child: GameSpeedCell(
                  initialValue: AppConfig.shared.gameSpeed,
                  onChanged: (value) {
                    AppConfig.shared.gameSpeed = value;
                    JSBridge.updateGameSpeed(value);
                  },
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 2),
                child: ColorFilterCell(
                  initialValue: AppConfig.shared.selectedFilter,
                  onChanged: (value) {
                    AppConfig.shared.selectedFilter = value;
                    JSBridge.updateColorFilter(value);
                  },
                ),
              ),
              // 仅FMJ显示遇敌概率
              if (AppConfig.shared.appName == AppName.hdFmjApp)
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 2),
                  child: CombatProbabilityCell(
                    initialValue: AppConfig.shared.combatProbability,
                    onChanged: (value) {
                      AppConfig.shared.combatProbability = value;
                      JSBridge.updateCombatProbability(value);
                    },
                  ),
                ),
            ],
          ),

          if (AppConfig.shared.appName == AppName.hdFmjApp)
            CommonCard(
              title: '高级功能',
              children: [
               
              ],
            ),

          // 开发者信息
          CommonCard(
            title: '开发者信息',
            children: _developers.map((dev) => ListTile(
              dense: true,  // 使用紧凑模式
              title: Text(dev['name']!, style: const TextStyle(fontSize: 14)),
              onTap: () => _launchUrl(dev['homepage']!),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            )).toList(),
          ),

          // 隐私政策
          CommonCard(
            title: '隐私政策',
            children: [
              ListTile(
                dense: true,  // 使用紧凑模式
                title: const Text('隐私政策', style: TextStyle(fontSize: 14)),
                onTap: () => _launchUrl('https://blog.csdn.net/u012390519/article/details/145736113'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

}