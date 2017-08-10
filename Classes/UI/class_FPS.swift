//
//  class_FPS.swift
//  Pods
//
//  Created by Cc on 2017/8/4.
//
//

import Foundation
import CoreMedia

public class class_FPS {
    
    private var link: CADisplayLink?
    
    private var lastTime: TimeInterval = 0.0;
    
    private var count:Int = 0;
    
    private var _frameRate: Double = 0
    // fps帧率
    public var mFrameRate: Double {
        
        return _frameRate
    }
    // fps帧率block
    public var mFrameRateBlock: ((_ fps: Double) -> Void)?
    
    public init() {
        
        link = CADisplayLink.init(target: self, selector: #selector(self.didTick(link:)))
        link?.add(to: RunLoop.current, forMode: .commonModes)
    }
    
    deinit{
        
        link?.invalidate()
    }
    
    @objc func didTick(link: CADisplayLink){
        
        if lastTime == 0 {
            lastTime = link.timestamp
            return
        }
        count += 1
        
        let delta = link.timestamp - lastTime
        
        if delta < 1 {
            return
        }
        
        lastTime = link.timestamp
        
        // 帧数========>可以自己定义作为label显示
        let fps = Double(count) / delta
        
        count = 0
        
        _frameRate = fps
        
        if let block = mFrameRateBlock {
           
            block(fps)
        }
    }
}

public class class_FPSLabel: UILabel {
    
    private var link: class_FPS?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    
        link = class_FPS.init()
        link?.mFrameRateBlock = { (fps: Double) in
        
            self.text = String(format: "%02.0f FPS", round(fps))
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

