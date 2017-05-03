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
    var up : Int { get }
    var right   : Int { get }
    var down : Int { get }
    var left      : Int { get }
    var diagonal : Int { get }
}

class PawnMovement : Movement{
    
    var canMoveDirectlyDiagonally: Bool { return false }
    var canMoveDirectlyForward: Bool{ return true }
    var canMoveDirectlyBackwards: Bool{ return false }
    var canMoveDirectlyLeft: Bool{ return false }
    var canMoveDirectlyRight: Bool{ return false }

    private var _up = 1
    private var _down = 0
    func setUpDown(up : Int, down : Int){
        self._up = up
        self._down = down
    }
    
    var up: Int{ return _up }
    var right: Int{ return 0 }
    var down: Int{ return _down }
    var left: Int{ return 0 }
    var diagonal : Int { return 0 }
}

class RookMovement : Movement{
    
    var canMoveDirectlyDiagonally: Bool { return false }
    var canMoveDirectlyForward: Bool{ return true }
    var canMoveDirectlyBackwards: Bool{ return true }
    var canMoveDirectlyLeft: Bool{ return true }
    var canMoveDirectlyRight: Bool{ return true }
    
    var up: Int{ return 8 }
    var right: Int{ return 8 }
    var left: Int{ return 8 }
    var down: Int{ return 8 }
    var diagonal : Int { return 0 }
}

class KnightMovement : Movement{
    
    var canMoveDirectlyDiagonally: Bool { return false }
    var canMoveDirectlyForward: Bool{ return false }
    var canMoveDirectlyBackwards: Bool{ return false }
    var canMoveDirectlyLeft : Bool { return false }
    var canMoveDirectlyRight: Bool { return false }
    
    var up: Int{ return 0 }
    var down: Int{ return 0 }
    var left: Int{ return 0 }
    var right : Int{ return 0 }
    var diagonal : Int { return 0 }
}

class BishopMovement : Movement{
    var canMoveDirectlyDiagonally: Bool { return true }
    var canMoveDirectlyForward: Bool{ return false }
    var canMoveDirectlyBackwards: Bool{ return false }
    var canMoveDirectlyLeft : Bool { return false }
    var canMoveDirectlyRight: Bool { return false }
    
    var up: Int{ return 0 }
    var down: Int{ return 0 }
    var left: Int{ return 0 }
    var right : Int{ return 0 }
    var diagonal : Int { return 8 }
}

class QueenMovement : Movement{
    var canMoveDirectlyDiagonally: Bool { return true }
    var canMoveDirectlyForward: Bool{ return true }
    var canMoveDirectlyBackwards: Bool{ return true }
    var canMoveDirectlyLeft : Bool { return true }
    var canMoveDirectlyRight: Bool { return true }
    
    var up: Int{ return 8 }
    var down: Int{ return 8 }
    var left: Int{ return 8 }
    var right : Int{ return 8 }
    var diagonal : Int { return 8 }
}

class KingMovement : Movement{
    var canMoveDirectlyDiagonally: Bool { return true }
    var canMoveDirectlyForward: Bool{ return true }
    var canMoveDirectlyBackwards: Bool{ return true }
    var canMoveDirectlyLeft : Bool { return true }
    var canMoveDirectlyRight: Bool { return true }
    
    var up: Int{ return 1 }
    var down: Int{ return 1 }
    var left: Int{ return 1 }
    var right : Int{ return 1 }
    var diagonal : Int { return 1 }
}

protocol ChessPieceDelegate{
    func positionDidChange(piece : ChessPiece, oldPosition : Point)
}

class ChessPiece : CustomStringConvertible, Equatable, Hashable{
    
    private var moves = [Point]()
    
    var Moves : [Point]{
        get{
            return self.moves
        }
    }
    
    var player : Player
    var delegate : ChessPieceDelegate?
    
    var allowedMovement : Movement
    
    var origin : Point = Point(0,0){
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
    
    func setMoves(moves : [Point]){
        self.moves = moves
    }
    
    func clearMoves(){
        self.moves = [Point]()
    }
    
    init(origin : Point, movement : Movement, player : Player){
        self.origin = origin
        self.allowedMovement = movement
        self.player = player
    }
    
    var description: String{
        get{
            return "\(name) x:\(x) y:\(y)"
        }
    }
    
    public var hashValue: Int {
        return x * 10 + y * 100
    }
    
    public static func ==(lhs: ChessPiece, rhs: ChessPiece) -> Bool{
        return lhs.name == rhs.name && lhs.origin == rhs.origin
    }
}

class Pawn : ChessPiece{
    
    override var name: String{
        get{
            return "Pawn"
        }
    }
    
    init(origin : Point, movement : PawnMovement, player : Player) {
        super.init(origin: origin, movement: movement, player: player)
    }
}

class Rook : ChessPiece{
    override var name: String{
        get{
            return "Rook"
        }
    }
    
    override init(origin : Point, movement : Movement, player : Player) {
        super.init(origin: origin, movement: movement, player: player)
    }
}

class Knight : ChessPiece{
    override var name: String{
        get{
            return "Knight"
        }
    }
    
    init(){
        super.init(origin: Point(0,0), movement: KnightMovement(), player: Player(name: "Player 1", id: 1))
    }
    
    override init(origin : Point, movement : Movement, player : Player) {
        super.init(origin: origin, movement: movement, player: player)
    }
}

class Bishop : ChessPiece{
    override var name: String{
        get{
            return "Bishop"
        }
    }
    
    init() {
        super.init(origin: Point(0,0), movement: BishopMovement(), player: Player(name: "Player 1", id: 1))
    }
    
    override init(origin : Point, movement : Movement, player : Player) {
        super.init(origin: origin, movement: movement, player: player)
    }
}

class Queen : ChessPiece{
    override var name: String{
        get{
            return "Queen"
        }
    }
    
    override init(origin : Point, movement : Movement, player : Player) {
        super.init(origin: origin, movement: movement, player: player)
    }
}

class King : ChessPiece{
        
    override var name: String{
        get{
            return "King"
        }
    }
    
    init(){
        super.init(origin: Point(0,0), movement: KingMovement(), player: Player(name: "Player 1", id: 1))
    }
    
    override init(origin : Point, movement : Movement, player : Player) {
        super.init(origin: origin, movement: movement, player: player)
    }
}

















