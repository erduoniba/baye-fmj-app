# 三国霸业/伏魔记重制版源码

## 项目总览

该项目是一个多平台游戏项目集合，包含经典 BBK 游戏的现代化移植版本。

项目包含以下主要组件：

[三国霸业C源码编译技术文档](./Baye/baye_c/README.md)

[三国霸业Web版本技术文档](./Baye/baye_offline/README.md)



[伏魔记C反汇编（伏魔记重制版引擎蓝本）](./Fmj/fmj_c_engine/readme.txt)

[伏魔记重制版引擎源码技术文档](./Fmj/fmj_kt/README.md)

[伏魔记Web版本技术文档](./Fmj/fmj_offline/README.md)



[三国霸业/伏魔记iOS版本技术文档](./iOS/README.md)

[三国霸业/伏魔记Android版本技术文档](./Flutter/README.md)



### 伏魔记源码历史故事

故事线基于2025年来回溯，都是我作者本人全网搜索，并一一找到对应的核心开发者确认后整理。

#### 1、全网最初安卓版源码（cdd990）

​	十年前，cdd990大佬开源了全网最初的安卓版《伏魔记》源码，这是将经典BBK游戏移植到现代移动平台的开创性尝试。

🎯 技术特点

​	• **原生Android开发**：基于Java和Android SDK实现

​	• **游戏引擎移植**：将BBK平台的游戏逻辑大部分功能移植

​	• **触屏适配**：为触屏操作重新设计交互方式

💔 历史遗憾

​	虽然这是一个开源项目，但由于一些原因，作者后来选择了闭源，GitHub链接现在已经无法访问。这个项目为后续所有的移植版本奠定了基础。

*项目状态：已闭源，链接无法访问*



#### 2、伏魔记 Java 版本（yuanmomo）


​	九年前，yuanmomo大佬在cdd990大佬版本的基础上，成功将游戏移植到PC平台。这个版本修改了绘图系统和事件监听机制，使游戏能够在桌面环境下流畅运行。https://github.com/yuanmomo/fmj_pc

🔧 核心改进
	**• 绘图系统重构：适配PC端的图形渲染**

​	**• 事件监听优化：支持键盘和鼠标操作**

​	**• 跨平台兼容：基于Java实现跨操作系统运行**

🌟 影响力

​	这个版本成为了后续众多移植项目的重要参考，其架构和实现方式被广泛借鉴和学习。

**项目来源：基于cdd990/fmj开发**



#### 3、伏魔记 Kotlin 版本（bgwp）

​	七年前，bgwp/dalong大佬使用Kotlin语言重写了整个游戏，并将其编译为JavaScript在Web环境中运行，这是一次技术栈的重大创新。https://gitee.com/bgwp/fmj.kt

⚡ 技术亮点

​	**• Kotlin/JS技术：使用现代语言特性重写游戏逻辑**

​	**• Web端运行：无需安装，浏览器直接游玩**

​	**• 架构优化：基于yuanmomo版本翻译改进**

​	**• 功能扩展：修复bug并添加新游戏支持**

🎮 现代化特性

​	不仅保持了原版的核心玩法，还加入了现代Web技术的优势，如响应式布局、在线存档等功能。

**技术栈：Kotlin → JavaScript编译**



#### 4、BBKRPGSimulator：C#版本	

​	五年前，stratosblue大佬带着满满的情怀，将游戏移植到C#平台。作者的话很有代表性："这个代码移植快完成的时候才发现原Java项目还有指令和逻辑没有完成。" https://github.com/stratosblue/BBKRPGSimulator

🎯 技术特色

​	**• C#重构：基于yuanmomo版本的C#翻译**

​	**• 数据模拟：支持地图、宝箱等数据展示**

​	**• RPG专用：专门针对RPG游戏优化**

😅 开发感悟

​	"虽然这种数据模拟的方式可以实现很多好玩的东西，比如地图、宝箱展示等，但确实没有发现一个做到了完美兼容的项目可以抄袭🤣"这种真诚的开发感悟体现了技术人的朴实和执着。

**项目定位：代码学习和简单体验**



#### 5、Android 版本伏魔记（artharyoung）

​	四年前，artharyoung大佬基于yuanmomo大佬的PC版本，再次将游戏带回到Android平台，这是继cdd990之后的又一次安卓移植尝试。 https://github.com/artharyoung/android_fmj

🔄 技术路径

​	**• 跨平台移植：PC → Android的技术转换**

​	**• 适配优化：针对移动设备的性能优化**

​	**• 界面调整：适应不同屏幕尺寸和分辨率**

🎮 移动体验

​	在保持PC版本功能完整性的同时，重新优化了移动端的用户体验，让玩家能够在手机上重温经典。

