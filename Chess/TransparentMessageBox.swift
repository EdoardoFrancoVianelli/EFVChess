//
//  TransparentMessageBox.swift
//  Chess
//
//  Created by Edoardo Franco Vianelli on 3/29/17.
//  Copyright © 2017 Edoardo Franco Vianelli. All rights reserved.
//

import UIKit

class TransparentMessageBox: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    private var _msg = ""
    private var messageLabel = UILabel()
    
    func initAspect(){
        /*init the label*/
        messageLabel.frame.origin = .zero
        messageLabel.frame.size   = self.frame.size
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 4
        messageLabel.textColor = UIColor.darkGray
        self.addSubview(messageLabel)
        /*Init the outer containter*/
        self.layer.borderWidth = 0.0
        self.layer.cornerRadius = 6.0
        self.backgroundColor = UIColor.lightGray
        self.alpha = 0.9
    }
    
    func show(view : UIView, atPoint : CGPoint){
        view.addSubview(self)
        self.frame.origin.y = atPoint.y
        UIView.animate(withDuration: 1, animations: {
            self.frame.origin = atPoint
        })
        sleep(UInt32(self.seconds))
        UIView.animate(withDuration: 1, animations: {
            self.frame.origin = CGPoint(x: view.frame.size.width, y: self.frame.origin.y)
        })
    }
    
    var Message : String{
        set{
            self._msg = newValue
            self.messageLabel.text = self._msg
        }
        get{
            return self._msg
        }
    }
    
    private var seconds = 0
    
    init(dimensions : CGFloat, seconds : Int) {
        super.init(frame: CGRect(x: -dimensions, y: -dimensions, width: dimensions, height: dimensions))
        initAspect()
        self.seconds = seconds
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
