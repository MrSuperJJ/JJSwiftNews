//
//  JJConstantUtil.swift
//  JJSwiftDemo
//
//  Created by yejiajun on 2017/3/10.
//  Copyright © 2017年 yejiajun. All rights reserved.
//

import UIKit

// MARK: - 屏幕宽度/高度
public let ScreenWidth = UIScreen.main.bounds.width
public let ScreenHeight = UIScreen.main.bounds.height
public let NavBarHeight = CGFloat(64)
// MARK: - 界面适配
// 320为iphont5屏幕宽度，375为iphone6屏幕宽度，414为iphone6+屏幕宽度
public let iphone5ScreenWidth  = CGFloat(320)
public let iphone6ScreenWidth  = CGFloat(375)
public let iphone6pScreenWidth = CGFloat(414)
public var currentScreenWidth  = iphone5ScreenWidth
// MARK: 函数实现(iphone6)
public func JJAdapter(_ value: CGFloat) -> CGFloat {
    let resultValue = UIScreen.main.bounds.width / iphone6ScreenWidth * value
    return resultValue
}

public func JJCGRectMake(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) -> CGRect {
    return CGRect(x: JJAdapter(x), y: JJAdapter(y), width: JJAdapter(width), height: JJAdapter(height))
}
// MARK: 扩展实现(iphone5)
public extension CGFloat {
    init(adValue: CGFloat) {
        let resultValue = UIScreen.main.bounds.width / iphone5ScreenWidth * adValue
        self.init(resultValue)
    }
}

public extension CGRect {
    init(adX: CGFloat, adY: CGFloat, adWidth: CGFloat, adHeight: CGFloat) {
        self.init(x: CGFloat(adValue: adX), y: CGFloat(adValue: adY), width: CGFloat(adValue: adWidth), height: CGFloat(adValue: adHeight))
    }
}

//MARK:- 生成十六进制颜色
public extension UIColor {
    convenience init(valueRGB: UInt, alpha: CGFloat) {
        self.init(
            red: CGFloat((valueRGB & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((valueRGB & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(valueRGB & 0x0000FF) / 255.0,
            alpha: alpha
        )
    }
}

// MARK: - 响应链信息打印
public func printResponderList(_ currentView: UIView) {
    print("------------------")
    print("      v ")
    print("    \(currentView)")
    
    var next = currentView.next
    
    while (next != nil)
    {
        print("      v ")
        print("    \(next!)")
        next = next?.next
    }
    print("------------------")
    
}

// MARK: - 日志打印 格式：[file(line), method]: message
public func printLog<T>(_ message: T, file: String = #file, method: String = #function, line: Int = #line) {
    #if DEBUG
        print("[\(((file as NSString).lastPathComponent as NSString).deletingPathExtension)(\(line)), \(method)]: \(message)")
    #endif
}

// MARK: - UIView扩展
public extension UIView {
    
    //MARK: 移除所有子视图
    internal func removeAllSubviews() {
        for item in self.subviews {
            item.removeFromSuperview()
        }
    }
    
    //MARK: 获取视图位置,宽度,高度
    internal var top: CGFloat {
        get {
            return self.frame.origin.y
        }
    }
    
    internal var bottom: CGFloat {
        get {
            return self.frame.origin.y + self.frame.size.height
        }
    }
    
    internal var left: CGFloat {
        get {
            return self.frame.origin.x
        }
    }
    
    internal var right: CGFloat {
        get {
            return self.frame.origin.x + self.frame.size.width
        }
    }
    
    internal var width: CGFloat {
        get {
            return self.frame.size.width
        }
    }
    
    internal var height: CGFloat {
        get {
            return self.frame.size.height
        }
    }
}

// MARK: - 获取多行文本情况下的高度
///
/// - Parameters:
///   - text: 文本内容
///   - width: 文本宽度
///   - font: 文本大小
///   - lineSpacing: 文本行间隔
/// - Returns: UIView高度
public func fetchHeightForMultipleLinesText(_ text: String, width: CGFloat, font: UIFont, lineSpacing: CGFloat = 0) -> CGFloat {
    let attributedText = NSMutableAttributedString(string: text, attributes: [NSFontAttributeName: font])
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.lineSpacing = lineSpacing
    attributedText.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSMakeRange(0, attributedText.length))
    let attributedSize = attributedText.boundingRect(with: CGSize(width: width, height: 900), options: .usesLineFragmentOrigin, context:nil).size
    return attributedSize.height
}
