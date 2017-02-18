//
//  ChessBoard.swift
//  Chess
//
//  Created by Edoardo Franco Vianelli on 1/30/17.
//  Copyright © 2017 Edoardo Franco Vianelli. All rights reserved.
//

import Foundation

protocol ChessBoardProtocol {
    func pieceDidChangePosition(piece : ChessPiece, oldPosition : (x : Int, y : Int))
    func pieceAdded(piece : ChessPiece)
    func pieceRemoved(piece : ChessPiece)
}

class ChessBoard : ChessPieceProtocol {
    
    private var board = Dictionary<String, ChessPiece>()
    var delegate : ChessBoardProtocol?
    
    init(player1Name : String, player2Name : String){
        self.board = Dictionary<String, ChessPiece>()
    }
    
    private func pieceCanEat(piece : ChessPiece, other : ChessPiece) -> Bool{
        
        if piece.player == other.player{
            return false
        }
        
        let allowed  = changeAllowed(piece: piece, newPosition: other.origin, inclusive: false)
        let can_move = movementPossible(piece: piece, newPosition: other.origin)
        if !allowed && can_move && piece is Pawn{
            return true
        }
        return allowed && can_move
    }
    
    private func pieceVulnerable(piece : ChessPiece) -> Bool{
        
        //check left and right
        
        print(piece)
        
        print("Left and Right")
        
        for i in 0..<8{
            if i == piece.x{
                continue
            }
            print("\(i),\(piece.y)")
            if let currentPiece = self.board["\(i)\(piece.y)"]{
                
                //check if the current piece can consume the other piece
                
                let diff = abs(i - piece.x)
                
                print("Found \(currentPiece)")
                
                if ((diff > 1) && (piece is Rook) || (piece is Queen)) || (diff == 1 && piece is King){
                    return true
                }
                
                break;
            }
        }
        
        //check up and down
        
        print("Up and Down")
        
        for i in 0..<8{
            if i == piece.y{
                continue
            }
            print("\(piece.x),\(i)")
            if let currentPiece = self.board["\(piece.x)\(i)"]{
                
                print("Found \(currentPiece)")
                
                let diff = abs(i - piece.y)
                
                if ((diff > 1) && (piece is Rook) || (piece is Queen)) || (diff == 1 && piece is King){
                    return true
                }
                
                break;
            }
        }
        
        //check diagonals
        
        let diagonal_descr = ["Lower right", "Upper left", "Upper right", "Lower left"]
        let increments : [(x : Int, y : Int)] = [(1,1), (-1, -1), (1,-1), (-1, 1)]
        
        for (i, increment) in increments.enumerated(){
            var current : (x : Int, y : Int) = (piece.origin.x + increment.x, piece.origin.y + increment.y)
            print(diagonal_descr[i])
            while current.x >= 0 && current.x < 8 && current.y >= 0 && current.y < 8{
                if let currentPiece = self.board["\(current.x)\(current.y)"]{
                    
                    print("Found \(currentPiece)")
                    
                    let y_diff = currentPiece.y - piece.y //if y is greater than 0, is is below, otherwise it is abow
                    let diff = abs(current.x - piece.x)
                    
                    if ((diff > 1) && (piece is Bishop) || (piece is Queen)) || (diff == 1 && (piece is King || piece is Pawn)){
                        
                        if (piece is Pawn){
                            if y_diff > 0 && currentPiece.player.id == 1{
                                break
                            }else if y_diff < 0 && currentPiece.player.id == 2{
                                break
                            }
                        }
                        
                        return true
                    }
                    
                    break;
                }
                print("(\(current.x), \(current.y))")
                current.x += increment.x
                current.y += increment.y
            }
        }
        
        return false
    }
    
    func consumePiece(piece1 : ChessPiece, piece2 : ChessPiece) -> Bool{
        
        if pieceCanEat(piece: piece1, other: piece2){
            removePiece(piece: piece2)
            piece1.origin = (piece2.x, piece2.y)
            return true
        }else {
            print("\(piece1) cannot eat \(piece2)")
        }
        
        return false
    }
    
