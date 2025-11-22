//
//  HDConstants.swift
//  HDBayeApp
//
//  Created by harrydeng on 2025/07/23.
//

import Foundation

// MARK: - App Constants
struct HDConstants {
    // MARK: - URLs
    struct URLs {
        static let privacyPolicy = "https://blog.csdn.net/u012390519/article/details/145736113"
    }

    // MARK: - QQ Group
    struct QQGroup {
        static let groupNumber = "583546208"
        static let urlScheme = "mqqapi://card/show_pslcard?src_type=internal&version=1&uin=\(groupNumber)&card_type=group&source=qrcode"
    }
    
    // MARK: - Version Update Alert
    struct VersionAlert {
        static let fmjTitle = "🎉 伏魔记升级 🎉"
        static let fmjMessage = """
        新版本带来全新游戏体验：
        
        功能新增：
          关于页面优化：支持跟随系统自动切换横竖屏，也可手动调整，适配不同使用习惯
          横屏交互升级：新增双手操作缩放画面大小，操作更灵活
          内容拓展：新增游戏故事页面，深度解读游戏背后的故事
          体验优化：实时保存游戏设置，下次启动直接沿用历史选项

        bug修复：
          修复新版魔塔无法获取经验、自带潮海衣新手福利的问题
          解决仙剑系列游戏已知的卡死故障
          兼容修复 “一中传奇1” 虚拟世界中无法触发雄哥删除校长剧情的问题
          修复 boss 及敌人血/蓝量上限显示异常（999）的问题

        立即体验全新的伏魔记世界！
        """
        
        static let bayeTitle = "🎉 三国霸业引擎升级 🎉"
        static let bayeMessage = """
        按国际惯例，致敬通宵虫、南方小鬼两位大佬！
        
        基于 loong 大神（https://gitee.com/bgwp/iBaye）源码构建三国霸业引擎，后续 Bug 修复及新功能开发均在此基础上进行。请注意：当前版本可能存在不稳定性，若遇到任何问题或有建议，可加入 QQ 群 526266208 并 @Harry 反馈。
        
        引擎代码优化
        • 支持原版词典分辨率（160x96）提升至低清分辨率（208x128）
        
        🔍 新增数据可视化
        • 直观展示初始时期势力分布、在野英雄、英雄榜、城市分布及详细数据
        
        📍 画面适配升级
        • 支持游戏画面横竖屏自由切换
        • 添加滤镜效果，还原复古游戏体验
        • 新增游戏变速器功能
        
        立即体验全新的三国霸业世界！
        """
        
        static let confirmButtonTitle = "立即体验"
        
        // 需要显示升级提示的版本号
        static let targetVersion = "2.2.7"
    }
    
    // MARK: - App Store Version Check
    struct AppStoreVersionCheck {
        static let title = "🆕 发现新版本"
        static let confirmButtonTitle = "立即更新"
        static let cancelButtonTitle = "稍后提醒"
        static let launchCountThreshold = 3 // 启动3次后检查版本
        
        static func message(for newVersion: String) -> String {
            return """
            检测到App Store上有新版本 \(newVersion)
            
            🎯 重要更新内容：
            • 性能优化和Bug修复
            • 新功能和体验改进
            • 更好的稳定性
            
            建议立即更新以获得最佳体验！
            """
        }
    }
    
    // MARK: - iTunes Search API
    struct iTunesAPI {
        static let searchURL = "https://itunes.apple.com/lookup?bundleId=\(Bundle.main.bundleIdentifier ?? "com.harry.fmj")"
    }
    
    // MARK: - Context Messages for JavaScript
    struct JSContext {
        static let updateColorFilter = "更新滤镜颜色"
        static let updateGameSpeed = "更新游戏速度"
        static let updateMapDisplay = "更新地图显示状态"
        static let setExpMultiple = "设置经验倍数"
        static let setGoldMultiple = "设置金币倍数"
        static let updateEngineSelection = "更新引擎选择"
        static let removeLocalStorage = "移除本地存储"
        static let setLocalStorage = "设置本地存储"
    }
    
    struct UIContant {
        static let leadingAnchor = 16.0
        static let trailingAnchor = -16.0
    }
}