**技术基础：基于yuanmomo/fmj_pc修改**



#### 6、java桌面版伏魔记（jacky14）

​	三年前，jacky14大佬延续了yuanmomo大佬的技术路线，开发了专门的Java桌面版本，从源码目录结构可以看出是参考经典PC版本架构。 https://github.com/jacky14/fmj_pc

🏗️ 架构特点

​	**• 经典架构：沿用成熟的PC版本架构**

​	**• Java技术栈：使用纯Java实现桌面应用**

​	**• 稳定性优化：专注于桌面环境的稳定运行**

⚡ 持续改进

​	在继承经典架构的基础上，针对现代桌面环境进行了相应的优化和改进，确保游戏的兼容性和稳定性。

**架构参考：yuanmomo/fmj_pc**



#### 7、GameShell适配的步步高经典游戏

​	三年前，zzxzzk115大佬将游戏适配到GameShell掌机设备上，基于bgwp的Kotlin版本构建H5页面游戏，实现了专业掌机的游戏体验。 https://github.com/zzxzzk115/BBKGames_GameShell

🔧 适配特色

​	**• 掌机优化：专门为GameShell设备优化**

​	**• H5技术：基于Web技术实现跨平台**

​	**• 硬件集成：充分利用掌机的物理按键**

🚀 技术价值

​	这个项目证明了经典游戏在现代掌机设备上的可行性，为复古游戏在新硬件平台上的运行提供了宝贵经验。

**技术基础：基于bgwp/fmj.kt构建**



#### 8、无云大佬逆向反编译bbk源码

​	一年前，无云大佬通过逆向工程技术，成功反编译了BBK的原始源码，这是技术考古学的重大突破。 https://gitee.com/BA4988/fmj-engine

⚡ 核心价值

​	**• 原始算法：包含原版的伤害计算公式**

​	**• 技术还原：最接近原版的实现逻辑**

​	**• 参考蓝本：为其他版本提供权威参考**

🏆 技术意义

​	这个项目不仅是技术实力的体现，更是对原版游戏的致敬和保护。通过逆向工程，我们得以窥见20年前游戏开发的原始面貌。"致敬通宵虫、南方小鬼最原始的作者。"

**技术手段：逆向反编译BBK原始代码**



### 游戏应用
- **三国霸业**：经典战略游戏的移动版本
- **伏魔记**：经典 RPG 游戏的移动版本

### 技术栈概览
- **iOS 原生**：Swift + WKWebView
- **Flutter 跨平台**：Dart + flutter_inappwebview  
- **游戏源码**：伏魔记：Kotlin/JS 编译到 JavaScript；三国霸业：C++ 编译成wasm文件，提供给JS使用





## 项目结构

```
├── AppStore										# 应用市场相关内容
│   ├── fmj
│   └── sgby
├── Baye												# 三国霸业源码目录
│   ├── baye_c									# 三国霸业c源码目录
│   ├── baye_doc								# 三国霸业mod游戏制作教程和说明
│   └── baye_offline						# 三国霸业h5离线包目录
├── Flutter											# Flutter 跨平台应用，主要构建Android平台
│   ├── analysis_options.yaml
│   ├── android
│   ├── assets
│   ├── build_signed_apk.sh
│   ├── devtools_options.yaml
│   ├── Infos
│   ├── ios
│   ├── lib
│   ├── linux
│   ├── macos
│   ├── pubspec.lock
│   ├── pubspec.yaml
│   ├── README.md
│   ├── test
│   ├── web
│   └── windows
├── Fmj													# 伏魔记源码目录								
│   ├── fmj_c_engine						# 伏魔记c语言反汇编源码，可以作为蓝本去重构
│   ├── fmj_kt									# 伏魔记totlin源码，通过该代码编译 js 文件
│   ├── fmj_libs								# 类伏魔记游戏资源
│   └── fmj_offline							# 伏魔记h5页面离线包
├── iOS													# iOS工程源码目录
│   ├── 项目资料									# 应用市场介绍文案
│   ├── Asserts
│   ├── HDBayeApp
│   ├── HDBayeApp.xcodeproj
│   ├── HDBayeApp.xcworkspace
│   ├── parse_performance_data.py
│   ├── Podfile
│   ├── Podfile.lock
│   ├── Pods
│   └── README.md
├── LICENSE
└── README.md
```

## 各组件详细说明

### 1. iOS 原生应用 (`iOS/`)

基于 Swift 的 iOS 原生应用，通过 WKWebView 展示离线 Web 游戏。

#### 核心功能
- 离线包管理系统（支持服务器更新）
- JS-Native 桥接通信
- Google AdMob 广告集成
- 内购系统（IAP）
- 用户反馈系统

