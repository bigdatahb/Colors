/**
 主页面视图
 */
import PhotosUI
import SwiftUI

struct ContentView: View {
    // 是否显示确认对话框
    @State private var showingOperators = false
    // 是否显示照片选择器
    @State private var showingPhotosPicker = false
    // 照片所选项目
    @State private var selectedItem: PhotosPickerItem?
    
    // 是否使用相机
    @State private var showingCamera = false
    
    // 要处理的图片
    @State private var processImage: Image?
    
    // 提取的主要颜色
    @State private var dominantColors: [Color] = []
    // 选中的颜色
    @State private var selectedColor: Color?
    
    @State private var rgbIntValue : (red: Int, green: Int, blue: Int)?
    @State private var cmykIntValue: (cyan: Int, magenta: Int, yellow: Int, black: Int)?
    @State private var hsbIntValue: (hue: Int, saturation: Int, brightness: Int)?
    
    // 是否为纯色图片
    @State private var isSolidColor: Bool = false
    // 主色
    @State private var mainColor: Color = .clear
    
    
    var body: some View {
        VStack {
            // 图片显示区域
            if let processImage {
                processImage
                    .resizable()
                    .scaledToFit()
            }
            
            // 主要颜色调色板（考虑不是纯色图片的情况, 从用户选择的图片中获取主要颜色)
            if !dominantColors.isEmpty {
                ColorPaletteView(colors: dominantColors, selectedColor: selectedColor, onColorSelcted: {
                    color in
                    selectedColor = color
                    // 解析当前选中颜色, 这个颜色是纯色, 直接进行颜色分解即可
                    analyzeSelectedColor(color)
                    
                })
            }
            // 针对某种特定颜色(纯色), 进行颜色分解, 显示分解结果视图
            if let rgbIntValue, let cmykIntValue, let hsbIntValue {
                ColorAnalysisResultView(rgbValue: rgbIntValue, cmykValue: cmykIntValue, hsbValue: hsbIntValue, mainColor: selectedColor ?? mainColor, isSolidColor: isSolidColor)
                    .padding(.horizontal, 20)
            } else {
                Spacer()
                    .frame(height: 400)
                    .padding(.horizontal, 20)
            }
            
            Spacer()
            Button {
                // 点击显示对话框菜单
                showingOperators = true
            } label: {
                Image(systemName: "plus")
                    .font(.title)
                    .padding()
                    .background(
                        LinearGradient(colors: [
                            // 使用自定义颜色构造器创建颜色
                            Color(hex: 0x696969),
                            Color(hex: 0xb8860b)
                        ], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .foregroundStyle(.white)
                    .clipShape(.circle)
            }
        }
        .confirmationDialog("", isPresented: $showingOperators) {
            Button("选择图片") {
                // 显示图片选择器
                showingPhotosPicker = true
            }
            
            Button("拍照") {
                // 显示拍摄界面
                showingCamera = true
            }
        }
        .padding()
        .photosPicker(isPresented: $showingPhotosPicker, selection: $selectedItem)
        // 只要用户选择图片就执行加载图片操作
        .onChange(of: selectedItem, loadImage)
    }
    
    
    func loadImage()  {
        Task {
            // 获取照片数据
            guard let imageData = try await selectedItem?.loadTransferable(type: Data.self) else { return }
            // 将照片数据转换成 UIImage
            guard let inputImage = UIImage(data: imageData) else { return }
            processImage = Image(uiImage: inputImage) // 从 UIImage 转换 Image
            // 对图片进行颜色解析
            analyzeColor(uiImage: inputImage)
        }
    }
    
    func analyzeColor(uiImage: UIImage) {
        // 1. 提取图片的主要颜色（使用聚类方法获取图片颜色类别)
        let extractedColors = ColorExtractor.extractDominantColors(from: uiImage, maxColors: 5)
        dominantColors = extractedColors
        
        // 2. 设置第一个主要颜色为默认选中
        if let firstColor = extractedColors.first {
            selectedColor = firstColor
            analyzeSelectedColor(firstColor)
        }

        // 3. 计算图片的平均色
        guard let avgUIColor = uiImage.averageColor() else { return }
        let avgColor = Color(avgUIColor)
        mainColor = avgColor
        
        // 4. 判断图片是否是纯色图片
        isSolidColor = isImageSolidColor(uiImage: uiImage)
    }
    
    func analyzeSelectedColor(_ color: Color) {
        // 计算选中颜色的 RGB, CMYK, HSB 分量值
        rgbIntValue = color.rgbIntValue()
        cmykIntValue = color.cmykIntValue()
        hsbIntValue = color.hsbIntValue()
    }
    
    /**
     判断图片是否为纯色图片
     */
    func isImageSolidColor(uiImage: UIImage, threshold: CGFloat = 0.05) -> Bool {
        guard let cgImage = uiImage.cgImage else { return false }
        let width = cgImage.width
        let height = cgImage.height
        guard let data = cgImage.dataProvider?.data,
              let ptr = CFDataGetBytePtr(data) else { return false }
        let bytesPerPixel = cgImage.bitsPerPixel / 8
        
        let sampleCount = min(20000, width * height)
        let step = max(1, (width * height) / sampleCount)
        
        guard let avgUIColor = uiImage.averageColor() else { return false}
        var r0: CGFloat = 0, g0: CGFloat = 0, b0: CGFloat = 0, a0: CGFloat = 0
        avgUIColor.getRed(&r0, green: &g0, blue: &b0, alpha: &a0)
        
        var maxDiff: CGFloat = 0
        for i in stride(from: 0, to: width * height , by: step) {
            let pixel = i * bytesPerPixel
            let r = CGFloat(ptr[pixel]) / 255.0
            let g = CGFloat(ptr[pixel + 1]) / 255.0
            let b = CGFloat(ptr[pixel + 2]) / 255.0
//            let a = CGFloat(ptr[pixel + 3]) / 255.0
            
            let diff = abs(r - r0) + abs(g - g0) + abs(b - b0)
            if diff > maxDiff {
                maxDiff = diff
            }
            if maxDiff > threshold {
                return false
            }
        }
        return true
    }
}

#Preview {
    ContentView()
}
