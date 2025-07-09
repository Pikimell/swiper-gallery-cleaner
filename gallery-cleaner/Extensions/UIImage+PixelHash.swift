//
//  UIImage+PixelHash.swift
//  gallery-cleaner
//
//  Created by Володимир Пащенко on 09.07.2025.
//

import UIKit

extension UIImage {
    /// Зменшує зображення до вказаного розміру
    func resize(to size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        draw(in: CGRect(origin: .zero, size: size))
        let resized = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resized
    }

    /// Конвертує в градації сірого
    func grayscale() -> UIImage? {
        let context = CIContext()
        guard let ciImage = CIImage(image: self) else { return nil }
        guard let filter = CIFilter(name: "CIPhotoEffectMono") else { return nil }
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        guard let output = filter.outputImage,
              let cgImage = context.createCGImage(output, from: output.extent) else {
            return nil
        }
        return UIImage(cgImage: cgImage)
    }

    /// Повертає одномірний масив інтенсивностей (0–255)
    func pixelIntensityArray() -> [UInt8]? {
        guard let cgImage = self.cgImage else { return nil }
        let width = Int(self.size.width)
        let height = Int(self.size.height)
        let bytesPerPixel = 1
        let bytesPerRow = width * bytesPerPixel
        var pixelData = [UInt8](repeating: 0, count: width * height)

        let colorSpace = CGColorSpaceCreateDeviceGray()
        guard let context = CGContext(data: &pixelData,
                                      width: width,
                                      height: height,
                                      bitsPerComponent: 8,
                                      bytesPerRow: bytesPerRow,
                                      space: colorSpace,
                                      bitmapInfo: 0) else {
            return nil
        }

        context.draw(cgImage, in: CGRect(origin: .zero, size: self.size))
        return pixelData
    }
    
    func resizeMaintainingAspect(to targetSize: CGSize) -> UIImage? {
            let aspectWidth = targetSize.width / size.width
            let aspectHeight = targetSize.height / size.height
            let scaleFactor = min(aspectWidth, aspectHeight)

            let scaledSize = CGSize(width: size.width * scaleFactor,
                                    height: size.height * scaleFactor)
            let renderer = UIGraphicsImageRenderer(size: scaledSize)

            return renderer.image { _ in
                self.draw(in: CGRect(origin: .zero, size: scaledSize))
            }
        }
}
