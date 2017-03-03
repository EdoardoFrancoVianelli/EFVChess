//
//  ChessBoard.swift
//  Chess
//
//  Created by Edoardo Franco Vianelli on 1/30/17.
//  Copyright © 2017 Edoardo Franco Vianelli. All rights reserved.
//

import Foundation

protocol ChessBoardDelegate {
    func pieceDidChangePosition(piece : ChessPiece, oldPosition : (x : Int, y : Int))
    func pieceAdded(piece : ChessPiece)
    func pieceRemoved(piece : ChessPiece)
}

class ChessBoard : ChessPieceDelegate {
    
    var player1Check : ChessPiece?{
        return pieceVulnerable(piece: player1King)
    }
    
    var player2Check : ChessPiece?{
        return pieceVulnerable(piece: player2King)
    }
    
    
    private var player1King : King
    private var player2King : King
    
    var firstPlayerKing : ChessPiece {
        get{
            return player1King
        }
    }
    
    var secondPlayerKing : ChessPiece{
        get{
            return player2King
        }
    }
    
    private var board : Dictionary<String, ChessPiece>

    var delegate : ChessBoardDelegate?
    
    var pieces : Dictionary<String, ChessPiece> {
        return board
    }
    
    
    init(player1Name : String, player2Name : String){
        self.board = Dictionary<String, ChessPiece>()
        self.player1King = King(x: 0, y: 0, movement: KingMovement(), player: Player(name: "", id: 1))
        self.player2King = King(x: 0, y: 0, movement: KingMovement(), player: Player(name: "", id: 2))
    }
    
    func pieceCanEat(piece : ChessPiece, other : ChessPiece) -> Bool{
        
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
    
    func pieceCanBeBlockedFromAttackingPiece(attacker : ChessPiece, attacked : ChessPiece) -> ChessPiece?{
        
        var x_inc = (attacked.origin.x - attacker.origin.x) > 0 ? 1 : -1
        var y_inc = (attacked.origin.y - attacker.origin.y) > 0 ? 1 : -1
        
        if (attacked.origin.x - attacker.origin.x) == 0{
            x_inc = 0
        }else if (attacked.origin.y - attacker.origin.y) == 0{
            y_inc = 0
        }
        
        var pieces_to_check = [ChessPiece]()
        
        for piece in board{
            if piece.value.player == attacked.player{
                pieces_to_check.append(piece.value)
            }
        }
        
        var i = attacker.origin.x
        var j = attacker.origin.y
        
        while i != attacked.x && j != attacked.y{
            for piece in pieces_to_check{
                if CheckBetween(startLocation: piece.origin, endLocation: attacked.origin, increments: (x_inc, y_inc)){
                    return piece
                }
            }
            i += x_inc
            j += y_inc
        }
        
        return nil
    }
    
    func pieceVulnerable(piece : ChessPiece) -> ChessPiece?{
        
        let left_r_up_d = ["Left", "Right", "Up", "Down"]
        let lr_ud_increments  : [(x : Int, y : Int)] = [(1,0), (0,1)]
        
        //check left and right
        
        print(piece)
        
        for (index,increment) in lr_ud_increments.enumerated(){
            var x = piece.x
            var y = piece.y
            print(left_r_up_d[index])
            for i in 0..<8{
                x += increment.x
                y += increment.y
                if (i == piece.x && index == 0) || (i == piece.y && index == 0){
                    continue
                }
                print("\(x),\(y)")
                if let currentPiece = self.board["\(x)\(y)"]{
                    
                    //check if the current piece can consume the other piece
                    
                    let diff = abs(i - ((index == 0) ? piece.x : piece.y))
                    
                    if ((diff > 1) && (currentPiece is Rook) || (currentPiece is Queen)) || (diff == 1 && currentPiece is King){
                        if currentPiece.player == piece.player{
                            break
                        }
                        return currentPiece
                    }
                    
                    break;
                }
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
                                        
                    let y_diff = currentPiece.y - piece.y //if y is greater than 0, is is below, otherwise it is abow
                    let diff = abs(current.x - piece.x)
                    
                    if (currentPiece is Bishop || currentPiece is Queen) || currentPiece is Pawn && diff == 1 && y_diff == 1{
                        if currentPiece.player == piece.player{
                            break
                        }
                        return currentPiece
                    }
                    
                    break;
                }
                print("(\(current.x), \(current.y))")
                current.x += increment.x
                current.y += increment.y
            }
        }
        
        return nil
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
    
    private func validKnightMovement(piece : ChessPiece, newPosition : (x : Int, y : Int)) -> Bool{
        return (abs(piece.x - newPosition.x) == 2 && abs(piece.y - newPosition.y) == 1) || (abs(piece.y - newPosition.y) == 2 && abs(piece.x - newPosition.x) == 1)
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
        
        let end = !inclusive ? newPosition : (newPosition.x + x_inc, newPosition.y + y_inc)
        
        let interference = CheckBetween(startLocation: (piece.x, piece.y), endLocation: end, increments: (x_inc, y_inc))
        var allowed = false
        
        if diagonalMovement(piece.origin, newPosition) && !(piece is Knight){ //diagonal
            allowed = piece.allowedMovement.canMoveDirectlyDiagonally && !interference
            if piece is King{
                return allowed && abs(newPosition.x - piece.x) == 1
            }
        }else if verticalMovement(piece.origin, newPosition){ //going straight up or down
            let diff = piece.y - newPosition.y
            if (piece is Pawn){
                return (piece.allowedMovement.canMoveDirectlyForward && abs(diff) <= piece.allowedMovement.forward && !interference)
            }else{
                if diff < 0{ //going backwards
                    return piece.allowedMovement.canMoveDirectlyBackwards && abs(diff) <= piece.allowedMovement.backwards && !interference
                }
                else{
                    return piece.allowedMovement.canMoveDirectlyForward   && abs(diff) <= piece.allowedMovement.forward   && !interference
                }
            }
        }else if sidewaysMovement(piece.origin, newPosition) { //going straight left or right
        
            let diff = piece.x - newPosition.x
            
            if diff < 0{ //going left
                return piece.allowedMovement.canMoveDirectlyLeft && abs(diff) <= piece.allowedMovement.left && !interference
            }else{ //going right
                return piece.allowedMovement.canMoveDirectlyRight && abs(diff) <= piece.allowedMovement.right && !interference
            }
        }else if validKnightMovement(piece: piece, newPosition: newPosition){ //knight movement
            return piece is Knight
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
        
        self.board.removeValue(forKey: "\(oldPosition.x)\(oldPosition.y)")
        self.board["\(piece.x)\(piece.y)"] = piece
        delegate?.pieceDidChangePosition(piece: piece, oldPosition: oldPosition)
    }
    
    func addPiece(piece : ChessPiece){
        
        if let king = piece as? King{
            if piece.player.id == 1{
                player1King = king
            }else{
                player2King = king
            }
        }
        
        self.board["\(piece.x)\(piece.y)"] = piece
        piece.delegate = self
        self.delegate?.pieceAdded(piece: piece)
    }
    
    func removePiece(piece : ChessPiece){
        self.board.removeValue(forKey: "\(piece.x)\(piece.y)")
        self.delegate?.pieceRemoved(piece: piece)
    }
}














