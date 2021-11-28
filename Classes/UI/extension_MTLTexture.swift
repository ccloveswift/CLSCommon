//
//  UIImage.swift
//  Today
//
//  Created by Alexey Globchastyy on 15/09/14.
//  Copyright (c) 2014 Alexey Globchastyy. All rights reserved.
//
import UIKit
import MetalKit
import MetalPerformanceShaders

public extension MTLTexture {
    
    @available(iOS 13.0, *)
    func e_copyTexture(_ dest: MTLTexture)
    {
        guard let device = MTLCreateSystemDefaultDevice() else { return }
        guard let queue = device.makeCommandQueue() else { return }
        
        var from: MTLTexture = self
        if self.width != dest.width || self.height != dest.height {
            let scalex: Double = 1.0 * Double(dest.width) / Double(self.width)
            let scaley: Double = 1.0 * Double(dest.height) / Double(self.height)
            let scaleTransform: MPSScaleTransform = MPSScaleTransform(scaleX: scalex, scaleY: scaley, translateX: 0, translateY: 0)
            let imageLanczosScale: MPSImageLanczosScale = MPSImageLanczosScale(device: device)
            withUnsafePointer(to: scaleTransform) { ptr in
                imageLanczosScale.scaleTransform = ptr
            }
            
            let descriptor: MTLTextureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: self.pixelFormat, width: dest.width, height: dest.height, mipmapped: false)
            let usage = (MTLTextureUsage.shaderRead.rawValue | MTLTextureUsage.shaderWrite.rawValue | MTLTextureUsage.renderTarget.rawValue)
            descriptor.usage = MTLTextureUsage.init(rawValue: usage)
            
            guard let tempDest: MTLTexture = device.makeTexture(descriptor: descriptor) else { return }
            guard let tempCommandBuffer: MTLCommandBuffer = queue.makeCommandBuffer() else { return }
            imageLanczosScale.encode(commandBuffer: tempCommandBuffer, sourceTexture: self, destinationTexture: tempDest)
            tempCommandBuffer.commit()
            tempCommandBuffer.waitUntilCompleted()
            from = tempDest
        }
        
        guard let commandBuffer = queue.makeCommandBuffer() else { return }
        guard let commandEncoder: MTLBlitCommandEncoder = commandBuffer.makeBlitCommandEncoder() else { return }
        commandEncoder.copy(from: from, to: dest)
        commandEncoder.endEncoding()
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
    }
}
