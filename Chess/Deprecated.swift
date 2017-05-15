//
//  Deprecated.swift
//  Chess
//
//  Created by Edoardo Franco Vianelli on 4/22/17.
//  Copyright © 2017 Edoardo Franco Vianelli. All rights reserved.
//

import Foundation

/*
func canChangePiecePosition(piece : ChessPiece, newPosition : Point) -> Bool{
    
    //verify legitimacy of position change
    
    
     if !changeAllowed(piece: piece, newPosition: newPosition, inclusive: true){
     print("Cannot move \(piece) to \(newPosition)")
     print(self.board.count)
     return false
     }
 
}
 
*/
/*
func pieceCanBeBlockedFromAttackingPiece(attacker : ChessPiece, attacked : ChessPiece) -> ChessPiece?{
    
    let attackLocations = Set(allowedMovementLocations(piece: attacker))
    
    for (_, piece) in self.board{
        if piece.player == attacked.player{
            let pieceLocations = Set(allowedMovementLocations(piece: piece))
            if !attackLocations.intersection(pieceLocations).isEmpty{
                return piece
            }
        }
    }
    
    return nil
    /*
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
     */
}
*/


/*
private func diagonalMovement(_ oldPosition : Point, _ newPosition : Point) -> Bool{
    return abs(newPosition.x - oldPosition.x) == abs(newPosition.y - oldPosition.y)
}

private func verticalMovement(_ oldPosition : Point, _ newPosition : Point) -> Bool{
    return oldPosition.x - newPosition.x == 0 && newPosition.y != oldPosition.y
}

private func sidewaysMovement(_ oldPosition : Point, _ newPosition : Point) -> Bool{
    return oldPosition.y - newPosition.y == 0 && newPosition.x != oldPosition.x
}

private func validKnightMovement(piece : ChessPiece, newPosition : Point) -> Bool{
    return (abs(piece.x - newPosition.x) == 2 && abs(piece.y - newPosition.y) == 1) || (abs(piece.y - newPosition.y) == 2 && abs(piece.x - newPosition.x) == 1)
}

private func changeAllowed(piece : ChessPiece, newPosition : Point, inclusive : Bool) -> Bool{
    
    //check based on the allowable movements
    
    var x_inc = (newPosition.x - piece.x) > 0 ? 1 : -1
    var y_inc = (newPosition.y - piece.y) > 0 ? 1 : -1
    
    if (newPosition.x - piece.x) == 0{
        x_inc = 0
    }else if (newPosition.y - piece.y) == 0{
        y_inc = 0
    }
    
    let end = !inclusive ? newPosition : Point(newPosition.x + x_inc, newPosition.y + y_inc)
    
    let interference = CheckBetween(startLocation: Point(piece.x, piece.y), endLocation: end, increments: (x_inc, y_inc))
    var allowed = false
    
    if diagonalMovement(piece.origin, newPosition) && !(piece is Knight){ //diagonal
        allowed = piece.allowedMovement.canMoveDirectlyDiagonally && !interference
        if piece is King{
            return allowed && abs(newPosition.x - piece.x) == 1
        }
    }else if verticalMovement(piece.origin, newPosition){ //going straight up or down
        let diff = piece.y - newPosition.y
        if (piece is Pawn){
            return (piece.allowedMovement.canMoveDirectlyForward && abs(diff) <= piece.allowedMovement.up && !interference)
        }else{
            if diff < 0{ //going backwards
                return piece.allowedMovement.canMoveDirectlyBackwards && abs(diff) <= piece.allowedMovement.down && !interference
            }
            else{
                return piece.allowedMovement.canMoveDirectlyForward   && abs(diff) <= piece.allowedMovement.up && !interference
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


private func pieceVulnerable(piece : ChessPiece) -> ChessPiece? {
    
     let left_r_up_d = ["Left", "Right", "Up", "Down"]
     let lr_ud_increments  : [(x : Int, y : Int)] = [(-1, 0), (1,0), (0, -1), (0, 1)]
     
     //check left and right
     
     var attacker : ChessPiece?
     
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
     if let currentPiece = self.board.pieces["\(x)\(y)"]{
     
     //check if the current piece can consume the other piece
     
     let x_diff = abs(piece.x - currentPiece.x)
     let y_diff = abs(piece.y - currentPiece.y)
     
     if piece.player == currentPiece.player{
     break
     }
     
     if (currentPiece is Queen || currentPiece is Rook) && ((x_diff == 0 && y_diff > 0) || (y_diff == 0 && x_diff > 0)){
     attacker = currentPiece
     }else if currentPiece is King && (x_diff <= 1 && y_diff <= 1){
     attacker = currentPiece
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
     if let currentPiece = self.board.pieces["\(current.x)\(current.y)"]{
     
     let y_diff = currentPiece.y - piece.y //if y is greater than 0, is is below, otherwise it is abow
     let diff = abs(current.x - piece.x)
     
     if (currentPiece is Bishop || currentPiece is Queen) || currentPiece is Pawn && diff == 1 && y_diff == 1{
     if currentPiece.player == piece.player{
     break
     }
     attacker = currentPiece
     }
     
     break;
     }
     print("(\(current.x), \(current.y))")
     current.x += increment.x
     current.y += increment.y
     }
     }
     
     return attacker
}

*/




