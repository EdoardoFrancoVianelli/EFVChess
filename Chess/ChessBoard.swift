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

class ChessBoard : ChessPieceProtocol, PlayerProtocol{
    
    var currentGame : Game{
        return game
    }
    
    private var game  : Game
    private var board = Dictionary<String, ChessPiece>()
    var delegate : ChessBoardProtocol?
    
    init(player1Name : String, player2Name : String){
        self.board = Dictionary<String, ChessPiece>()
        self.game = Game(p1: Player(name: player1Name, id: 1), p2: Player(name: player2Name, id: 2))
        self.game.firstPlayer.delegate = self
        self.game.secondPlayer.delegate = self
    }
    
    private func initPawns(){
        for i in 0..<8{
            addPiece(piece: Pawn(x: i, y: 1, movement: PawnMovement(), player: game.firstPlayer))
            addPiece(piece: Pawn(x: i, y: 6, movement: PawnMovement(), player: game.secondPlayer))
        }
    }
    
    private func initRooks(){
        addPiece(piece: Rook(x: 0, y: 0, movement: RookMovement(), player: game.firstPlayer))
        addPiece(piece: Rook(x: 7, y: 0, movement: RookMovement(), player: game.firstPlayer))
        addPiece(piece: Rook(x: 0, y: 7, movement: RookMovement(), player: game.secondPlayer))
        addPiece(piece: Rook(x: 7, y: 7, movement: RookMovement(), player: game.secondPlayer))
    }
    
    private func initKnights(){
        addPiece(piece: Knight(x: 1, y: 0, movement: KnightMovement(), player: game.firstPlayer))
        addPiece(piece: Knight(x: 6, y: 0, movement: KnightMovement(), player: game.firstPlayer))
        addPiece(piece: Knight(x: 1, y: 7, movement: KnightMovement(), player: game.secondPlayer))
        addPiece(piece: Knight(x: 6, y: 7, movement: KnightMovement(), player: game.secondPlayer))
    }
    
    private func initBishops(){
        addPiece(piece: Bishop(x: 2, y: 0, movement: BishopMovement(), player: game.firstPlayer))
        addPiece(piece: Bishop(x: 5, y: 0, movement: BishopMovement(), player: game.firstPlayer))
        addPiece(piece: Bishop(x: 2, y: 7, movement: BishopMovement(), player: game.secondPlayer))
        addPiece(piece: Bishop(x: 5, y: 7, movement: BishopMovement(), player: game.secondPlayer))
    }
    
    private func initKings(){
        addPiece(piece: King(x: 4, y: 0, movement: KingMovement(), player: game.firstPlayer))
        addPiece(piece: King(x: 4, y: 7, movement: KingMovement(), player: game.secondPlayer))
    }
    
    private func initQueens(){
        addPiece(piece: Queen(x: 3, y: 0, movement: QueenMovement(), player: game.firstPlayer))
        addPiece(piece: Queen(x: 3, y: 7, movement: QueenMovement(), player: game.secondPlayer))
    }
    
    private func inRange(piece : ChessPiece, destination : (x : Int, y : Int)) -> Bool{
        if piece.x < destination.x && piece.y < destination.y{
            return piece.x + piece.allowedMovement.right >= destination.x && piece.y + piece.allowedMovement.forward <= destination.y
        }else if piece.x < destination.x && piece.y >= destination.y{
            return piece.x + piece.allowedMovement.right >= destination.x && piece.y - piece.allowedMovement.backwards <= destination.y
        }
        else if piece.x >= destination.x && piece.y < destination.y{
            return piece.x - piece.allowedMovement.left <= destination.x && piece.y + piece.allowedMovement.forward >= destination.y
        }
        else if piece.x >= destination.x && piece.y >= destination.y{
            return piece.x - piece.allowedMovement.left <= destination.x && piece.y - piece.allowedMovement.backwards >= destination.y
        }
        return true
    }
    
    func nameDidChange(previousName: String, newName: String) {
        
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
                if pieceCanEat(piece: currentPiece, other: piece){
                    return true
                }
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
                if pieceCanEat(piece: currentPiece, other: piece){
                    return true
                }
            }
        }
        
        //check diagonals
        
        var x = -1
        var y = piece.origin.y - piece.origin.x - 1
        
        print("Diagonal")
        
        for _ in 0..<8{
            
            x += 1
            y += 1
            
            if piece.x == x && piece.y == y || (piece.x - x == x && piece.y - y == y){
                continue
            }
            
            print("(\(x),\(y))")
            
            if let currentPiece = self.board["\(x)\(y)"]{
                if pieceCanEat(piece: currentPiece, other: piece){
                    return true
                }
            }
            
            if x > 8 || y > 9{
                break
            }
        }
        
        return false
    }
    
    func consumePiece(piece1 : ChessPiece, piece2 : ChessPiece) -> Bool{
        if piece1.player == piece2.player || game.currentPlayer != piece1.player{
            return false
        }
        
        if pieceCanEat(piece: piece1, other: piece2){
            removePiece(piece: piece2)
            piece1.origin = (piece2.x, piece2.y)
            game.pieceRemoved(piece: piece2)
            game.switchTurns()
            return true
        }else {
            print("\(piece1) cannot eat \(piece2)")
        }
        
        return false
    }
    
    func startGame(){
        self.initPawns()
        self.initRooks()
        self.initKnights()
        self.initBishops()
        self.initKings()
        self.initQueens()
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
                if !movement_allowed{
                    if piece is Pawn{
                        if !(piece.allowedMovement as! PawnMovement).movedTwo && abs(diff) == 2 && piece.player == game.currentPlayer
                        {
                            (piece.allowedMovement as! PawnMovement).movedTwo = true
                            allowed = true
                        }
                    }
                }
                
                if diff < 0{ //direction is downward
                    return (movement_allowed || allowed) && game.firstPlayerTurn
                }else{ //direction is upward
                    return (movement_allowed || allowed) && !game.firstPlayerTurn
                }
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
        
        return allowed && piece.player == game.currentPlayer
    }
    
    func changePiecePosition(piece : ChessPiece, newPosition : (x : Int, y : Int)){
        
        //verify legitimacy of position change
        
        if !changeAllowed(piece: piece, newPosition: newPosition, inclusive: true){
            print("Cannot move \(piece) to \(newPosition)")
            print(self.board.count)
            return
        }
        
        game.switchTurns()
        
        if piece is Pawn{
            (piece.allowedMovement as? PawnMovement)?.movedTwo = true
        }
        
        piece.origin = (newPosition.x, newPosition.y)
    }
    
    func positionDidChange(piece: ChessPiece, oldPosition : (x : Int, y : Int)) {
        //pieceVulnerable(piece: piece)
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
        self.board.removeValue(forKey: "\(piece.x)\(piece.y)")
        self.delegate?.pieceRemoved(piece: piece)
    }
}
