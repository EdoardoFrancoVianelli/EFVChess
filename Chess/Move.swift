//
//  Move.swift
//  Chess
//
//  Created by Edoardo Franco Vianelli on 3/12/17.
//  Copyright © 2017 Edoardo Franco Vianelli. All rights reserved.
//

import Foundation

class Move{
    var piece : ChessPiece
    var previousLocation : Point
    var consumedPiece : ChessPiece?
    
    init(piece : ChessPiece, previousLocation : Point, consumedPiece : ChessPiece?) {
        self.piece = piece
        self.previousLocation = previousLocation
        self.consumedPiece = consumedPiece
    }
}
