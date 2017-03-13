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
    
    func initializeButtons(){
        let buttonWidth = self.frame.size.width / 2
        let buttonHeight = self.frame.size.height
        cancelButton = UIButton(frame: CGRect(x: 0, y: 0, width: buttonWidth, height: buttonHeight))
        confirmButton = UIButton(frame: CGRect(x: buttonWidth, y: 0, width: buttonWidth, height: buttonHeight))
        
        cancelButton?.titleLabel?.adjustsFontSizeToFitWidth = true
        confirmButton?.titleLabel?.adjustsFontSizeToFitWidth = true
        
        cancelButton?.isUserInteractionEnabled = true
        confirmButton?.isUserInteractionEnabled = true
        
        cancelButton?.setTitleColor(UIColor.black, for: .normal)
        cancelButton?.setTitleColor(UIColor.white, for: .highlighted)
        
        confirmButton?.setTitleColor(UIColor.black, for: .normal)
        confirmButton?.setTitleColor(UIColor.white, for: .highlighted)
        
        cancelButton?.setTitle("Cancel", for: .normal)
        confirmButton?.setTitle("Confirm", for: .normal)
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
    
    var piece : ChessPiece = Pawn(x: 0, y: 0, movement: PawnMovement(), player: Player(name: "", id: 0)){
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
    
    var conf_action : (() -> ())?
    var undo_action : (() -> ())?
    
    func addCancelAction(action : @escaping () -> ()){
        self.undo_action = action
        self.cancelButton!.addTarget(self, action: #selector(undo(button:)), for: .touchUpInside)
    }
    
    func addConfirmAction(action : @escaping () -> ()){
        self.conf_action = action
        self.confirmButton!.addTarget(self, action: #selector(confirm(button:)), for: .touchUpInside)
    }
    
    func undo(button : UIButton){
        self.showMoveApprovalView = false
        self.undo_action?()
    }
    
    func confirm(button : UIButton){
        self.showMoveApprovalView = false
        self.conf_action?()
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
