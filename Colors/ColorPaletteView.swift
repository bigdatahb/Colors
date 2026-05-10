//
//  ColorPaletteView.swift
//  Colors
//
//  Created by Bo Huang on 2025/7/14.
//

import SwiftUI

struct ColorPaletteView: View {
    // 调色板颜色数组
    let colors: [Color]
    // 当前选中颜色
    let selectedColor: Color?
    // 选择颜色需要执行的闭包
    let onColorSelcted: (Color) -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            Text("主要颜色")
                .font(.headline)
                .foregroundStyle(.secondary)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(minimum: 10, maximum: .infinity)), count: 5), spacing: 12) {
                ForEach(Array(colors.enumerated()), id: \.offset) {
                    index, color in
                    ColorSwatchView(
                        color: color,
                        isSelected: selectedColor == color,
                        onTap: {
                            onColorSelcted(color)
                        })
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
    }
}

/**
 单个颜色卡片视图
 */
struct ColorSwatchView: View {
    // 颜色
    let color: Color
    // 是否选中
    let isSelected: Bool
    // 点击需要执行的闭包
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing : 4) {
                // 将颜色创建为 50 x 50 的小卡片
                color
                    .frame(width: 50, height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isSelected ? Color.primary : Color.clear, lineWidth: 2)
                    }
                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                // 颜色下面放置颜色对应的十六进制值
                Text(color.hexString() ?? "#000000")
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .buttonStyle(.plain)
        // 对于选中的颜色, 适当放大
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.easeIn(duration: 0.2), value: isSelected)
    }
}

#Preview {
    ColorPaletteView(colors: [.red, .green, .blue, .yellow, .purple], selectedColor: .red, onColorSelcted: { _ in })
        .padding()
    
}
