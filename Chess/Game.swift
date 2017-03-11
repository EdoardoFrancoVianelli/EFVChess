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
    func gameStarted()
    func pieceMoved(piece : ChessPiece)
}

class Game{
    
    var gameOver : Bool = false{
        didSet{
            if gameOver{
                delegate?.gameOver(loser: currentPlayer)
            }
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
    
    private func playerInCheck(p : Player,
                               moved : ChessPiece,
                               oldPosition : (x : Int, y : Int),
                               consumedPiece : ChessPiece?){
        delegate?.playerInCheck(player: p)
        if let removedPiece = consumedPiece{
            self.board.addPiece(piece: removedPiece)
        }
        moved.origin = oldPosition
        return
    }
    
    func verifyCheckMate(p : Player, attackingPiece : ChessPiece, attacked : ChessPiece){ //check if the current player is in checkmate
        //checkmate if the attacking piece cannot be blocked or eaten
        
        let (kingAttacker, _) = board.pieceVulnerable(piece: attackingPiece)
        let blockingPiece = board.pieceCanBeBlockedFromAttackingPiece(attacker: attackingPiece, attacked: attacked)
        
        if ( kingAttacker == nil && blockingPiece == nil){
            //game over
            gameOver = true
        }
    }
    
    func switchTurns(moved : ChessPiece, oldPosition : (x : Int, y : Int), pieceRemoved : ChessPiece?){
        
        print("Positions for moved \(moved) are \(board.pieceVulnerable(piece: moved).locations)")
        
        if gameOver { return }
        
        if let attacker = (currentTurn == _player1) ? board.player1Check : board.player2Check{
            let king     = (currentTurn == _player1) ? board.firstPlayerKing : board.secondPlayerKing
            playerInCheck(p: currentTurn, moved: moved, oldPosition: oldPosition, consumedPiece: pieceRemoved)
            verifyCheckMate(p: currentTurn, attackingPiece: attacker, attacked: king)
            if pieceRemoved != nil{
                board.addPiece(piece: pieceRemoved!)
            }
            return
        }
        self.currentTurn = (self.currentTurn == _player1) ? _player2 : _player1
        delegate?.didSwitchTurn(player: currentPlayer)
    }
    
    func pieceDeselected(){
        delegate?.pieceDeselected()
    }
    
    func pieceSelected(piece : ChessPiece){
        //let locations = board.pieceVulnerable(piece: piece).locations
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
            return
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
            self.delegate?.pieceMoved(piece: piece)
            self.switchTurns(moved: piece, oldPosition: oldPosition, pieceRemoved: nil)
        }else{
            if let pawn = piece as? Pawn{
                if !(pawn.allowedMovement as! PawnMovement).movedTwo &&
                    abs(diff) == 2 &&
                    piece.player == currentPlayer &&
                    abs(piece.x - newPosition.x) == 0{
                    (piece.allowedMovement as! PawnMovement).movedTwo = true
                    pawn.origin = newPosition
                    self.switchTurns(moved: piece, oldPosition: oldPosition, pieceRemoved: nil)
                    self.delegate?.pieceMoved(piece: pawn)
                }
            }
        }
    }
    
    func addPiece(piece : ChessPiece){
        self.board.addPiece(piece: piece)
    }
    
    func removeAllPieces(){
        for element in self.board.pieces{
            self.board.removePiece(piece: element.value)
        }
    }
    
    func consume(piece1 : ChessPiece, piece2 : ChessPiece) -> ChessPiece?{
        
        if self.board.pieceCanEat(piece: piece1, other: piece2){
            self.board.removePiece(piece: piece2)
            piece1.origin = (piece2.x, piece2.y)
            return piece2
        }else {
            print("\(piece1) cannot eat \(piece2)")
        }
        
        return nil
    }
    
    func consumePiece(piece1 : ChessPiece, piece2 : ChessPiece) -> Bool{
        let oldPosition = piece1.origin
        if piece1.player == piece2.player || currentPlayer != piece1.player{
            return false
        }
        
        if let consumed = self.consume(piece1: piece1, piece2: piece2){
            pieceRemoved(piece: piece2)
            self.delegate?.pieceMoved(piece: piece1)
            switchTurns(moved: piece1, oldPosition: oldPosition, pieceRemoved: consumed)
        }
        
        return true
    }
    
    //MARK: Game initialization code

    func startGame(){
        self.gameOver = false
        self.removeAllPieces()
        self.initPawns()
        self.initRooks()
        self.initKnights()
        self.initBishops()
        self.initKings()
        self.initQueens()
        delegate?.gameStarted()
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








