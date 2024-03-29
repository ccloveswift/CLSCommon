//
//  UIImage.swift
//  Today
//
//  Created by Alexey Globchastyy on 15/09/14.
//  Copyright (c) 2014 Alexey Globchastyy. All rights reserved.
//
import UIKit
import Accelerate

public extension UIImage {
    
    public func e_ApplyHighPenetrationBlur() -> UIImage? {
        
        return e_ApplyBlurWithRadius(8, tintColor: UIColor(white: 1, alpha: 0.1), saturationDeltaFactor: 1.8)
    }
    public func e_ApplyLightEffect() -> UIImage? {
        return e_ApplyBlurWithRadius(30, tintColor: UIColor(white: 1.0, alpha: 0.3), saturationDeltaFactor: 1.8)
    }
    
    public func e_ApplyExtraLightEffect() -> UIImage? {
        return e_ApplyBlurWithRadius(20, tintColor: UIColor(white: 0.97, alpha: 0.82), saturationDeltaFactor: 1.8)
    }
    
    public func e_ApplyDarkEffect() -> UIImage? {
        return e_ApplyBlurWithRadius(20, tintColor: UIColor(white: 0.11, alpha: 0.73), saturationDeltaFactor: 1.8)
    }
    
    public func e_ApplyTintEffectWithColor(_ tintColor: UIColor) -> UIImage? {
        let effectColorAlpha: CGFloat = 0.6
        var effectColor = tintColor
        
        let componentCount = tintColor.cgColor.numberOfComponents
        
        if componentCount == 2 {
            var b: CGFloat = 0
            if tintColor.getWhite(&b, alpha: nil) {
                effectColor = UIColor(white: b, alpha: effectColorAlpha)
            }
        } else {
            var red: CGFloat = 0
            var green: CGFloat = 0
            var blue: CGFloat = 0
            
            if tintColor.getRed(&red, green: &green, blue: &blue, alpha: nil) {
                effectColor = UIColor(red: red, green: green, blue: blue, alpha: effectColorAlpha)
            }
        }
        
        return e_ApplyBlurWithRadius(10, tintColor: effectColor, saturationDeltaFactor: -1.0, maskImage: nil)
    }
    