#### 目录结构
```
iOS/
├── HDBayeApp/
│   ├── WebView/             # Web 视图和 JS 桥接
│   ├── About/               # 设置和配置界面
│   ├── Tools/               # 工具类（离线包管理等）
│   ├── Feedback/            # 反馈系统
│   ├── ThirdParts/          # 第三方集成
│   └── Resources/           # 资源和离线包
├── fastlane/                # 自动化构建部署
└── Build/                   # 构建输出
```

#### 开发命令
```bash
pod install                  # 安装依赖
open HDBayeApp.xcworkspace  # 打开项目

# Fastlane 构建
bundle exec fastlane build_upload2 platform:appstore
bundle exec fastlane build_upload2 platform:firim
```

### 2. Flutter 跨平台应用 (`Flutter/`)

使用 Flutter 构建的跨平台应用，支持 iOS、Android、Web 等多平台。

#### 核心功能
- 跨平台 WebView 展示游戏
- 离线包解压和管理
- 存档管理系统
- 版本检查和更新

#### 目录结构
```
hd_sgbaye/
├── lib/
│   ├── main.dart            # 应用入口
│   ├── web_view_page.dart   # WebView 页面
│   ├── offline_package_manager.dart  # 离线包管理
│   ├── pages/               # 页面组件
│   ├── services/            # 服务层
│   └── utils/               # 工具类
├── android/                 # Android 平台代码
├── ios/                     # iOS 平台代码
└── assets/                  # 资源文件
    └── web/                 # 离线包文件
```

#### 开发命令
```bash
flutter pub get              # 安装依赖
flutter run                  # 运行开发版本
flutter build apk --release  # 构建 Android APK
flutter build ios            # 构建 iOS
```

### 3. 伏魔记游戏源码 (`fmj.kt/`)

经典 RPG 游戏"伏魔记"的 Kotlin/JS 移植版，编译为 JavaScript 在浏览器中运行。

#### 核心系统
- **角色系统**：玩家、怪物、NPC
- **战斗系统**：回合制战斗、动作队列
- **魔法系统**：各类魔法技能
- **物品系统**：装备、药品、道具
- **脚本系统**：79+ 脚本命令支持
- **场景管理**：地图切换、事件触发

#### 项目结构
```
fmj.kt/
├── src/fmj/
│   ├── Game.kt              # 游戏主控制器
│   ├── characters/          # 角色系统
│   ├── combat/              # 战斗系统
│   ├── magic/               # 魔法系统
│   ├── goods/               # 物品系统
│   ├── script/              # 脚本引擎
│   └── views/               # UI 界面
├── assets/                  # 游戏资源
│   ├── *.lib               # 游戏数据文件
│   └── buildrom.sh         # 资源构建脚本
├── dev_tools/              # 开发工具
│   ├── devtools.js         # 浏览器调试工具
│   └── docs/               # 开发文档
└── out/production/         # 构建输出
```

#### 构建命令
```bash
./gradlew buildGame          # 构建游戏（推荐）
./gradlew build             # 仅编译
./gradlew copyResources     # 复制资源

# 资源构建
cd assets
./buildrom.sh               # 构建游戏资源
```

#### 技术特点
- 固定分辨率：160x96 像素（原 BBK 屏幕尺寸）
- Kotlin/JS Legacy 编译器
- Canvas 渲染
- 完整保留原游戏机制

### 4. 伏魔记离线包构建系统 (`fmj.offline/`)

将 fmj.kt 编译后的 JavaScript 打包成适合移动端使用的离线包，支持多种经典游戏。

#### 核心功能
- **多游戏支持**：伏魔记、金庸群侠传、侠客行、赤壁之战系列
- **响应式界面**：自适应移动端和桌面端
- **控制系统**：虚拟摇杆和按钮两种模式
- **屏幕适配**：横屏/竖屏自动切换
- **游戏增强**：倍速、滤镜、小地图等功能
- **安全打包**：支持加密和 SHA256 校验

#### 目录结构
```
fmj.offline/
├── index.html               # 游戏主页面入口
├── pack-game.sh            # 通用打包脚本
├── js/                     # JavaScript 核心文件
│   ├── fmj.core.v2.js     # v2 游戏引擎（Kotlin 转译）
│   ├── fmj.core.js        # v1 游戏引擎（兼容）
│   ├── sys.js             # 系统接口层
│   ├── keyboard.js        # 键盘映射系统
│   ├── m.js               # 移动端适配
│   ├── m-native-bridge.js # 原生桥接层
│   ├── nipplejs.min.js    # 虚拟摇杆库
│   └── rom.js             # 游戏 ROM 数据
├── style/                  # CSS 样式文件
│   ├── baye.css           # 主样式
│   └── joystick.css       # 控制器样式
├── images/                # 控制图标资源
├── games/                 # 游戏专属文件
│   └── fmj/              
│       └── strategy.html  # 游戏攻略页面
└── dist/                  # 打包输出目录
```

