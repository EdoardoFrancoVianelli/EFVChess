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

@IBDesignable

class UIBoard : UIView, ChessBoardDelegate, UIChessPieceProtocol{
    
    internal func pieceRemoved(piece: ChessPiece) {
        pieces["\(piece.x)\(piece.y)"]?.removeFromSuperview()
        pieces.removeValue(forKey: "\(piece.x)\(piece.y)")
    }
    
    var game : Game = Game(p1: Player(name:"", id:1), p2: Player(name: "", id: 2))
    
    private var pieces = Dictionary<String, UIChessPiece>()
    
    private var tiles = [Tile]()
    private var selectedPiece : ChessPiece?{
        didSet{
            if let piece = selectedPiece{
                self.game.pieceSelected(piece: piece)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    func startGame(){
        game.startGame()
    }
    
    override var bounds: CGRect{
        didSet{
            self.tiles = [Tile]()
            self.drawLines()
            for view in self.subviews{
                if let piece = view as? UIChessPiece{
                    piece.frame.origin = CGPoint(x: xPoint(x: piece.x), y: yPoint(y: piece.y))
                    piece.frame.size = CGSize(width: bounds.size.width / 8, height: bounds.size.height / 8)
                }
            }
        }
    }
    
    private func initTapGesture(){
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.addGestureRecognizer(tapGesture)
    }
    
    internal func handleTap(tap : UITapGestureRecognizer){
        if let selected = self.selectedPiece{
            let tapLocation = tap.location(in: self)
            //convert screen x and y to coordinate x and y
            let new_x = Int(tapLocation.x / (self.frame.size.width / 8))
            let new_y = Int(tapLocation.y / (self.frame.size.height / 8))
            DispatchQueue.main.async {
                self.game.changePiecePosition(piece: selected, newPosition: (new_x, new_y))
            }
        }
    }
    
    //board is 8x8
    
    func initialize(){
        self.game.boardDelegate = self
        self.drawLines()
        self.initTapGesture()
        self.game.startGame()
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
    
    private func drawLines(){
        self.tiles = [Tile]()
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
        self.setNeedsDisplay()
    }
    
    private func drawTile(tile : Tile, color : UIColor){
        tile.color = color
        color.set()
        tile.fill()
    }
    
    override func draw(_ rect: CGRect) {
        //(210,105,30)
        let darkBrown = UIColor(red: 139/255, green: 69/255, blue: 19/255, alpha: 1.0)
        let lightBrown = UIColor(red: 210/255, green: 105/255, blue: 30/255, alpha: 1.0)
        
        var prevs = [UIColor]()
        
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
    }
    
    /*CHESS BOARD PROTOCOL*/
    
    func pieceAdded(piece: ChessPiece) {
        let new_piece = UIChessPiece(frame: CGRect(x: xPoint(x: piece.x),
                                                   y: yPoint(y: piece.y),
                                                   width:frame.size.width / 8,
                                                   height:frame.size.height / 8),
                                     piece: piece)

        if piece.y < 2{
            new_piece.setPieceWhite()
        }
        
        new_piece.delegate = self
        
        if pieces["\(piece.x)\(piece.y)"] == nil{
            pieces["\(piece.x)\(piece.y)"] = new_piece
            self.addSubview(new_piece)
        }
    }
    
    var audioPlayer : AVAudioPlayer?
    
    func playTap(){
        do{
            try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)
            if let path = Bundle.main.path(forResource: "keyboard_tap", ofType: "mp3"){
                let alertSound = URL(fileURLWithPath: path)
                audioPlayer = try AVAudioPlayer(contentsOf: alertSound)
                audioPlayer?.prepareToPlay()
                audioPlayer?.play()
            }else{
                print("Cannot find audio file")
            }
        }catch let error as NSError{
            print(error)
            print("Could not play sound")
        }
    }

    func pieceDidChangePosition(piece: ChessPiece, oldPosition: (x: Int, y: Int)) {
        let new_frame = CGRect(x: xPoint(x: piece.x), y: yPoint(y: piece.y), width:frame.size.width / 8, height:frame.size.height / 8)
        if let existingPiece = pieces["\(oldPosition.x)\(oldPosition.y)"]{
            
            playTap()
            
            UIView.animate(withDuration: 0.5, animations: {
                existingPiece.frame = new_frame
            })
            existingPiece.Selected = false
            pieces["\(piece.x)\(piece.y)"] = existingPiece
        }else{
            print("Cannot find piece")
        }
        pieces.removeValue(forKey: "\(oldPosition.x)\(oldPosition.y)")
    }
    
    /*UIChessPieceProtocol*/
    
    internal func pieceSelected(piece: ChessPiece) {
        if let selected = self.selectedPiece{
            if !self.game.consumePiece(piece1: selected, piece2: piece){
                self.selectedPiece = piece
            }else{
                self.selectedPiece = nil
            }
        }else{
            self.selectedPiece = piece
        }
    }
}

























