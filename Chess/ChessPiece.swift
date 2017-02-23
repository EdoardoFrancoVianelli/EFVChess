//
//  ChessPiece.swift
//  Chess
//
//  Created by Edoardo Franco Vianelli on 1/30/17.
//  Copyright © 2017 Edoardo Franco Vianelli. All rights reserved.
//

import Foundation

//need to define allowed movements
//move in a certain direction with a certain number of hops

protocol Movement{
    
    var canMoveDirectlyDiagonally : Bool { get }
    var canMoveDirectlyForward : Bool { get }
    var canMoveDirectlyBackwards : Bool { get }
    var canMoveDirectlyLeft : Bool { get }
    var canMoveDirectlyRight : Bool { get }
    var forward : Int { get }
    var right   : Int { get }
    var backwards : Int { get }
    var left      : Int { get }
}

class PawnMovement : Movement{
    
    var movedTwo : Bool = false{
        didSet{
            print("Caught ya bitch")
        }
    }
    
    var canMoveDirectlyDiagonally: Bool { return false }
    var canMoveDirectlyForward: Bool{ return true }
    var canMoveDirectlyBackwards: Bool{ return false }
    var canMoveDirectlyLeft: Bool{ return false }
    var canMoveDirectlyRight: Bool{ return false }

    var forward: Int{ return 1 }
    
    var right: Int{ return 0 }
    
    var backwards: Int{ return 0 }
    
    var left: Int{ return 0 }
}

class RookMovement : Movement{
    
    var canMoveDirectlyDiagonally: Bool { return false }
    var canMoveDirectlyForward: Bool{ return true }
    var canMoveDirectlyBackwards: Bool{ return true }
    var canMoveDirectlyLeft: Bool{ return true }
    var canMoveDirectlyRight: Bool{ return true }
    
    var forward: Int{ return 8 }
    var right: Int{ return 8 }
    var left: Int{ return 8 }
    var backwards: Int{ return 8 }
    
}

class KnightMovement : Movement{
    
    var canMoveDirectlyDiagonally: Bool { return false }
    var canMoveDirectlyForward: Bool{ return false }
    var canMoveDirectlyBackwards: Bool{ return false }
    var canMoveDirectlyLeft : Bool { return false }
    var canMoveDirectlyRight: Bool { return false }
    
    var forward: Int{ return 2 }
    var backwards: Int{ return 2 }
    var left: Int{ return 1 }
    var right : Int{ return 1 }
}

class BishopMovement : Movement{
    var canMoveDirectlyDiagonally: Bool { return true }
    var canMoveDirectlyForward: Bool{ return false }
    var canMoveDirectlyBackwards: Bool{ return false }
    var canMoveDirectlyLeft : Bool { return false }
    var canMoveDirectlyRight: Bool { return false }
    
    var forward: Int{ return 8 }
    var backwards: Int{ return 8 }
    var left: Int{ return 8 }
    var right : Int{ return 8 }
}

class QueenMovement : Movement{
    var canMoveDirectlyDiagonally: Bool { return true }
    var canMoveDirectlyForward: Bool{ return true }
    var canMoveDirectlyBackwards: Bool{ return true }
    var canMoveDirectlyLeft : Bool { return true }
    var canMoveDirectlyRight: Bool { return true }
    
    var forward: Int{ return 8 }
    var backwards: Int{ return 8 }
    var left: Int{ return 8 }
    var right : Int{ return 8 }
}

class KingMovement : Movement{
    var canMoveDirectlyDiagonally: Bool { return true }
    var canMoveDirectlyForward: Bool{ return true }
    var canMoveDirectlyBackwards: Bool{ return true }
    var canMoveDirectlyLeft : Bool { return true }
    var canMoveDirectlyRight: Bool { return true }
    
    var forward: Int{ return 1 }
    var backwards: Int{ return 1 }
    var left: Int{ return 1 }
    var right : Int{ return 1 }
}

protocol ChessPieceDelegate{
    func positionDidChange(piece : ChessPiece, oldPosition : (x : Int, y : Int))
}

class ChessPiece : CustomStringConvertible{
    
    var player : Player
    var delegate : ChessPieceDelegate?
    
    var allowedMovement : Movement
    
    var origin : (x : Int, y : Int) = (0,0){
        didSet{
            if origin != oldValue{
                delegate?.positionDidChange(piece: self, oldPosition: oldValue)
            }
        }
    }
    
    var x : Int{
        get{
            return self.origin.x
        }
    }
    
    var y : Int{
        get{
            return self.origin.y
        }
    }
    
    var name : String{
        get{
            return ""
        }
    }
    
    init(x : Int, y : Int, movement : Movement, player : Player){
        self.origin = (x, y)
        self.allowedMovement = movement
        self.player = player
    }
    
    var description: String{
        get{
            return "\(name) x:\(x) y:\(y)"
        }
    }
}

class Pawn : ChessPiece{
    
    override var name: String{
        get{
            return "Pawn"
        }
    }
    
    init(x: Int, y: Int, movement : PawnMovement, player : Player) {
        super.init(x: x, y: y, movement: movement, player: player)
    }
}

class Rook : ChessPiece{
    override var name: String{
        get{
            return "Rook"
        }
    }
    
    override init(x: Int, y: Int, movement : Movement, player : Player) {
        super.init(x: x, y: y, movement: movement, player: player)
    }
}

class Knight : ChessPiece{
    override var name: String{
        get{
            return "Knight"
        }
    }
    
    override init(x: Int, y: Int, movement : Movement, player : Player) {
        super.init(x: x, y: y, movement: movement, player: player)
    }
}

class Bishop : ChessPiece{
    override var name: String{
        get{
            return "Bishop"
        }
    }
    
    override init(x: Int, y: Int, movement : Movement, player : Player) {
        super.init(x: x, y: y, movement: movement, player: player)
    }
}

class Queen : ChessPiece{
    override var name: String{
        get{
            return "Queen"
        }
    }
    
    override init(x: Int, y: Int, movement : Movement, player : Player) {
        super.init(x: x, y: y, movement: movement, player: player)
    }
}

class King : ChessPiece{
        
    override var name: String{
        get{
            return "King"
        }
    }
    
    override init(x: Int, y: Int, movement : Movement, player : Player) {
        super.init(x: x, y: y, movement: movement, player: player)
    }
}

