    public func e_ApplyBlurWithRadius(_ blurRadius: CGFloat, tintColor: UIColor?, saturationDeltaFactor: CGFloat, maskImage: UIImage? = nil) -> UIImage? {
        // Check pre-conditions.
        if (size.width < 1 || size.height < 1) {
            CLSLogInfo("*** error: invalid size: \(size.width) x \(size.height). Both dimensions must be >= 1: \(self)")
            return nil
        }
        guard let cgImage = self.cgImage else {
            CLSLogInfo("*** error: image must be backed by a CGImage: \(self)")
            return nil
        }
        if maskImage != nil && maskImage!.cgImage == nil {
            CLSLogInfo("*** error: maskImage must be backed by a CGImage: \(maskImage!)")
            return nil
        }
        
//        let __FLT_EPSILON__ = CGFloat(FLT_EPSILON)
        let __FLT_EPSILON__ = CGFloat(Float.ulpOfOne)
        let screenScale = UIScreen.main.scale
        let imageRect = CGRect(origin: CGPoint.zero, size: size)
        var effectImage = self
        
        let hasBlur = blurRadius > __FLT_EPSILON__
        let hasSaturationChange = fabs(saturationDeltaFactor - 1.0) > __FLT_EPSILON__
        
        if hasBlur || hasSaturationChange {
            func createEffectBuffer(_ context: CGContext) -> vImage_Buffer {
                let data = context.data
                let width = vImagePixelCount(context.width)
                let height = vImagePixelCount(context.height)
                let rowBytes = context.bytesPerRow
                
                return vImage_Buffer(data: data, height: height, width: width, rowBytes: rowBytes)
            }
            
            UIGraphicsBeginImageContextWithOptions(size, false, screenScale)
            guard let effectInContext = UIGraphicsGetCurrentContext() else { return  nil }
            
            effectInContext.scaleBy(x: 1.0, y: -1.0)
            effectInContext.translateBy(x: 0, y: -size.height)
            effectInContext.draw(cgImage, in: imageRect)
            
            var effectInBuffer = createEffectBuffer(effectInContext)
            
            
            UIGraphicsBeginImageContextWithOptions(size, false, screenScale)
            
            guard let effectOutContext = UIGraphicsGetCurrentContext() else { return  nil }
            var effectOutBuffer = createEffectBuffer(effectOutContext)
            
            
            if hasBlur {
                // A description of how to compute the box kernel width from the Gaussian
                // radius (aka standard deviation) appears in the SVG spec:
                // http://www.w3.org/TR/SVG/filters.html#feGaussianBlurElement
                //
                // For larger values of 's' (s >= 2.0), an approximation can be used: Three
                // successive box-blurs build a piece-wise quadratic convolution kernel, which
                // approximates the Gaussian kernel to within roughly 3%.
                //
                // let d = floor(s * 3*sqrt(2*pi)/4 + 0.5)
                //
                // ... if d is odd, use three box-blurs of size 'd', centered on the output pixel.
                //
                let inputRadius = blurRadius * screenScale
                let d = floor(inputRadius * 3.0 * CGFloat(sqrt(2 * Double.pi) / 4 + 0.5))
                var radius = UInt32(d)
                if radius % 2 != 1 {
                    radius += 1 // force radius to be odd so that the three box-blur methodology works.
                }
                
                let imageEdgeExtendFlags = vImage_Flags(kvImageEdgeExtend)
                
                vImageBoxConvolve_ARGB8888(&effectInBuffer, &effectOutBuffer, nil, 0, 0, radius, radius, nil, imageEdgeExtendFlags)
                vImageBoxConvolve_ARGB8888(&effectOutBuffer, &effectInBuffer, nil, 0, 0, radius, radius, nil, imageEdgeExtendFlags)
                vImageBoxConvolve_ARGB8888(&effectInBuffer, &effectOutBuffer, nil, 0, 0, radius, radius, nil, imageEdgeExtendFlags)
            }
            
            var effectImageBuffersAreSwapped = false
            
            if hasSaturationChange {
                let s: CGFloat = saturationDeltaFactor
                let floatingPointSaturationMatrix: [CGFloat] = [
                    0.0722 + 0.9278 * s,  0.0722 - 0.0722 * s,  0.0722 - 0.0722 * s,  0,
                    0.7152 - 0.7152 * s,  0.7152 + 0.2848 * s,  0.7152 - 0.7152 * s,  0,
                    0.2126 - 0.2126 * s,  0.2126 - 0.2126 * s,  0.2126 + 0.7873 * s,  0,
                    0,                    0,                    0,  1
                ]
                
                let divisor: CGFloat = 256
                let matrixSize = floatingPointSaturationMatrix.count
                var saturationMatrix = [Int16](repeating: 0, count: matrixSize)
                
                for i: Int in 0 ..< matrixSize {
                    saturationMatrix[i] = Int16(round(floatingPointSaturationMatrix[i] * divisor))
                }
                
                if hasBlur {
                    vImageMatrixMultiply_ARGB8888(&effectOutBuffer, &effectInBuffer, saturationMatrix, Int32(divisor), nil, nil, vImage_Flags(kvImageNoFlags))
                    effectImageBuffersAreSwapped = true
                } else {
                    vImageMatrixMultiply_ARGB8888(&effectInBuffer, &effectOutBuffer, saturationMatrix, Int32(divisor), nil, nil, vImage_Flags(kvImageNoFlags))
                }
            }
            
            if !effectImageBuffersAreSwapped {
                effectImage = UIGraphicsGetImageFromCurrentImageContext()!
            }
            
            UIGraphicsEndImageContext()
            
            if effectImageBuffersAreSwapped {
                effectImage = UIGraphicsGetImageFromCurrentImageContext()!
            }
            
            UIGraphicsEndImageContext()
        }
        
        // Set up output context.
        UIGraphicsBeginImageContextWithOptions(size, false, screenScale)
        
        guard let outputContext = UIGraphicsGetCurrentContext() else { return nil }
        
        outputContext.scaleBy(x: 1.0, y: -1.0)
        outputContext.translateBy(x: 0, y: -size.height)
        
        // Draw base image.
        outputContext.draw(cgImage, in: imageRect)
        
        // Draw effect image.
        if hasBlur {
            outputContext.saveGState()
            if let maskCGImage = maskImage?.cgImage {
                outputContext.clip(to: imageRect, mask: maskCGImage);
            }
            outputContext.draw(effectImage.cgImage!, in: imageRect)
            outputContext.restoreGState()
        }
        
        // Add in color tint.
        if let color = tintColor {
            outputContext.saveGState()
            outputContext.setFillColor(color.cgColor)
            outputContext.fill(imageRect)
            outputContext.restoreGState()
        }
        
        // Output image is ready.
        let outputImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return outputImage
    }
}

