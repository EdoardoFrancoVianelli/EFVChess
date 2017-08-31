//
//  ChessBoard.swift
//  Chess
//
//  Created by Edoardo Franco Vianelli on 1/30/17.
//  Copyright © 2017 Edoardo Franco Vianelli. All rights reserved.
//

import Foundation

protocol ChessBoardDelegate {
    func pieceDidChangePosition(piece : ChessPiece, oldPosition : Point)
    func pieceAdded(piece : ChessPiece)
    func pieceRemoved(piece : ChessPiece)
}

class Point : Hashable, Equatable, CustomStringConvertible{
    var x = 0
    var y = 0
    
    init(_ x : Int, _ y : Int){
        self.x = x
        self.y = y
    }
    
    public var hashValue: Int {
        return x * 10 + y * 100
    }
    
    public static func ==(lhs: Point, rhs: Point) -> Bool
    {
        return (lhs.x, lhs.y) == (rhs.x, rhs.y)
    }
    
    public var description: String {
        get {
            return "(\(x),(\(y))"
        }
    }
}

class ChessBoard : ChessPieceDelegate {
    
    private var board : Dictionary<String, ChessPiece>

    var pieces : Dictionary<String, ChessPiece>{
        get{
            return self.board
        }
    }
    
    var delegate : ChessBoardDelegate?
    
    init(player1Name : String, player2Name : String){
        self.board = Dictionary<String, ChessPiece>()
    }
        
    func positionDidChange(piece: ChessPiece, oldPosition : Point) {
        self.board.removeValue(forKey: "\(oldPosition.x)\(oldPosition.y)")
        self.board["\(piece.x)\(piece.y)"] = piece
        delegate?.pieceDidChangePosition(piece: piece, oldPosition: oldPosition)
    }
    
    func addPiece(piece : ChessPiece){
        self.board["\(piece.x)\(piece.y)"] = piece
        piece.delegate = self
        self.delegate?.pieceAdded(piece: piece)
    }
    
    func removePiece(piece : ChessPiece){
        if self.board.removeValue(forKey: "\(piece.x)\(piece.y)") == nil{
            print("hello")
        }
        self.delegate?.pieceRemoved(piece: piece)
    }
    
    func pieceAt(x : Int, y : Int) -> ChessPiece?{
        return self.board["\(x)\(y)"]
    }
    
    func hasPieceAtPoint(x : Int, y : Int) -> Bool{
        return self.pieceAt(x: x, y: y) != nil
    }
    
    func hasPieceAtPoint(point : Point) -> Bool{
        return self.hasPieceAtPoint(x: point.x, y: point.y)
    }
}


/*
 
 
 
 private func CheckBetween(startLocation : Point,
 endLocation : Point,
 increments : (x : Int, y : Int)) -> Bool{
 
 var i = startLocation.x + increments.x
 var j = startLocation.y + increments.y
 
 while abs(i) != abs(endLocation.x) || abs(j) != abs(endLocation.y){
 
 if let _ = board["\(i)\(j)"]{
 return true
 }
 
 if i <= 0 || i >= 8 || j <= 0 || j >= 8{
 return false
 }
 
 i += increments.x
 j += increments.y
 }
 
 return false
 }
 
 */













