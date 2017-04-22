//
//  ChessStatusBox.swift
//  Chess
//
//  Created by Edoardo Franco Vianelli on 2/15/17.
//  Copyright © 2017 Edoardo Franco Vianelli. All rights reserved.
//

import UIKit

protocol StatusBoxDelegate {
    func confirmActionFired()
    func cancelActionFired()
}

@IBDesignable
class ChessStatusBox: UIView {
    
    var delegate : StatusBoxDelegate?
    
    @IBInspectable
    var white : Bool = false{
        didSet{
            if white {
                setWhite()
            }
        }
    }
    
    private var imageDisplayer : UIImageView
    private var pieceLabel : UILabel
    var confirmButton : UIButton?
    var cancelButton : UIButton?
    
    func initButton(title : String, x : CGFloat) -> UIButton{
        let buttonWidth = self.frame.size.width / 2
        let buttonHeight = self.frame.size.height
        let button = UIButton(frame: CGRect(x: x, y: 0, width: buttonWidth, height: buttonHeight))
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.isUserInteractionEnabled = true
        button.setTitleColor(UIColor.black, for: .normal)
        button.setTitleColor(UIColor.white, for: .highlighted)
        button.setTitle(title, for: .normal)
        return button
    }
    
    func initializeButtons(){
        cancelButton = initButton(title: "Cancel", x: 0)
        cancelButton?.addTarget(self, action: #selector(undo(button:)), for: .touchUpInside)
        confirmButton = initButton(title: "Confirm", x: self.frame.size.width / 2)
        confirmButton?.addTarget(self, action: #selector(confirm(button:)), for: .touchUpInside)
    }
    
    var showMoveApprovalView : Bool = false{
        didSet{
            if showMoveApprovalView{
                self.imageDisplayer.removeFromSuperview()
                self.pieceLabel.removeFromSuperview()
                self.addSubview(self.cancelButton!)
                self.addSubview(self.confirmButton!)
            }else{
                self.cancelButton?.removeFromSuperview()
                self.confirmButton?.removeFromSuperview()
                self.addSubview(self.imageDisplayer)
                self.addSubview(self.pieceLabel)
            }
        }
    }
    
    func resetSeconds(){
        self.secondsPassed = 0
    }
    
    var secondsPassed = 0{
        didSet{
            updateTitle()
        }
    }
    
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
    
    var glow : Bool = false{
        didSet{
            self.SetGlow(glow: glow)
        }
    }
    
    func SetGlow(glow : Bool){
        //https://www.hackingwithswift.com/example-code/uikit/how-to-add-a-shadow-to-a-uiview for the glow code
        self.layer.shadowColor = UIColor.white.cgColor
        self.layer.shadowOffset = CGSize.zero
        if glow {
            self.layer.shadowOpacity = 1
            self.layer.shadowRadius = 10
        }else{
            self.layer.shadowOpacity = 0
            self.layer.shadowRadius = 0
        }
    }
    
    var image : UIImage{
        didSet{
            imageDisplayer.image = image
        }
    }
    
    var piece : ChessPiece = Pawn(origin: Point(0,0), movement: PawnMovement(), player: Player(name: "", id: 0)){
        didSet{
            updateTitle()
        }
    }
    
    private func updateTitle(){
        self.title = self.piece.name + "\n" + self.timeText()
    }
    
    var title : String?{
        get{
            return pieceLabel.text
        }set{
            pieceLabel.text = newValue
        }
    }

    func setWhite(){
        self.image = self.image.withRenderingMode(.alwaysTemplate)
        self.imageDisplayer.tintColor = UIColor.white
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
        pieceLabel.text = "Pawn" + "\n" + "00:00"
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
        self.backgroundColor = UIColor.lightGray
    }
    
    private func timeText() -> String{
        let formatter = NumberFormatter()
        formatter.minimumIntegerDigits = 2
        if let minutes = formatter.string(from: NSNumber(value: secondsPassed / 60)){
            if let seconds = formatter.string(from: NSNumber(value: secondsPassed % 60)){
                return "\(minutes):\(seconds)"
            }
        }
        return ""
    }
    
    func initialize(){
        initImage()
        initLabel()
        initAspect()
        initializeButtons()
    }
    
    required init?(coder aDecoder: NSCoder) {
        imageDisplayer = UIImageView()
        image = UIImage()
        pieceLabel = UILabel()
        super.init(coder: aDecoder)
        initialize()
    }
    
    func undo(button : UIButton){
        self.showMoveApprovalView = false
        self.delegate?.cancelActionFired()
    }
    
    func confirm(button : UIButton){
        self.showMoveApprovalView = false
        self.delegate?.confirmActionFired()
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
