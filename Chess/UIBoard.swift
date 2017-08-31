//
//  UIBoard.swift
//  Chess
//
//  Created by Edoardo Franco Vianelli on 1/30/17.
//  Copyright © 2017 Edoardo Franco Vianelli. All rights reserved.
//

import AVFoundation
import Foundation
import UIKit

class Tile : UIBezierPath{
    
    var color : UIColor = UIColor.black
    
    
}

protocol BoardDelegate{
    func pieceTapped(piece : ChessPiece) -> [Point]
    func moveRequested(newLocation : (x : Float, y : Float)) -> Bool
}

@IBDesignable

class UIBoard : UIView, ChessBoardDelegate, UIChessPieceDelegate{

    var allowedLocations = [Point]()
    var tiles = [Tile]()
    var delegate : BoardDelegate?
    var originalPiecePosition : CGPoint?
    
    func imageForPiece(piece : ChessPiece) -> UIImage?{
        return pieces["\(piece.origin.x)\(piece.origin.y)"]?.Image
    }
    
    internal func pieceRemoved(piece: ChessPiece) {

        if let removed = pieces["\(piece.x)\(piece.y)"]{
            removed.clearImage()
            removed.removeFromSuperview()
            pieces.removeValue(forKey: "\(piece.x)\(piece.y)")
        }
    }
    
    private var pieces = Dictionary<String, UIChessPiece>()

    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    private var angle : CGFloat = 0.0
    
    func rotate(){
        angle = angle == 0.0 ? CGFloat(Double.pi) : 0.0
        UIView.animate(withDuration: 1, animations: {
            self.transform = CGAffineTransform.init(rotationAngle: self.angle)
            for view in self.subviews{
                view.transform = CGAffineTransform.init(rotationAngle: self.angle)
            }
        })
    }

    override var bounds: CGRect{
        didSet{
            //self.tiles = [Tile]()
            self.setNeedsDisplay()
            for view in self.subviews{
                if let piece = view as? UIChessPiece{
                    piece.frame.origin = CGPoint(x: xPoint(x: piece.x), y: yPoint(y: piece.y))
                    piece.frame.size = CGSize(width: bounds.size.width / 8, height: bounds.size.height / 8)
                }
            }
        }
    }
    
    //board is 8x8
    
