//
//  ColorExtractor.swift
//  Colors
//
//  Created by Bo Huang on 2025/7/15.
//

/**
 颜色提取器
 */
import SwiftUI
import UIKit

struct ColorExtractor {
    /// 从图片中提取主要颜色
    /// - Parameters:
    ///     - image: 输入图片
    ///     - maxColors: 最大提取的颜色数目, 默认为 5 个
    ///     - minDistance: 颜色空间最小距离阈值, 图片色差在这个阈值内就认为是同一种颜色
    /// - Returns: 提取的主要颜色数组
    static func extractDominantColors(
        from image: UIImage,
        maxColors: Int = 5,
        minDistance: CGFloat = 0.1
    ) -> [Color] {
        
        // 1. 获取图片的所有像素点
        guard let pixelData = getPixelData(from: image) else { return []}
        
        // 2. 随机打乱像素点
        let shuffledPixelData = pixelData.shuffled()
        
        // 3. 取前 N 个 作为样本点, 比 2 万多则采样 2 万个
        let sampleCount = min(shuffledPixelData.count, 20000)
        let samplePixelData = Array(shuffledPixelData[..<sampleCount])
        
        // 4. 使用 K-means 聚类算法来提取颜色
        let colors = kMeansClustering(pixelData: samplePixelData, k: maxColors, minDistance: minDistance)
        
        return colors.sorted { color1 , color2 in
            color1.percentage > color2.percentage
        }.map {
            $0.color
        }
    }
    
    // 获取图片像素数据
    private static func getPixelData(from image: UIImage) -> [UIColor]? {
        // 转换成 CGImage, 通过 CGImage 的方法来获取像素数据
        guard let cgImage = image.cgImage else { return nil }
        
        let width = cgImage.width
        let height = cgImage.height
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        
        // 获取数据
        guard let data = cgImage.dataProvider?.data,
              let ptr = CFDataGetBytePtr(data) else {
            return nil
        }
        
        var colors: [UIColor] = []
        
        // 对像素数据进行采样（每 4 个像素取 1 个, 提升性能)
        for y in stride(from: 0, to: height, by: 2) {
            for x in stride(from: 0, to: width, by: 2) {
                let pixelIndex = y * bytesPerRow + x * bytesPerPixel
                
                let r = CGFloat(ptr[pixelIndex]) / 255.0
                let g = CGFloat(ptr[pixelIndex + 1]) / 255.0
                let b = CGFloat(ptr[pixelIndex + 2]) / 255.0
                let a = CGFloat(ptr[pixelIndex + 3]) / 255.0
                
                // 忽略透明像素
                if a > 0.1 {
                    colors.append(UIColor(red: r, green: g, blue: b, alpha: a))
                }
            }
        }
        return colors
    }
    
    /**
     K-means 聚类获取聚类颜色及其占比
     */
    private static func kMeansClustering(
        pixelData: [UIColor],
        k: Int,
        minDistance: CGFloat
    ) -> [(color: Color, percentage: Double)] {
        
        guard !pixelData.isEmpty else { return [] }
        
        // 初始化聚类中心
        var centroids = (0..<k).map {
            _ in
            // 随机选择元素作为聚类中心
            pixelData.randomElement() ?? UIColor.black
        }
        
        var clusters : [[UIColor]] = Array(repeating: [], count: k)
        var converged  = false // 是否收敛
        var maxIterations = 50 // 最大迭代次数
        var iteration = 0 // 当前迭代次数
        
        while !converged && iteration < maxIterations {
            iteration += 1
            
            // 清空聚类
            clusters = Array(repeating: [], count: k)
            
            // 分配像素到最近的聚类中心
            for pixel in pixelData {
                var minDistance = CGFloat.greatestFiniteMagnitude
                var closestClusters = 0
                
                for (i, centroid) in centroids.enumerated() {
                    let distance = colorDistance(pixel, centroid)
                    
                    if distance < minDistance {
                        minDistance = distance
                        closestClusters = i
                    }
                }
                
                clusters[closestClusters].append(pixel)
            }
            
            // 更新聚类中心
            var newCentroids: [UIColor] = []
            converged = true
            
            for (i, cluster) in clusters.enumerated() {
                if cluster.isEmpty {
                    newCentroids.append(centroids[i])
                    continue
                }
                // 取平均色作为新的聚类中心
                let newCentroid = averageColor(cluster)
                newCentroids.append(newCentroid)
                
                // 检查是否收敛
                if colorDistance(centroids[i], newCentroid) > minDistance {
                    converged = false
                }
            }
            
            centroids = newCentroids
        }
        
        // 计算每个聚类的占比
        let totalPixels = pixelData.count
        var result : [(color: Color, percentage: Double)] = []
        
        for (i, cluster) in clusters.enumerated() {
            if !cluster.isEmpty {
                let percentage = Double(cluster.count) / Double(totalPixels)
                let color = Color(centroids[i])
                result.append((color: color, percentage: percentage))
            }
        }
        return result
    }
    
    /**
     计算两个颜色间的距离
     */
    private static func colorDistance(_ lhs: UIColor, _ rhs: UIColor) -> CGFloat {
        var r1 : CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2 : CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
        
        lhs.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        rhs.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        
        // 计算欧几里得距离
        let dr = r1 - r2
        let dg = g1 - g2
        let db = b1 - b2
        return sqrt(dr * dr + dg * dg + db * db)
    }
    
    /**
     计算一个颜色数组的平均色
     */
    private static func averageColor(_ colors: [UIColor]) -> UIColor {
        guard !colors.isEmpty else { return UIColor.black }
        
        var totalR: CGFloat = 0
        var totalG: CGFloat = 0
        var totalB: CGFloat = 0
        var totalA: CGFloat = 0
        
        for color in colors {
            var r : CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
            color.getRed(&r, green: &g, blue: &b, alpha: &a)
            
            totalR += r
            totalG += g
            totalB += b
            totalA += a
        }
        
        let count = CGFloat(colors.count)
        return UIColor(
            red: totalR / count,
            green: totalG / count,
            blue: totalB / count,
            alpha: totalA / count,
        )
    }
}
