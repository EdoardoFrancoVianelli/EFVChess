//
//  Game.swift
//  Chess
//
//  Created by Edoardo Franco Vianelli on 2/8/17.
//  Copyright © 2017 Edoardo Franco Vianelli. All rights reserved.
//

import Foundation

protocol GameDelegate {
    func playerInCheck(player : Player)
    func didSwitchTurn(player : Player)
    func pieceSelected(piece : ChessPiece)
    func pieceDeselected()
    func gameOver(loser : Player)
}

class Game{
    
    var gameOver : Bool = false{
        didSet{
            delegate?.gameOver(loser: currentPlayer)
        }
    }
    
    private var player1removed = [ChessPiece]()
    private var player2removed = [ChessPiece]()
    
    var board = ChessBoard(player1Name: "", player2Name: "")
    
    var player1Deleted : [ChessPiece]{
        return player1removed
    }
    
    var player2Deleted : [ChessPiece]{
        return player2removed
    }
    
    var delegate : GameDelegate?
    var boardDelegate : ChessBoardDelegate?{
        set{
            board.delegate = newValue
        }get{
            return board.delegate
        }
    }
        
    private var _player1 : Player{
        didSet{
            print("Setting player 1")
        }
    }
    private var _player2 : Player{
        didSet{
            print("Setting player 2")
        }
    }

    
    var firstPlayer : Player{
        return _player1
    }
    
    var secondPlayer : Player{
        return _player2
    }
    
    private var currentTurn : Player
    
    var currentPlayer : Player{
        return currentTurn
    }
    
    init(p1 : Player, p2 : Player){
        self._player1 = p1
        self._player2 = p2
        self.currentTurn = p1
    }
    
    var firstPlayerTurn : Bool{
        return currentTurn == _player1
    }
    
    private func playerInCheck(p : Player, moved : ChessPiece, oldPosition : (x : Int, y : Int)){
        delegate?.playerInCheck(player: _player1)
        moved.origin = oldPosition
        return
    }
    
    func verifyCheckMate(p : Player, attackingPiece : ChessPiece, attacked : ChessPiece){ //check if the current player is in checkmate
        //checkmate if the attacking piece cannot be blocked or eaten
        
        if ( board.pieceVulnerable(piece: attackingPiece) == nil && board.pieceCanBeBlockedFromAttackingPiece(attacker: attackingPiece, attacked: attacked) == nil){
            //game over
        }
    }
    
    func switchTurns(moved : ChessPiece, oldPosition : (x : Int, y : Int)){
        
        if currentTurn == _player1{
            
            if let attacker = board.player1Check{
                playerInCheck(p: _player1, moved: moved, oldPosition: oldPosition)
                verifyCheckMate(p: _player1, attackingPiece: attacker, attacked: board.firstPlayerKing)
                return
            }
            
            self.currentTurn = _player2
            
        }else{
            
            if let attacker = board.player2Check{
                playerInCheck(p: _player1, moved: moved, oldPosition: oldPosition)
                verifyCheckMate(p: _player2, attackingPiece: attacker, attacked: board.secondPlayerKing)
                return
            }
            
            self.currentTurn = _player1
            
        }
        
        delegate?.didSwitchTurn(player: currentPlayer)
    }
    
    func pieceDeselected(){
        delegate?.pieceDeselected()
    }
    
    func pieceSelected(piece : ChessPiece){
        delegate?.pieceSelected(piece: piece)
    }
    
    func pieceRemoved(piece : ChessPiece){
        if piece.player == _player1{
            player1removed.append(piece)
        }else if piece.player == _player2{
            player2removed.append(piece)
        }
    }
    
    func setPlayerNames(p1 : String, p2 : String){
        self._player1.name = p1
        self._player2.name = p2
    }
    