    private func CheckBetween(startLocation : (x : Int, y : Int),
                                            endLocation : (x : Int, y : Int),
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
    
    private func movementPossible(piece : ChessPiece, newPosition : (x : Int, y : Int)) -> Bool{
        let diagonal = abs(newPosition.x - piece.x) == abs(newPosition.y - piece.y)
        let vertical = piece.x - newPosition.x == 0 && newPosition.y != piece.y
        let sideways = piece.y - newPosition.y == 0 && newPosition.x != piece.x
        if (piece is Rook){
            return sideways || vertical
        }else if (piece is Pawn){
            return abs(newPosition.x - piece.x) == 1 && abs(newPosition.y - piece.y) == 1
        }else if (piece is King || piece is Queen){
            return diagonal || vertical || sideways
        }else if (piece is Bishop){
            return diagonal
        }else if (piece is Knight){
            var allowed = false
            if abs(piece.x - newPosition.x) == 2{
                if abs(piece.y - newPosition.y) == 1{
                    allowed = piece is Knight
                }
            }else if abs(piece.y - newPosition.y) == 2{
                if abs(piece.x - newPosition.x) == 1{
                    allowed = piece is Knight
                }
            }
            return allowed
        }
        return false
    }
    
    private func diagonalMovement(_ oldPosition : (x : Int, y : Int), _ newPosition : (x : Int, y : Int)) -> Bool{
        return abs(newPosition.x - oldPosition.x) == abs(newPosition.y - oldPosition.y)
    }
    
    private func verticalMovement(_ oldPosition : (x : Int, y : Int), _ newPosition : (x : Int, y : Int)) -> Bool{
        return oldPosition.x - newPosition.x == 0 && newPosition.y != oldPosition.y
    }
    
    private func sidewaysMovement(_ oldPosition : (x : Int, y : Int), _ newPosition : (x : Int, y : Int)) -> Bool{
        return oldPosition.y - newPosition.y == 0 && newPosition.x != oldPosition.x
    }
    
    private func changeAllowed(piece : ChessPiece, newPosition : (x : Int, y : Int), inclusive : Bool) -> Bool{
        
        //check based on the allowable movements
        
        var x_inc = (newPosition.x - piece.x) > 0 ? 1 : -1
        var y_inc = (newPosition.y - piece.y) > 0 ? 1 : -1
        
        if (newPosition.x - piece.x) == 0{
            x_inc = 0
        }else if (newPosition.y - piece.y) == 0{
            y_inc = 0
        }
        
        let diagonal = diagonalMovement(piece.origin, newPosition)
        let vertical = verticalMovement(piece.origin, newPosition)
        let sideways = sidewaysMovement(piece.origin, newPosition)
        
        let end = !inclusive ? newPosition : (newPosition.x + x_inc, newPosition.y + y_inc)
        
        let interference = CheckBetween(startLocation: (piece.x, piece.y), endLocation: end, increments: (x_inc, y_inc))
        var allowed = false
        
        if diagonal && !(piece is Knight){ //diagonal
            allowed = piece.allowedMovement.canMoveDirectlyDiagonally && !interference
            if piece is King{
                allowed = allowed && abs(newPosition.x - piece.x) == 1
            }
        }else if vertical{ //going straight up or down
            let diff = piece.y - newPosition.y
            if (piece is Pawn){
                let movement_allowed = (piece.allowedMovement.canMoveDirectlyForward && abs(diff) <= piece.allowedMovement.forward && !interference)
                return movement_allowed
            }else{
                if diff < 0{ //going backwards
                    allowed = piece.allowedMovement.canMoveDirectlyBackwards && abs(diff) <= piece.allowedMovement.backwards && !interference
                }
                else{
                    allowed = piece.allowedMovement.canMoveDirectlyForward   && abs(diff) <= piece.allowedMovement.forward   && !interference
                }
            }
        }else if sideways { //going straight left or right
        
            let diff = piece.x - newPosition.x
            
            if diff < 0{ //going left
                allowed = piece.allowedMovement.canMoveDirectlyLeft && abs(diff) <= piece.allowedMovement.left && !interference
            }else{ //going right
                allowed = piece.allowedMovement.canMoveDirectlyRight && abs(diff) <= piece.allowedMovement.right && !interference
            }
        }else { //knight movement
            if abs(piece.x - newPosition.x) == 2{
                if abs(piece.y - newPosition.y) == 1{
                    allowed = piece is Knight
                }
            }else if abs(piece.y - newPosition.y) == 2{
                if abs(piece.x - newPosition.x) == 1{
                    allowed = piece is Knight
                }
            }
            if let currentPiece = board["\(newPosition.x)\(newPosition.y)"]{
                if currentPiece.player != piece.player{
                    allowed = allowed && true
                }
            }else{
                allowed = allowed && true
            }
        }
        
        return allowed
    }
    
    func canChangePiecePosition(piece : ChessPiece, newPosition : (x : Int, y : Int)) -> Bool{
        
        //verify legitimacy of position change
        
        if !changeAllowed(piece: piece, newPosition: newPosition, inclusive: true){
            print("Cannot move \(piece) to \(newPosition)")
            print(self.board.count)
            return false
        }
        
        if piece is Pawn{
            (piece.allowedMovement as? PawnMovement)?.movedTwo = true
        }
        
        return true
    }
    
    func positionDidChange(piece: ChessPiece, oldPosition : (x : Int, y : Int)) {
        
        DispatchQueue.main.async {
            if (self.pieceVulnerable(piece: piece)){
                print("Piece is not safe in this position")
            }else{
                print("Piece is safe in this position")
            }
        }
        
        self.board.removeValue(forKey: "\(oldPosition.x)\(oldPosition.y)")
        self.board["\(piece.x)\(piece.y)"] = piece
        delegate?.pieceDidChangePosition(piece: piece, oldPosition: oldPosition)
    }
    
    func addPiece(piece : ChessPiece){
        self.board["\(piece.x)\(piece.y)"] = piece
        piece.delegate = self
        self.delegate?.pieceAdded(piece: piece)
    }
    
    func removeAllPieces(){
        for element in self.board{
            removePiece(piece: element.value)
        }
        
        self.board = Dictionary<String, ChessPiece>()
    }
    
    func removePiece(piece : ChessPiece){
        self.board.removeValue(forKey: "\(piece.x)\(piece.y)")
        self.delegate?.pieceRemoved(piece: piece)
    }
}