public extension UIImage {
    
    
    /// 压缩图片
    ///
    /// - Parameters:
    ///   - size: 大小
    ///   - usingSizeDrawContext: 。。。
    /// - Returns: 图片
    public func e_EqualRatioToSize(size: CGSize, usingSizeDrawContext: Bool) -> UIImage? {
        
        var width: CGFloat = CGFloat(self.cgImage!.width)
        var height: CGFloat = CGFloat(self.cgImage!.height)
        
        let verticalRadio = size.height * 1.0 / height;
        let horizontalRadio = size.width * 1.0 / width;
        
        var radio: CGFloat = 1.0;
        if verticalRadio > 1 && horizontalRadio > 1 {
            
            radio = verticalRadio > horizontalRadio ? horizontalRadio : verticalRadio;
        }
        else {
            
            radio = verticalRadio < horizontalRadio ? verticalRadio : horizontalRadio;
        }
        
        width = CGFloat(width * radio);
        height = CGFloat(height * radio);
        
        // 创建一个bitmap的context
        // 并把它设置成为当前正在使用的context
        if (usingSizeDrawContext) {
            
            UIGraphicsBeginImageContext(size);
            // 绘制改变大小的图片
            let xPos = (size.width - width) / 2;
            let yPos = (size.height - height) / 2;
            self .draw(in: CGRect(x: xPos, y: yPos, width: width, height: height))
        }
        else {
            
            UIGraphicsBeginImageContext(CGSize(width: width, height: height))
            self .draw(in: CGRect(x: 0, y: 0, width: width, height: height))
        }
        
        // 从当前context中创建一个改变大小后的图片
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        
        // 使当前的context出堆栈
        UIGraphicsEndImageContext();
        
        // 返回新的改变大小后的图片
        return scaledImage;
    }

    
    /// 裁剪图片
    ///
    /// - Parameter rect: 大小 （绝对值）
    /// - Returns: 图片
    public func e_RectImageOfRect(rect: CGRect, scale: CGFloat) -> UIImage? {
        
        let sourceImageRef = self.cgImage
        
        let newRect = CGRect.init(x: rect.origin.x * scale, y: rect.origin.y * scale, width: rect.size.width * scale, height: rect.size.height * scale)
        let newImageRef = sourceImageRef?.cropping(to: newRect)
        
        if let imgRef = newImageRef {
        
            return UIImage.init(cgImage: imgRef, scale: self.scale, orientation: self.imageOrientation)
        }
        else {
            
            assert(false)
            return self
        }
    }

    /// 矫正图片
    ///
    /// - Returns: 返回一张图片
    public func e_FixedOrientation() -> UIImage {
        
        return e_Rotation(imgOrientation: self.imageOrientation)
    }
    
    public func e_Rotation(imgOrientation: UIImage.Orientation) -> UIImage {
        
        let imageOrientation = imgOrientation
        if imageOrientation == .up {
            
            return self
        }
        
        let imgRef = self.cgImage
        let width = CGFloat(imgRef!.width)
        let height = CGFloat(imgRef!.height)
        var transform = CGAffineTransform.identity
        var bounds = CGRect.init(x: 0, y: 0, width: width, height: height)
        let scaleRatio:CGFloat = 1
        var boundHeight: CGFloat = 0
        let orient = imageOrientation;
        switch orient {
        case .up: //EXIF = 1
            transform = CGAffineTransform.identity
        case .upMirrored: //EXIF = 2
            transform = CGAffineTransform(translationX: width, y: 0.0);
            transform = transform.scaledBy(x: -1.0, y: 1.0)
        case .down: //EXIF = 3
            transform = CGAffineTransform(translationX: width, y: height);
            transform = transform.rotated(by: CGFloat(M_PI))
        case .downMirrored: //EXIF = 4
            transform = CGAffineTransform(translationX: 0.0, y: height);
            transform = transform.scaledBy(x: 1.0, y: -1.0)
        case .leftMirrored: //EXIF = 5
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransform(translationX: height, y: width);
            transform = transform.scaledBy(x: -1.0, y: 1.0)
            transform = transform.rotated(by: CGFloat(3.0 * M_PI / 2.0))
        case .left: //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransform(translationX: 0.0, y: width);
            transform = transform.rotated(by: CGFloat(3.0 * M_PI / 2.0))
        case .rightMirrored: //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransform(scaleX: -1.0, y: 1.0);
            transform = transform.rotated(by: CGFloat(M_PI / 2.0))
        case .right: //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransform(translationX: height, y: 0.0);
            transform = transform.rotated(by: CGFloat(M_PI / 2.0))
        default:
            break
        }
        
        UIGraphicsBeginImageContext(bounds.size);
        let context: CGContext = UIGraphicsGetCurrentContext()!
        if (orient == .right || orient == .left) {
            
            context.scaleBy(x: -scaleRatio, y: scaleRatio)
            context.translateBy(x: -height, y: 0)
        }
        else {
            
            context.scaleBy(x: scaleRatio, y: -scaleRatio)
            context.translateBy(x: 0, y: -height)
        }
        context.concatenate(transform)
        context.draw(imgRef!, in: CGRect.init(x: 0, y: 0, width: width, height: height))
        
        let imageCopy = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return imageCopy!
    }

    public func e_RatioToSize(size: CGSize) -> UIImage? {
        
        // 创建一个bitmap的context
        // 并把它设置成为当前正在使用的context
        UIGraphicsBeginImageContext(size)
        self .draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        // 从当前context中创建一个改变大小后的图片
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        
        // 使当前的context出堆栈
        UIGraphicsEndImageContext();
        
        // 返回新的改变大小后的图片
        return scaledImage;
    }
}
