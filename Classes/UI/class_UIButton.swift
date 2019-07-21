//
//  class_UIButton.swift
//  Pods
//
//  Created by Cc on 2017/9/9.
//
//

import UIKit

public class class_UIButton: UIButton {
    
    public typealias tClickBlock = ((_ sender: class_UIButton) -> Void)?
    
    public var mClickBlock: tClickBlock = nil
    
    public override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        self.addTarget(self, action: #selector(onClick(sender:)), for: .touchUpInside)
    }
    
    deinit {
        
        self.removeTarget(self, action: nil, for: .allTouchEvents)
        CLSLogInfo("deinit class_UIButton")
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func onClick(sender: class_UIButton) {
        
        if let block = mClickBlock {
            
            block(sender)
        }
    }
}
