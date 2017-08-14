//
//  extension_bu.swift
//  Pods
//
//  Created by Cc on 2017/8/11.
//
//

import Foundation
import CoreImage
import AVFoundation

public extension CMSampleBuffer {

    public func e_GotUIImage() -> UIImage? {
        
        if let pixelBuffer = CMSampleBufferGetImageBuffer(self) {
            
            let ciImage: CIImage = CIImage.init(cvPixelBuffer: pixelBuffer)
            
            let context = CIContext.init()
            
            if let myImage = context.createCGImage(ciImage, from: CGRect.init(x: 0, y: 0, width: CVPixelBufferGetWidth(pixelBuffer), height: CVPixelBufferGetHeight(pixelBuffer))) {
                
                let uiImage = UIImage.init(cgImage: myImage)
                
                return uiImage
            }
        }
        
       return nil
    }
}