    func changePiecePosition(piece: ChessPiece, newPosition : (x : Int, y : Int)){
        
        if gameOver{
            print("Game is over, you can't move anything")
        }
        
        let oldPosition = piece.origin
        if piece.player != currentPlayer{
            return
        }
        let diff = piece.y - newPosition.y
        if self.board.canChangePiecePosition(piece: piece, newPosition: newPosition){
            
            /*Avoid pawn moving backwards*/
            
            if piece is Pawn{
                
                if diff < 0 && !firstPlayerTurn || (diff > 0 && firstPlayerTurn){ //direction is downward
                    return
                }
            }
            
            piece.origin = (newPosition.x, newPosition.y)
            self.switchTurns(moved: piece, oldPosition: oldPosition)
        }else{
            if let pawn = piece as? Pawn{
                if !(pawn.allowedMovement as! PawnMovement).movedTwo &&
                    abs(diff) == 2 &&
                    piece.player == currentPlayer &&
                    abs(piece.x - newPosition.x) == 0{
                    (piece.allowedMovement as! PawnMovement).movedTwo = true
                    pawn.origin = newPosition
                    self.switchTurns(moved: piece, oldPosition: oldPosition)
                }
            }
        }
    }
    
    func addPiece(piece : ChessPiece){
        self.board.addPiece(piece: piece)
    }
    
    func consumePiece(piece1 : ChessPiece, piece2 : ChessPiece) -> Bool{
        let oldPosition = piece1.origin
        if piece1.player == piece2.player || currentPlayer != piece1.player{
            return false
        }
        
        if self.board.consumePiece(piece1: piece1, piece2: piece2){
            pieceRemoved(piece: piece2)
            switchTurns(moved: piece1, oldPosition: oldPosition)
        }
        
        return true
    }
    
    //MARK: Game initialization code

    func startGame(){
        self.gameOver = false
        self.board.removeAllPieces()
        self.initPawns()
        self.initRooks()
        self.initKnights()
        self.initBishops()
        self.initKings()
        self.initQueens()
    }
    
    private func initPawns(){
        for i in 0..<8{
            board.addPiece(piece: Pawn(x: i, y: 1, movement: PawnMovement(), player: firstPlayer))
            board.addPiece(piece: Pawn(x: i, y: 6, movement: PawnMovement(), player: secondPlayer))
        }
    }
    
    private func initRooks(){
        addPiece(piece: Rook(x: 0, y: 0, movement: RookMovement(), player: firstPlayer))
        addPiece(piece: Rook(x: 7, y: 0, movement: RookMovement(), player: firstPlayer))
        addPiece(piece: Rook(x: 0, y: 7, movement: RookMovement(), player: secondPlayer))
        addPiece(piece: Rook(x: 7, y: 7, movement: RookMovement(), player: secondPlayer))
    }
    
    private func initKnights(){
        addPiece(piece: Knight(x: 1, y: 0, movement: KnightMovement(), player: firstPlayer))
        addPiece(piece: Knight(x: 6, y: 0, movement: KnightMovement(), player: firstPlayer))
        addPiece(piece: Knight(x: 1, y: 7, movement: KnightMovement(), player: secondPlayer))
        addPiece(piece: Knight(x: 6, y: 7, movement: KnightMovement(), player: secondPlayer))
    }
    
    private func initBishops(){
        addPiece(piece: Bishop(x: 2, y: 0, movement: BishopMovement(), player: firstPlayer))
        addPiece(piece: Bishop(x: 5, y: 0, movement: BishopMovement(), player: firstPlayer))
        addPiece(piece: Bishop(x: 2, y: 7, movement: BishopMovement(), player: secondPlayer))
        addPiece(piece: Bishop(x: 5, y: 7, movement: BishopMovement(), player: secondPlayer))
    }
    
    private func initKings(){
        addPiece(piece: King(x: 4, y: 0, movement: KingMovement(), player: firstPlayer))
        addPiece(piece: King(x: 4, y: 7, movement: KingMovement(), player: secondPlayer))
    }
    
    private func initQueens(){
        addPiece(piece: Queen(x: 3, y: 0, movement: QueenMovement(), player: firstPlayer))
        addPiece(piece: Queen(x: 3, y: 7, movement: QueenMovement(), player: secondPlayer))
    }
}








