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
*/




