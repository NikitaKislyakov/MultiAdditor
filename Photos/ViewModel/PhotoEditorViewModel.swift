import SwiftUI
import Combine
import CoreImage
import CoreImage.CIFilterBuiltins

class PhotoEditorViewModel: ObservableObject {
    @Published var originalImage: UIImage
    @Published var processedImage: UIImage?

    @Published var selectedTool: EditorTool? = nil
    @Published var selectedAdjustment: AdjustmentOption? = nil

    // Adjustment values
    @Published var brightness: Double = 0.0
    @Published var contrast: Double = 1.0
    @Published var saturation: Double = 1.0
    @Published var sharpness: Double = 0.0
    @Published var exposure: Double = 0.0
    @Published var blur: Double = 0.0
    
    // Rotation
    @Published var rotationAngle: Double = 0.0
    
    // Color filters
    @Published var colorFilters: [ColorFilter] = []
    
    // Text
    @Published var overlayTexts: [OverlayText] = []

    private var ciContext = CIContext()
    private var currentCIImage: CIImage

    init(image: UIImage) {
        self.originalImage = image
        self.currentCIImage = CIImage(image: image) ?? CIImage()
        applyProcessing()
    }

    func valueForAdjustment(_ adjustment: AdjustmentOption) -> Double {
        switch adjustment {
        case .brightness: return brightness
        case .contrast: return contrast
        case .saturation: return saturation
        case .sharpness: return sharpness
        case .exposure: return exposure
        case .blur: return blur
        }
    }

    func setValueForAdjustment(_ adjustment: AdjustmentOption, newValue: Double) {
        switch adjustment {
        case .brightness: brightness = newValue
        case .contrast: contrast = newValue
        case .saturation: saturation = newValue
        case .sharpness: sharpness = newValue
        case .exposure: exposure = newValue
        case .blur: blur = newValue
        }
        applyProcessing()
    }
    
    func addColorFilter(_ filter: ColorFilter) {
        colorFilters.append(filter)
        applyProcessing()
    }
    
    func removeColorFilter(_ filter: ColorFilter) {
        colorFilters.removeAll { $0 == filter }
        applyProcessing()
    }
    
    func update(to newImage: UIImage) {
        self.originalImage = newImage
        self.currentCIImage = CIImage(image: newImage) ?? CIImage()
        applyProcessing()
    }

    func applyProcessing() {
        var outputImage = currentCIImage

        // Step 1: Color controls
        let colorFilter = CIFilter.colorControls()
        colorFilter.setValue(outputImage, forKey: kCIInputImageKey)
        colorFilter.brightness = Float(brightness)
        colorFilter.contrast = Float(contrast)
        colorFilter.saturation = Float(saturation)

        if let colorOutput = colorFilter.outputImage {
            outputImage = colorOutput
        }

        // Step 2: Exposure
        let exposureFilter = CIFilter.exposureAdjust()
        exposureFilter.setValue(outputImage, forKey: kCIInputImageKey)
        exposureFilter.ev = Float(exposure)

        if let exposureOutput = exposureFilter.outputImage {
            outputImage = exposureOutput
        }
        
        // Step 3: Rotation
        let rotationTransform = CGAffineTransform(rotationAngle: CGFloat(rotationAngle))
        outputImage = outputImage.transformed(by: rotationTransform)

        // Step 3: Sharpness
        let sharpnessFilter = CIFilter.sharpenLuminance()
        sharpnessFilter.setValue(outputImage, forKey: kCIInputImageKey)
        sharpnessFilter.sharpness = Float(sharpness)

        if let sharpnessOutput = sharpnessFilter.outputImage {
            outputImage = sharpnessOutput
        }

        // Step 4: Apply color filters
        for colorFilter in colorFilters {
            let filter = colorFilter.filter
            filter.setValue(outputImage, forKey: kCIInputImageKey)
            if let filteredOutput = filter.outputImage {
                outputImage = filteredOutput
            }
        }
        
        // Step 6: Blur
        if blur > 0 {
            let blurFilter = CIFilter.gaussianBlur()
            blurFilter.inputImage = outputImage
            blurFilter.radius = Float(blur)

            if let blurredOutput = blurFilter.outputImage {
                outputImage = blurredOutput
            }
        }

        if let cgImage = ciContext.createCGImage(outputImage, from: outputImage.extent) {
            processedImage = UIImage(cgImage: cgImage)
        } else {
            processedImage = originalImage
        }
    }

}

// MARK: - Tool Definitions

enum EditorTool: String, CaseIterable {
    case filters, rotate, crop, collage

    var icon: String {
        switch self {
        case .filters: return "Filters"
        case .rotate: return "Rotate"
        case .crop: return "Crop"
        case .collage: return "Collage"
        }
    }
}

enum AdjustmentOption: String, CaseIterable {
    case brightness, contrast, saturation, sharpness, exposure, blur

    var range: ClosedRange<Double> {
        switch self {
        case .brightness: return -1.0...1.0
        case .contrast: return 0.5...2.0
        case .saturation: return 0.0...2.0
        case .sharpness: return 0.0...2.0
        case .exposure: return -2.0...2.0
        case .blur: return 0.0...10.0
        }
    }
}

// MARK: - Color Filters

enum ColorFilter: Equatable, Hashable {
    case sepia
    case grayscale
    case colorInvert
    case colorMonochrome(color: Color)
    case colorPosterize(levels: Int)

    var filter: CIFilter {
        switch self {
        case .sepia:
            let filter = CIFilter.sepiaTone()
            filter.intensity = 1.0
            return filter
        case .grayscale:
            let filter = CIFilter.colorControls()
            filter.saturation = 0.0
            return filter
        case .colorInvert:
            return CIFilter.colorInvert()
        case .colorMonochrome(let color):
            let filter = CIFilter.colorMonochrome()
            filter.color = CIColor(color: UIColor(color))
            return filter
        case .colorPosterize(let levels):
            let filter = CIFilter.colorPosterize()
            filter.levels = Float(levels)
            return filter
        }
    }
}

// MARK: - Color Filters
struct OverlayText: Hashable {
    var text: String
    var position: CGPoint
    var fontSize: CGFloat
    var color: UIColor
}



