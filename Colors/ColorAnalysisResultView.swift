//
//  ColorAnalysisResultView.swift
//  Colors
//
//  Created by Bo Huang on 2025/7/15.
//

import SwiftUI

struct ColorAnalysisResultView: View {
    let rgbValue : (Int, Int, Int)
    let cmykValue: (Int, Int, Int, Int)
    let hsbValue: (Int, Int, Int)
    let mainColor: Color
    let isSolidColor: Bool
    // 当前显示的颜色类型
    @State private var selectedComponent: ColorComponent = .rgb
    
    // 实现 CaseIterable 协议, 让枚举成员可迭代
    enum ColorComponent: String, CaseIterable {
        case rgb = "RGB"
        case cmyk = "CMYK"
        case hsb = "HSB"
    }
    
    private var mainColorCard: some View {
        VStack(spacing: 0) {
            Text(isSolidColor ? "纯色图片" : "主色提取")
                .font(.headline)
                .foregroundStyle(.secondary)
            
            mainColor
                .frame(width: 80, height: 80)
                .clipShape(.circle)
                .overlay {
                    Circle()
                        .stroke(.white, lineWidth: 3)
                        .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
                }
        }
    }
    private var hexValueCard: some View {
        VStack(spacing: 8) {
            Text("十六进制")
                .font(.headline)
                .foregroundStyle(.secondary)
            
            Text(mainColor.hexString() ?? "#000000")
                .font(.system(.title2, design: .monospaced))
                .fontWeight(.bold)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.quaternary)
                )
        }
    }
    
    // MARK: 分量选择器
    private var componentSelector: some View {
        HStack(spacing: 0) {
            ForEach(ColorComponent.allCases, id: \.self) {
                component in
                Button{
                    selectedComponent = component
                } label: {
                    Text(component.rawValue)
                        .font(.system(.body, design: .rounded))
                        .fontWeight(.medium)
                        .foregroundStyle(selectedComponent == component ? .white : .primary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(selectedComponent == component ? mainColor : .clear)
                        )
                        .overlay {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(selectedComponent == component ? mainColor : .gray.opacity(0.3), lineWidth: 1)
                        }
                }
                .buttonStyle(.plain)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.quaternary)
        )
    }
    
    // MARK: 分量视图
    @ViewBuilder
    private var selectedComponentView: some View {
        switch selectedComponent {
        case .rgb:
            rgbComponentCard
        case .cmyk:
            cmykComponentCard
        case .hsb:
            hsbComponentCard
        }
    }
    
    // MARK: RGB 分量视图
    private var rgbComponentCard: some View {
        VStack(spacing: 12) {
            Text("RGB 分量")
                .font(.headline)
                .foregroundStyle(.secondary)
            
            VStack(spacing: 8) {
                colorBarComponent(label: "R", value: rgbValue.0, maxValue: 255, color: .red, backgroundColor: .red.opacity(0.2))
                colorBarComponent(label: "G", value: rgbValue.1, maxValue: 255, color: .green, backgroundColor: .green.opacity(0.2))
                colorBarComponent(label: "B", value: rgbValue.2, maxValue: 255, color: .blue, backgroundColor: .blue.opacity(0.2))
            }
            Spacer()
        }
    }
    
    // MARK: CMYK 分量视图
    private var cmykComponentCard: some View {
        VStack(spacing: 12) {
            Text("CMYK 分量")
                .font(.headline)
                .foregroundStyle(.secondary)
            VStack(spacing: 8) {
                colorBarComponent(label: "C", value: cmykValue.0, maxValue: 100, color: .cyan, backgroundColor: .cyan.opacity(0.2))
                colorBarComponent(label: "M", value: cmykValue.1, maxValue: 100, color: .magenta, backgroundColor: .magenta.opacity(0.2))
                colorBarComponent(label: "Y", value: cmykValue.2, maxValue: 100, color: .yellow, backgroundColor: .yellow.opacity(0.2))
                colorBarComponent(label: "K", value: cmykValue.3, maxValue: 100, color: .black, backgroundColor: .black.opacity(0.2))
            }
        }
    }
    
    // MARK: HSB 分量视图
    private var hsbComponentCard: some View {
        VStack(spacing: 12) {
            Text("HSB 分量")
                .font(.headline)
                .foregroundStyle(.secondary)
            
            VStack(spacing: 8) {
                colorBarComponent(label: "H", value: hsbValue.0, maxValue: 360, color: .orange, backgroundColor: .orange.opacity(0.2))
                colorBarComponent(label: "S", value: hsbValue.1, maxValue: 100, color: .purple, backgroundColor: .purple.opacity(0.2))
                colorBarComponent(label: "B", value: hsbValue.2, maxValue: 100, color: .indigo, backgroundColor: .indigo.opacity(0.2))
            }
            Spacer()
        }
    }
    
    // MARK: 颜色条
    private func colorBarComponent(
        label: String,
        value: Int,
        maxValue: Int,
        color: Color,
        backgroundColor: Color
    ) -> some View {
        HStack {
            Text(label)
                .font(.system(.body, design: .monospaced))
                .fontWeight(.semibold)
                .frame(width: 20, alignment: .leading)
            
            GeometryReader{
                proxy in
                ZStack (alignment: .leading){
                    // 背景条
                    RoundedRectangle(cornerRadius: 4)
                        .fill(backgroundColor)
                        .frame(height: 20)
                    
                    // 颜色条
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color)
                        .frame(width: proxy.size.width * CGFloat(value) / CGFloat(maxValue), height: 20)
                    
                }
            }
            .frame(height: 20)
            
            Text("\(value)")
                .font(.system(.body, design: .monospaced))
                .fontWeight(.medium)
                .frame(width: 35, alignment: .trailing)
        }
    }
    
    var body: some View {
        
        VStack(spacing: 16) {
            HStack{
                // 主色展示
                mainColorCard
                Spacer()
                hexValueCard
            }
            
            // 分量选择器
            componentSelector
            // 根据选择显示对应的分量结果
            selectedComponentView
        }
        .padding()
        .frame(height: 360)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
}

#Preview {
    ColorAnalysisResultView(
        rgbValue: (255, 128, 64), cmykValue: (0, 50, 75, 0), hsbValue: (20, 85, 100), mainColor: .orange, isSolidColor: true
    )
}
