//
//  ColorsUtil.swift
//  Colors
//
//  Created by Bo Huang on 2025/7/14.
//

/**
 颜色解析扩展工具
 */
import SwiftUI
import UIKit


extension Color {
    // 扩展 Color 功能
    // 洋红色
    static let magenta = Color(cgColor: CGColor(red: 1, green: 0, blue: 1, alpha: 1))
    
    // 添加从 16 进制创建颜色的方法
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double(hex >> 16 & 0xff) / 255,
            green: Double(hex >> 08 & 0xff) / 255,
            blue: Double(hex >> 00 & 0xff) / 255,
            opacity: alpha
        )
    }
    
    /**
     获取颜色的 16 进制字符串
     */
    func hexString() -> String? {
        // 先获取颜色的 RGB 值
        if let (red, green, blue) = rgbIntValue() {
            return String(format: "%02X%02X%02X", red, green, blue)
        }
        return nil
    }
    
    /**
     获取 RGB 各颜色分量的整数值, 取值范围 0 - 255
     */
    func rgbIntValue() -> (red: Int, green: Int, blue: Int)? {
        // 将 0 - 1 的小数值转换为 0 - 255 的整数值
        if let (r, g, b) = rgbValue() {
            let red = Int(r * 255)
            let green = Int(g * 255)
            let blue = Int(b * 255)
            return (red, green, blue)
        }
        return nil
    }
    
    /**
     获取颜色的 CMYK 分量值, 取值范围 0 - 1
     */
    func cmykValue() -> (cyan: CGFloat, magenta: CGFloat, yellow: CGFloat, black: CGFloat)? {
        // 1. 先获取颜色的 RGB 值
        if let (red, green, blue) = rgbValue() {
            // 2. 将 RGB 转换成 CMYK
            let black = 1 - max(red, green, blue)
            let cyan = (1 - red - black) / (1 - black)
            let magenta = (1 - green - black) / (1 - black)
            let yellow = (1 - blue - black) / (1 - black)
            
            return (cyan, magenta, yellow, black)
        }
        return nil
    }
    
    /**
     获取 CMYK 的整数值(各颜色分量百分比的整数值, 也就是将小数转换为百分比整数), 比如 0.21 -> 21
     */
    func cmykIntValue() -> (cyan: Int, magenta: Int, yellow: Int, black: Int)? {
        if let (cyan, magenta, yellow, black) = cmykValue() {
            let c = Int(cyan * 100)
            let m = Int(magenta * 100)
            let y = Int(yellow * 100)
            let k = Int(black * 100)
            return (c, m, y, k)
        }
        return nil
    }
    
    /**
     HSB 颜色模型
        HSB(Hue, Saturation, Brightness) 是一种基于人眼感知的颜色模型
        Hue 表示色相, 也就是颜色的类型, 取值范围 0° - 360° (环形)
        Saturation 表示饱和度, 颜色的鲜艳程度, 取值范围 0%(灰) - 100%(纯色)
        Brightness 表示亮度, 颜色的明暗程度, 范围 0%(黑) - 100%(最亮)
     */
    func hsbValue() -> (hue: CGFloat, saturation: CGFloat, brightness: CGFloat)? {
        let uiColor = UIColor(self)
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        
        // 使用UIKit 的方法获取颜色的 HSB 值
        guard uiColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) else {
            return nil
        }
        return (hue * 360, saturation * 100, brightness * 100)
    }
    
    /**
     获取 HSB 整型值
     */
    func hsbIntValue() -> (hue: Int, saturation: Int, brightness: Int)? {
        if let (h, s, b) = hsbValue() {
            let hue = Int(h.rounded(.toNearestOrAwayFromZero))
            let saturation = Int(s.rounded(.toNearestOrAwayFromZero))
            let brightness = Int(b.rounded(.toNearestOrAwayFromZero))
            return (hue, saturation, brightness)
        }
        return nil
    }
    
    /**
     获取颜色的 RGB 各分量的值, 值的范围 0 - 1
     */
    private func rgbValue() -> (red: CGFloat, green: CGFloat, blue: CGFloat)? {
        // 因为 UIKit 有直接分解颜色 RGB 的方法, 使用 UIKit, 需要处理的是 UIColor
        // 1. 将 Color 转换为 UIColor
        let uiColor = UIColor(self)
        
        // 2. 获取 RGBA 分量
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        // 如果支持 RGB 颜色空间才会解析成功
        guard uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
            return nil
        }
        return (red, green, blue)
    }
}
