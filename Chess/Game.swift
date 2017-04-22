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

class Game : UIBoardDelegate{
    
    private var pendingMove : Move?
    
    var gameOver : Bool = false{
        didSet{
            if gameOver{
                gameDelegate?.gameOver(loser: currentPlayer)
            }
        }
    }
    
    private var player1removed = [ChessPiece]()
    private var player2removed = [ChessPiece]()
    
    private var board = ChessBoard(player1Name: "", player2Name: "")
    
    var player1Deleted : [ChessPiece]{ return player1removed }
    var player2Deleted : [ChessPiece]{ return player2removed }
    
    var gameDelegate : GameDelegate?
    
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

    
    var firstPlayer : Player { return _player1 }
    var secondPlayer : Player{ return _player2 }
    
    private var currentTurn : Player
    var currentPlayer : Player{ return currentTurn }
    
    init(p1 : Player, p2 : Player){
        self._player1 = p1
        self._player2 = p2
        self.currentTurn = p1
    }
    
    var firstPlayerTurn : Bool{
        return currentTurn == _player1
    }
    
    private var selected : ChessPiece?{
        didSet{
            if selected == nil{
                self.pieceDeselected()
                return
            }
            self.pieceSelected(piece: selected!)
        }
    }
    
    private func playerInCheck(p : Player,
                               moved : ChessPiece,
                               oldPosition : Point,
                               consumedPiece : ChessPiece?){
        gameDelegate?.playerInCheck(player: p)
        if let removedPiece = consumedPiece{
            self.board.addPiece(piece: removedPiece)
        }
        moved.origin = oldPosition
    }
    
    func verifyCheckMate(p : Player, attackingPiece : ChessPiece, attacked : ChessPiece){ //check if the current player is in checkmate
        //checkmate if the attacking piece cannot be blocked or eaten
        
        let kingAttacker = board.pieceVulnerable(piece: attackingPiece)
        let blockingPiece = board.pieceCanBeBlockedFromAttackingPiece(attacker: attackingPiece, attacked: attacked)
        
        if ( kingAttacker == nil && blockingPiece == nil){
            //game over
            gameOver = true
        }
    }
    
    func undoPendingMove(){
        if let pending = pendingMove{
            pending.piece.origin = pending.previousLocation
            if let pawn = pending.piece as? Pawn{
                (pawn.allowedMovement as! PawnMovement).movedTwo = false
            }
            if let consumed = pending.consumedPiece{
                self.board.addPiece(piece: consumed)
            }
            pendingMove = nil
        }
    }
    
    func confirmPendingMove(){
        if let pending = pendingMove{
            self.switchTurns(moved: pending.piece, oldPosition: pending.previousLocation, pieceRemoved: pending.consumedPiece)
            pendingMove = nil
        }
    }
    
    func switchTurns(){
        self.currentTurn = (self.currentTurn == _player1) ? _player2 : _player1
        gameDelegate?.didSwitchTurn(player: currentPlayer)
    }
    
    func switchTurns(moved : ChessPiece, oldPosition : Point, pieceRemoved : ChessPiece?){
        
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
        self.switchTurns()
    }
    
    
    
    func pieceDeselected(){
        gameDelegate?.pieceDeselected()
    }
    
    func pieceSelected(piece : ChessPiece){
        gameDelegate?.pieceSelected(piece: piece)
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
    
    func pieceMoved(piece : ChessPiece, previousLocation : Point, consumedPiece : ChessPiece?){
        self.pendingMove = Move(piece: piece, previousLocation: previousLocation, consumedPiece: consumedPiece)
        self.gameDelegate?.pieceMoved(piece: piece)
    }
    
    func changePiecePosition(piece: ChessPiece, newPosition : Point) -> Bool{
        
        if pendingMove != nil || gameOver || piece.player != currentPlayer{
            return false
        }
        let oldPosition = piece.origin
        let diff = piece.y - newPosition.y
        if self.board.canChangePiecePosition(piece: piece, newPosition: newPosition){
            
            /*Avoid pawn moving backwards*/
            
            if piece is Pawn{
                
                if diff > 0 && !firstPlayerTurn || (diff < 0 && firstPlayerTurn){ //direction is downward
                    return false
                }
            }
            
            piece.origin = Point(newPosition.x, newPosition.y)
            self.pieceMoved(piece: piece, previousLocation: oldPosition, consumedPiece: nil)
            return true
        }else{
            if let pawn = piece as? Pawn{
                if !(pawn.allowedMovement as! PawnMovement).movedTwo &&
                    abs(diff) == 2 &&
                    piece.player == currentPlayer &&
                    abs(piece.x - newPosition.x) == 0{
                    (piece.allowedMovement as! PawnMovement).movedTwo = true
                    pawn.origin = newPosition
                    self.pieceMoved(piece: pawn, previousLocation: oldPosition, consumedPiece: nil)
                    return true
                }
            }
        }
        return false
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
            piece1.origin = Point(piece2.x, piece2.y)
            return piece2
        }else {
            print("\(piece1) cannot eat \(piece2)")
        }
        
        return nil
    }
    