#### 技术架构
```
┌─────────────────────────────────────────────────┐
│                HTML5 前端层                      │
├─────────────────────────────────────────────────┤
│  输入系统 │ 屏幕适配 │ 原生桥接 │ 游戏增强      │
├─────────────────────────────────────────────────┤
│           Kotlin/JS 游戏引擎层                   │
│         (fmj.core.v2.js / fmj.core.js)         │
├─────────────────────────────────────────────────┤
│            Canvas 2D 渲染层                      │
└─────────────────────────────────────────────────┘
```

#### 关键特性
- **输入系统**：
  - 虚拟摇杆（nipplejs）：8 方向支持，长按重复
  - 按钮模式：独立方向和功能按钮
  - 键盘映射：1-8 数字键对应游戏控制
  
- **屏幕适配**：
  - 横屏：标准布局，控制器在两侧
  - 竖屏：画布旋转 90 度，控制器重新布局
  - 动态尺寸：根据屏幕大小自动缩放

- **游戏增强**：
  - 倍速系统：`window.gameSpeedMultiple(n)`
  - 滤镜效果：复古、绿色、红色、清新等
  - 小地图功能：显示隐藏物品和玩家位置
  - 存档管理：与原生应用同步

- **安全机制**：
  - SHA256 完整性校验
  - 密码格式：`文件名-SHA256哈希值`
  - 加密打包选项

#### 与客户端集成
离线包被 iOS 和 Flutter 客户端使用：
1. 客户端从服务器下载离线包
2. 解压到应用沙盒目录
3. 通过 WebView 加载 index.html
4. JS 桥接实现原生功能调用

### 5. 共享资源 (`AppStore/`)

各平台共享的资源文件，包括：
- 应用图标
- 市场截图
- 活动图片

## 关键技术要点

### 离线包系统
1. **版本管理**：使用 YYYYMMDDHH 格式
2. **更新流程**：检查 → 用户确认 → 下载 → 解压 → 清理
3. **优先级**：网络版本 > Bundle 版本
4. **ZIP 管理**：自动清理，仅保留最新版本

### JS 桥接通信
- **iOS**：WKScriptMessageHandler
- **Flutter**：flutter_inappwebview JavaScript Handlers
- **统一接口**：保持两平台 API 一致性

### 构建部署
- **iOS**：Fastlane 自动化
- **Android**：Fastlane + PGYER
- **版本控制**：自动版本号管理

## 开发流程

### 1. 环境准备
```bash
# iOS 开发
gem install bundler
bundle install

# Flutter 开发  
flutter doctor
flutter pub get

# Node.js 服务
npm install

# Kotlin/JS 游戏
./gradlew build
```

### 2. 本地调试
- **iOS**：Xcode 调试，支持 Safari Web Inspector
- **Flutter**：flutter run，支持热重载
- **服务器**：nodemon 自动重启
- **游戏**：浏览器开发工具，Source Maps 支持

### 3. 发布流程
1. 更新版本号
2. 构建离线包
3. 上传到服务器
4. 管理后台激活新版本
5. 客户端检查更新

## 注意事项

### 安全考虑
- 服务器 API 使用速率限制
- 离线包需要哈希验证
- 管理后台需要登录认证
- 敏感数据不提交到代码库

### 性能优化
- 离线包按需更新
- WebView 缓存管理
- 图片资源压缩
- 代码混淆和压缩

### 兼容性
- iOS 13.0+
- Android API 21+
- Flutter SDK 3.7.2+
- Node.js 14+

## 常见问题

### Q: 如何添加新游戏？
1. 准备游戏 Web 版本
2. 打包为离线 ZIP
3. 配置应用支持
4. 更新服务器配置

### Q: 如何调试 JS 桥接？
- iOS：使用 Safari 开发者工具
- Flutter：使用 Chrome DevTools
- 添加日志输出到原生和 JS 端

### Q: 离线包更新失败？
1. 检查网络连接
2. 验证服务器配置
3. 查看客户端日志
4. 确认版本号正确

## 项目维护

### 日常维护
- 监控服务器日志
- 检查用户反馈
- 更新离线包内容
- 处理崩溃报告

### 版本发布
- 遵循语义化版本
- 编写更新日志
- 测试所有平台
- 分阶段发布

注意：
完成代码修改后，不需要自动运行构建和测试命令。