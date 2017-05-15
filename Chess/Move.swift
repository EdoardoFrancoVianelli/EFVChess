//
//  Move.swift
//  Chess
//
//  Created by Edoardo Franco Vianelli on 3/12/17.
//  Copyright © 2017 Edoardo Franco Vianelli. All rights reserved.
//

import Foundation

class Move : CustomStringConvertible, Hashable, Equatable{
    var piece : ChessPiece
    var previousLocation : Point
    var consumedPiece : ChessPiece?
    var newLocation : Point
    
    init(piece : ChessPiece, previousLocation : Point, newLocation : Point, consumedPiece : ChessPiece?) {
        self.piece = piece
        self.previousLocation = previousLocation
        self.consumedPiece = consumedPiece
        self.newLocation = newLocation
    }
    
    var description: String{
        get{
            return "from:\(previousLocation) to:\(newLocation) consuming:\(String(describing: consumedPiece))"
        }
    }
    
    public static func ==(lhs: Move, rhs: Move) -> Bool{
        return lhs.previousLocation == rhs.previousLocation && lhs.newLocation == rhs.newLocation
    }
    
    public var hashValue: Int {
    
        return (previousLocation.hashValue + newLocation.hashValue) * piece.player.id
    
    }
}
