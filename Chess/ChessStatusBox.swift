//
//  ChessStatusBox.swift
//  Chess
//
//  Created by Edoardo Franco Vianelli on 2/15/17.
//  Copyright © 2017 Edoardo Franco Vianelli. All rights reserved.
//

import UIKit

@IBDesignable
class ChessStatusBox: UIView {
    
    override var frame: CGRect{
        didSet{
            initialize()
        }
    }
    
    override var bounds: CGRect{
        didSet{
            initialize()
        }
    }
    
    private var imageDisplayer : UIImageView
    private var pieceLabel : UILabel
    
    var image : UIImage{
        didSet{
            imageDisplayer.image = image
        }
    }

    private func initImage(){
        let dimension = self.frame.height
        let offset : CGFloat = 1
        imageDisplayer.frame.origin = CGPoint(x: offset, y: offset)
        imageDisplayer.frame.size = CGSize(width: dimension - 2 * offset, height: dimension - 2 * offset)
        if let pawn = UIImage(named: "chess-pawn.png"){
            image = pawn
        }
        /*imageDisplayer.layer.borderWidth = 1.0*/
        addSubview(imageDisplayer)
    }
    
    private func initLabel(){
        pieceLabel.text = "Pawn"
        pieceLabel.textAlignment = .center
        pieceLabel.numberOfLines = 2
        pieceLabel.frame.origin = CGPoint(x: imageDisplayer.frame.origin.x + imageDisplayer.frame.size.width,
                                          y: imageDisplayer.frame.origin.y)
        pieceLabel.frame.size.width = frame.size.width - pieceLabel.frame.origin.x
        pieceLabel.frame.size.height = frame.size.height
        addSubview(pieceLabel)
    }
    
    private func initAspect(){
        self.layer.cornerRadius = 6
    }
    
    func initialize(){
        initImage()
        initLabel()
        initAspect()
    }
    
    required init?(coder aDecoder: NSCoder) {
        imageDisplayer = UIImageView()
        image = UIImage()
        pieceLabel = UILabel()
        super.init(coder: aDecoder)
        initialize()
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