    func initialize(){
        //self.game.boardDelegate = self
        self.setNeedsDisplay()
        initMoveTapGesture()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    private func xPoint(x : Int) -> CGFloat{
        let width = self.frame.size.width / 8
        return CGFloat(x) * width
    }
    
    private func yPoint(y : Int) -> CGFloat{
        let height = self.frame.size.height / 8
        return CGFloat(y) * height
    }
    
    private func drawTile(tile : Tile, color : UIColor){
        tile.color = color
        color.set()
        tile.fill()
    }
    
    func getTiles() -> [Tile]
    {
        tiles = [Tile]()
        for i in 0..<64{
            let x = Int(i / 8)
            let y = i % 8
            let tile = Tile()
            tile.move(to: CGPoint(x: xPoint(x: x), y: yPoint(y: y)))
            tile.addLine(to: CGPoint(x: xPoint(x: x+1), y: yPoint(y: y)))
            tile.addLine(to: CGPoint(x: xPoint(x: x+1), y: yPoint(y: y+1)))
            tile.addLine(to: CGPoint(x: xPoint(x: x), y: yPoint(y: y+1)))
            tile.close()
            tiles.append(tile)
        }
        return tiles
    }
    
    override func draw(_ rect: CGRect) {
        //(210,105,30)
        let darkBrown = UIColor(red: 139/255, green: 69/255, blue: 19/255, alpha: 1.0)
        let lightBrown = UIColor(red: 210/255, green: 105/255, blue: 30/255, alpha: 1.0)
        
        var prevs = [UIColor]()
        
        if tiles.isEmpty{
            tiles = getTiles()
        }
    
        for i in 0..<tiles.count{

            let tile = tiles[i]
            
            if prevs.count < 8{
                if i % 2 == 0{
                    drawTile(tile: tile, color: darkBrown)
                    prevs.append(darkBrown)
                }else{
                    drawTile(tile: tile, color: lightBrown)
                    prevs.append(lightBrown)
                }
            }else{
                if prevs[i % 8] == darkBrown{
                    drawTile(tile: tile, color: lightBrown)
                    prevs[i % 8] = lightBrown
                }else{
                    drawTile(tile: tile, color: darkBrown)
                    prevs[i % 8] = darkBrown
                }
            }
        }
        
        UIColor.yellow.setFill()
        for location in allowedLocations{
            let currentPath = UIBezierPath()
            currentPath.move(to: CGPoint(x: xPoint(x: location.x), y: yPoint(y: location.y)))
            currentPath.addLine(to: CGPoint(x: xPoint(x: location.x+1), y: yPoint(y: location.y)))
            currentPath.addLine(to: CGPoint(x: xPoint(x: location.x+1), y: yPoint(y: location.y+1)))
            currentPath.addLine(to: CGPoint(x: xPoint(x: location.x), y: yPoint(y: location.y+1)))
            currentPath.close()
            currentPath.fill()
            currentPath.stroke()
        }
    }
    
    /*CHESS BOARD PROTOCOL*/
    
    func pieceAdded(piece: ChessPiece) {
        let new_piece = UIChessPiece(frame: CGRect(x: xPoint(x: piece.x),
                                                   y: yPoint(y: piece.y),
                                                   width:frame.size.width / 8,
                                                   height:frame.size.height / 8),
                                     piece: piece)

        if piece.player.id == 1{
            new_piece.setPieceWhite()
        }
        
        new_piece.delegate = self
        
        if pieces["\(piece.x)\(piece.y)"] == nil{
            pieces["\(piece.x)\(piece.y)"] = new_piece
            self.addSubview(new_piece)
        }
    }

    private func initMoveTapGesture(){
        let moveTap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.addGestureRecognizer(moveTap)
    }
    
    /*
     Allow for the user to slightly tap outside and still get the move through, if it is within 10% of a square distance from
     another box, try that other box too
     */
    
    func screenToPointCoordinates(x : CGFloat, y : CGFloat) -> (x : CGFloat, y : CGFloat){
        let new_x = (x / (self.frame.size.width / 8))
        let new_y = (y / (self.frame.size.height / 8))
        return (new_x, new_y)
    }
    
    internal func handleTap(tap : UITapGestureRecognizer){
        let tapLocation = tap.location(in: self)
        //convert screen x and y to coordinate x and y
        let (new_x, new_y) = screenToPointCoordinates(x: tapLocation.x, y: tapLocation.y)
        let _ = delegate?.moveRequested(newLocation: (Float(new_x), Float(new_y)))
    }
    
    func pieceDidChangePosition(piece: ChessPiece, oldPosition: Point) {
        let new_point = CGPoint(x: xPoint(x: piece.x), y: yPoint(y: piece.y))
        if let existingPiece = pieces["\(oldPosition.x)\(oldPosition.y)"]{
            print(Settings.animations)
            UIView.animate(withDuration: Settings.animations ? 0.5 : 0.0, animations: {
                existingPiece.frame.origin = new_point
            })
            pieces["\(piece.x)\(piece.y)"] = existingPiece
        }else{
            print("Cannot find piece")
        }
        pieces.removeValue(forKey: "\(oldPosition.x)\(oldPosition.y)")
        self.allowedLocations = [Point]()
        self.setNeedsDisplay()
        
        //UIImageWriteToSavedPhotosAlbum(self.snapshot()!, nil, nil, nil)
        self.originalPiecePosition = nil
    }
    
    internal func pieceSelected(piece: ChessPiece) {
        if let locations = delegate?.pieceTapped(piece: piece){
            if Settings.allowedMoves{
                self.allowedLocations = locations
                self.setNeedsDisplay()
            }
        }
    }
    
    func piecePanned(piece : UIChessPiece, location: CGPoint) {
        if let positions = delegate?.pieceTapped(piece: piece.Piece){
            if positions.isEmpty{
                return
            }
        }
        
        if originalPiecePosition == nil{
            originalPiecePosition = piece.frame.origin
        }
        
        piece.frame.origin = CGPoint(x: location.x - piece.frame.size.width / 2, y: location.y - piece.frame.size.height / 2)
    }
    
    func pieceDropped(piece: UIChessPiece) {
        let currentLocation = piece.frame.origin
        let screenPoint = screenToPointCoordinates(x: currentLocation.x, y: currentLocation.y)
        print(screenPoint)
        
        if let moved = delegate?.moveRequested(newLocation: (Float(screenPoint.x), Float(screenPoint.y))){
            if !moved{
                if let originalLocation = originalPiecePosition{
                    UIView.animate(withDuration: Settings.animations ? 0.5 : 0.0, animations: {
                        piece.frame.origin = originalLocation //move back to original position
                    })
                    originalPiecePosition = nil //reset the original location
                }
            }
        }
    }
}

























