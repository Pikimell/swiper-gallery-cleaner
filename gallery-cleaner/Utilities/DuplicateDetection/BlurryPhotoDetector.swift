import Foundation
import UIKit
import CoreImage

/// Відповідає за виявлення розмитих фото через різкість (variance of Laplacian)
struct BlurryPhotoDetector {

    /// Обчислює "різкість" через дисперсію Лапласіана
    static func sharpness(of image: UIImage) -> Float? {
        guard let cgImage = image.cgImage else { return nil }

        let ciImage = CIImage(cgImage: cgImage)
        let context = CIContext(options: nil)

        guard let laplacianFilter = CIFilter(name: "Laplacian") ?? laplacianFallback(ciImage: ciImage),
              let outputImage = laplacianFilter.outputImage,
              let bitmap = context.createCGImage(outputImage, from: outputImage.extent)
        else {
            return nil
        }

        guard let data = bitmap.dataProvider?.data as Data?,
              let ptr = CFDataGetBytePtr(data as CFData)
        else {
            return nil
        }

        let count = CFDataGetLength(data as CFData)
        guard count > 0 else { return nil }

        var sum: Float = 0
        var sumSq: Float = 0

        for i in 0..<count {
            let val = Float(ptr[i])
            sum += val
            sumSq += val * val
        }

        let mean = sum / Float(count)
        let variance = (sumSq / Float(count)) - (mean * mean)
        return variance
    }

    /// У fallback-фільтрі використовуємо edge-detection через Convolution
    static func laplacianFallback(ciImage: CIImage) -> CIFilter? {
        let weights: [CGFloat] = [
            0,  1, 0,
            1, -4, 1,
            0,  1, 0
        ]

        let filter = CIFilter(name: "CIConvolution3X3")
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        filter?.setValue(CIVector(values: weights, count: weights.count), forKey: "inputWeights")
        filter?.setValue(1.0, forKey: "inputBias")
        return filter
    }

    /// Обчислює різкість для кожного фото, і групує ті, які нижче порогу
    static func groupBlurryPhotos(from photos: [PhotoItem],
                                  targetSize: CGSize = CGSize(width: 150, height: 150),
                                  blurThreshold: Float = 50.0,
                                  progress: ((Int) -> Void)? = nil,
                                  completion: @escaping ([[PhotoItem]]) -> Void) {
        var blurry: [PhotoItem] = []
        var scanned = 0

        let group = DispatchGroup()

        for photo in photos {
            group.enter()

            photo.thumbnail(targetSize: targetSize) { image in
                defer {
                    DispatchQueue.main.async {
                        scanned += 1
                        progress?(scanned)
                    }
                    group.leave()
                }

                guard let image = image,
                      let score = sharpness(of: image) else { return }

                if score < blurThreshold {
                    blurry.append(photo)
                }
            }
        }

        group.notify(queue: .main) {
            completion(blurry.isEmpty ? [] : [blurry])
        }
    }
}
