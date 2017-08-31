//
//  IconView.swift
//  Chess
//
//  Created by Edoardo Franco Vianelli on 8/31/17.
//  Copyright © 2017 Edoardo Franco Vianelli. All rights reserved.
//

import UIKit

class IconView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.layer.borderWidth = 1
        self.layer.cornerRadius = self.frame.size.width / 16
    }
}

extension UIView{
    func snapshot() -> UIImage? {
        UIGraphicsBeginImageContext(CGSize(width: frame.size.width, height: frame.size.height))
        drawHierarchy(in: CGRect(x: 0.0, y: 0.0, width: frame.size.width, height: frame.size.height), afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

