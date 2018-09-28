//
//  CoinsHeaderBgView.swift
//  MyCoin
//
//  Created by GaoWanli on 31/01/2018.
//  Copyright © 2018 wl. All rights reserved.
//

import UIKit

class CoinsHeaderBgView: UIView {
    private var bgImageView: UIImageView = UIImageView()
    private var arcImageView: UIImageView = UIImageView()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    private func setup() {
        bgImageView.image = #imageLiteral(resourceName: "bg")
        bgImageView.contentMode = .top
        bgImageView.clipsToBounds = true
        addSubview(bgImageView)
        
        arcImageView.image = #imageLiteral(resourceName: "home_bg_arc")
        addSubview(arcImageView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        bgImageView.frame = bounds
        let imgHeight = arcImageView.image?.size.height ?? 0.00
        arcImageView.frame = CGRect(x: 0.0, y: bounds.height - imgHeight, width: bounds.width, height: imgHeight)
    }
}