    func consumePiece(piece1 : ChessPiece, piece2 : ChessPiece) -> Bool{
        let oldPosition = piece1.origin
        if piece1.player == piece2.player || currentPlayer != piece1.player || pendingMove != nil{
            return false
        }
        
        if let consumed = self.consume(piece1: piece1, piece2: piece2){
            pieceRemoved(piece: piece2)
            self.pieceMoved(piece: piece1, previousLocation: oldPosition, consumedPiece: consumed)
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
        gameDelegate?.gameStarted()
        if currentPlayer.id == 2{
            self.switchTurns()
        }
    }
    
    private func initPawns(){
        let p1_move = PawnMovement()
        p1_move.setUpDown(up: 1, down: 0)
        let p2_move = PawnMovement()
        p1_move.setUpDown(up: 0, down: 1)
        for i in 0..<8{
            board.addPiece(piece: Pawn(origin: Point(i,1), movement: p1_move, player: secondPlayer))
            board.addPiece(piece: Pawn(origin: Point(i,6), movement: p2_move, player: firstPlayer))
        }
    }
    
    private func initRooks(){
        addPiece(piece: Rook(origin: Point(0,0), movement: RookMovement(), player: secondPlayer))
        addPiece(piece: Rook(origin: Point(7,0), movement: RookMovement(), player: secondPlayer))
        addPiece(piece: Rook(origin: Point(0,7), movement: RookMovement(), player: firstPlayer))
        addPiece(piece: Rook(origin: Point(7,7), movement: RookMovement(), player: firstPlayer))
    }
    
    private func initKnights(){
        addPiece(piece: Knight(origin: Point(1,0), movement: KnightMovement(), player: secondPlayer))
        addPiece(piece: Knight(origin: Point(6,0), movement: KnightMovement(), player: secondPlayer))
        addPiece(piece: Knight(origin: Point(1,7), movement: KnightMovement(), player: firstPlayer))
        addPiece(piece: Knight(origin: Point(6,7), movement: KnightMovement(), player: firstPlayer))
    }
    
    private func initBishops(){
        addPiece(piece: Bishop(origin: Point(2,0), movement: BishopMovement(), player: secondPlayer))
        addPiece(piece: Bishop(origin: Point(5,0), movement: BishopMovement(), player: secondPlayer))
        addPiece(piece: Bishop(origin: Point(2,7), movement: BishopMovement(), player: firstPlayer))
        addPiece(piece: Bishop(origin: Point(5,7), movement: BishopMovement(), player: firstPlayer))
    }
    
    private func initKings(){
        addPiece(piece: King(origin: Point(4,0), movement: KingMovement(), player: secondPlayer))
        addPiece(piece: King(origin: Point(4,7), movement: KingMovement(), player: firstPlayer))
    }
    
    private func initQueens(){
        addPiece(piece: Queen(origin: Point(3,0), movement: QueenMovement(), player: secondPlayer))
        addPiece(piece: Queen(origin: Point(3,7), movement: QueenMovement(), player: firstPlayer))
    }

    func moveRequested(newLocation: (x: Float, y: Float)) {
        if selected == nil{
            return
        }
        let x = newLocation.x
        let y = newLocation.y
        let x_diff = x - Float(Int(x))
        let y_diff = y - Float(Int(y))
        DispatchQueue.main.async {
            let locations : (x : Int, y : Int) = (Int(x), Int(y))
            let increments : [(x : Int, y : Int)] = [(0, 1), (0, -1), (1, 0), (-1, 0)]
            let conditions : [Bool] = [(y_diff >= 0.9), (y_diff <= 0.1), (x_diff >= 0.9), (x_diff <= 0.1)]
            if !self.changePiecePosition(piece: self.selected!, newPosition: Point(locations.x, locations.y)){
                for i in 0..<4{
                    let current : (x : Int, y : Int) = (locations.x + increments[i].x, locations.y + increments[i].y)
                    if conditions[i] && self.changePiecePosition(piece: self.selected!, newPosition: Point(current.x, current.y)){
                        break
                    }
                }
            }
        }
    }
    
    func pieceTapped(piece: ChessPiece) {
        if piece.player.id == currentTurn.id{
            self.selected = piece
        }else{ //an attack on an opposing player's piece
             if let selectedPiece = self.selected{
                 let _ = self.consumePiece(piece1: selectedPiece, piece2: piece)
             }
        }
    }
}








