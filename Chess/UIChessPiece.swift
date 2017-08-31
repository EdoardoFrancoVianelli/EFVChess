//
//  UIChessPiece.swift
//  Chess
//
//  Created by Edoardo Franco Vianelli on 1/30/17.
//  Copyright © 2017 Edoardo Franco Vianelli. All rights reserved.
//

import Foundation
import UIKit

var pieceImages = ["Pawn" : UIImage(named: "chess-pawn.png"), "Bishop" : UIImage(named: "bishop.png"), "King" : UIImage(named: "chess-king.png"), "Queen" : UIImage(named: "chess-queen.png"), "Rook" : UIImage(named: "chess-rok.png"), "Knight" : UIImage(named: "chess-knight.png")]

protocol UIChessPieceDelegate {
    func pieceSelected(piece : ChessPiece)
    func piecePanned(piece : UIChessPiece, location : CGPoint)
    func pieceDropped(piece : UIChessPiece)
}

enum ChessPieceError: Error {
    case NullDelegate
}

@IBDesignable
class UIChessPiece : UIView{
    
    private var dragGesture = UIPanGestureRecognizer()
    
    private var image = UIImageView()
    
    var Piece : ChessPiece{
        return self.piece
    }
    
    var Image : UIImage?{
        return self.image.image
    }
    
    var delegate : UIChessPieceDelegate?
    private var piece : ChessPiece
    private var nameLabel : UILabel
    private var selected : Bool
    
    var x : Int { return piece.x }
    var y : Int { return piece.y }
    
    override var frame: CGRect{
        didSet{
            self.updateImageFrame()
        }
    }
    
    var nameColor : UIColor{
        get{
            return self.nameLabel.textColor
        }set{
            self.nameLabel.textColor = newValue
        }
    }
    
    internal func pieceTapped() throws {
        if delegate == nil{
            throw ChessPieceError.NullDelegate
        }
        delegate?.pieceSelected(piece: self.piece)
    }

    private func initGesture(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.pieceTapped))
        self.addGestureRecognizer(tap)
    }
    
    func activateGlow(){
        self.nameLabel.shadowColor = self.nameLabel.textColor
        self.nameLabel.layer.shadowRadius = 4.0
        self.nameLabel.layer.shadowOpacity = 0.9
        self.nameLabel.layer.shadowOffset = CGSize.zero
        self.nameLabel.layer.masksToBounds = false
    }
    
    func deactivateGlow(){
        self.nameLabel.shadowColor = nil
        self.nameLabel.layer.shadowRadius = 0.0
        self.nameLabel.layer.shadowOpacity = 0.0
        self.nameLabel.layer.shadowOffset = CGSize.zero
        self.nameLabel.layer.masksToBounds = true
    }
    
    init(frame : CGRect, piece : ChessPiece){
        self.piece = piece
        self.nameLabel = UILabel()
        self.selected = false
        super.init(frame: frame)
        self.initAspect()
        self.initGesture()
        self.dragGesture = UIPanGestureRecognizer(target: self, action: #selector(panning(_:)))
        self.addGestureRecognizer(self.dragGesture)
    }
    
    func clearImage(){
        self.image.image = nil
    }
    
    private func updateImageFrame(){
        self.image.frame = CGRect(origin: CGPoint(x: self.bounds.size.width / 8, y: self.bounds.size.height / 8),
                                  size: CGSize(width: self.bounds.size.width * 6/8, height: self.bounds.size.height * 6/8))
    }
    
    private func initAspect(){
        self.updateImageFrame()
        self.image.contentMode = .scaleAspectFit
        self.image.image = pieceImages[piece.name]!!
        self.addSubview(image)
    }
    
    func setPieceWhite(){
        self.image.image = self.image.image?.withRenderingMode(.alwaysTemplate)
        self.image.tintColor = UIColor.white
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.piece = ChessPiece(origin: Point(0,0), movement: PawnMovement(), player: Player(name: "", id: 1))
        self.nameLabel = UILabel()
        self.selected = false
        super.init(coder: aDecoder)
        self.initAspect()
    }

    func panning(_ gesture : UIPanGestureRecognizer){
        do {
            try self.pieceTapped()
        }
        catch{
        
        }
        if gesture.state != .ended{
            delegate?.piecePanned(piece: self, location: gesture.location(in: self.superview))
        }else {
            delegate?.pieceDropped(piece: self)
        }
    }
}









