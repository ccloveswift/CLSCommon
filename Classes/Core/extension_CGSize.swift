//
//  extension_CGSize.swift
//  Pods
//
//  Created by Cc on 2017/8/25.
//
//

import Foundation

public extension CGSize {
 
    /// 当前的size 适配到preview size上，如果size 远小于preview size 不放大
    ///
    /// - Parameter previewSize: 需要显示的大小
    /// - Returns: 合适的size
    public func e_GetMaxFullSize(previewSize: CGSize) -> CGSize {
        
        // 图片size 比例
        let OrgImgBiLi: CGFloat = self.width / self.height // 1 / 2
        let previewBiLi: CGFloat = previewSize.width / previewSize.height // 2 / 1
        
        if OrgImgBiLi > previewBiLi {
            // 宽缩放到相等
            let newW = self.width > previewSize.width ? previewSize.width : self.width
            let newH = newW / OrgImgBiLi
            return CGSize(width: newW, height: newH)
        }
        else if OrgImgBiLi < previewBiLi {
            // 高缩放到相等
            let newH = self.height > previewSize.height ? previewSize.height : self.height
            let newW = OrgImgBiLi * newH
            return CGSize(width: newW, height: newH)
        }
        else {
            // 相等
            if (self.width > previewSize.width) {
                
                return previewSize
            }
            else {
                
                return self
            }
        }
    }
}
