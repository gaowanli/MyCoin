//
//  GradientView.swift
//  MyCoin
//
//  Created by GaoWanli on 30/01/2018.
//  Copyright © 2018 wl. All rights reserved.
//

import UIKit

class GradientView: UIView {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    override public class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setup()
    }
    
    private func setup() {
        guard let gradientLayer = self.layer as? CAGradientLayer else { return }
        
        gradientLayer.startPoint = .zero
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.0)
        let beginColor = UIColor.hex(value: 0x28E1B3).cgColor
        let endColor = UIColor.hex(value: 0x23BBF2).cgColor
        gradientLayer.colors = [beginColor, endColor]
    }
}
