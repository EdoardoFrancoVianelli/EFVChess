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

class Point : Hashable, Equatable{
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
        self.player1King = King(origin: Point(0,0), movement: KingMovement(), player: Player(name: "", id: 1))
        self.player2King = King(origin: Point(0,0), movement: KingMovement(), player: Player(name: "", id: 2))
    }
    
    func pieceCanEat(piece : ChessPiece, other : ChessPiece) -> Bool{
        
        if piece.player == other.player{
            return false
        }
        
        let allowed  = allowedMovementLocations(piece: piece).contains(where: { (p : Point) in
            return Point(p.x,p.y) == other.origin
        })// changeAllowed(piece: piece, newPosition: other.origin, inclusive: false)
        let can_move = movementPossible(piece: piece, newPosition: other.origin)
        if !allowed && can_move && piece is Pawn{
            return true
        }
        return allowed && can_move
    }
    
    func canEscape(piece : ChessPiece, other : ChessPiece) -> Bool{
        let piece1Locations = Set(allowedMovementLocations(piece: piece))
        let piece2Locations = Set(allowedMovementLocations(piece: other))
        return !(piece1Locations.subtracting(piece2Locations)).isEmpty
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
    
    func allowedMovementLocations(piece : ChessPiece) -> [Point]{
        let pieceMovement = piece.allowedMovement
        var locations = [Point]()

        //left, right, up, down
        
        let movements : [(max : Int, increments : (x : Int, y : Int))] = [(pieceMovement.left, (-1, 0)),
                                                                                   (pieceMovement.right, (1, 0)),
                                                                                   (pieceMovement.up, (0,-1)),
                                                                                   (pieceMovement.down, (0, 1)),
                                                                                   (pieceMovement.diagonal, (1, 1)),
                                                                                   (pieceMovement.diagonal, (-1, -1)),
                                                                                   (pieceMovement.diagonal, (-1, 1)),
                                                                                   (pieceMovement.diagonal, (1, -1))]
        for direction in movements{
            var x = piece.x
            var y = piece.y
            for _ in 0..<direction.max{
                while true{
                    x += direction.increments.x
                    y += direction.increments.y
                    if !(x > 0 && x < 8 && y > 0 && y < 8){
                        break
                    }
                    locations.append(Point(x, y))
                }
            }
        }
        
        if piece is Knight{
            let possible_locations : [Point] = [Point(piece.x - 1, piece.y - 2),
                                                             Point(piece.x + 1, piece.y - 2),
                                                             Point(piece.x - 1, piece.y + 2),
                                                             Point(piece.x + 1, piece.y + 2)]
            for location in possible_locations{
                if location.x > 0 && location.x < 8 && location.y > 0 && location.y < 8{
                    locations.append(location)
                }
            }
        }
        
        return locations
    }
    
    func pieceVulnerable(piece : ChessPiece) -> ChessPiece? {
        
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
                if let currentPiece = self.board["\(x)\(y)"]{
                    
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
                if let currentPiece = self.board["\(current.x)\(current.y)"]{
                                        
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
    
    private func movementPossible(piece : ChessPiece, newPosition : Point) -> Bool{
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
    
    func canChangePiecePosition(piece : ChessPiece, newPosition : Point) -> Bool{
        
        //verify legitimacy of position change
        
        /*
        if !changeAllowed(piece: piece, newPosition: newPosition, inclusive: true){
            print("Cannot move \(piece) to \(newPosition)")
            print(self.board.count)
            return false
        }
         */
        
        let locations = allowedMovementLocations(piece: piece)
        if !(locations.contains(where: { element in
            return element == newPosition
        })){
            print("Cannot move \(piece) to \(newPosition)")
            print(self.board.count)
            return false
        }
        
        if piece is Pawn{
            (piece.allowedMovement as? PawnMovement)?.movedTwo = true
        }
        
        return true
    }
    
    func positionDidChange(piece: ChessPiece, oldPosition : Point) {
        
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
    
    func pieceAt(x : Int, y : Int) -> ChessPiece?{
        return self.board["\(x)\(y)"]
    }
}














