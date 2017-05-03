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
    
    var player1Check : ChessPiece?{
        return pieceVulnerable(piece: player1King)
    }
    
    var player2Check : ChessPiece?{
        return pieceVulnerable(piece: player2King)
    }
    
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
        
        self.player1King = King(origin: Point(0,0), movement: KingMovement(), player: Player(name: "", id: 1))
        self.player2King = King(origin: Point(0,0), movement: KingMovement(), player: Player(name: "", id: 2))
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
        
        let kingAttacker = pieceVulnerable(piece: attackingPiece)
        let blockingPiece = pieceCanBeBlockedFromAttackingPiece(attacker: attackingPiece, attacked: attacked)
        
        if ( kingAttacker == nil && blockingPiece == nil){
            //game over
            gameOver = true
        }
    }
    
    func undoPendingMove(){
        if let pending = pendingMove{
            pending.piece.origin = pending.previousLocation
            if let consumed = pending.consumedPiece{
                self.board.addPiece(piece: consumed)
            }
            pendingMove = nil
        }
    }
    
    func confirmPendingMove(){
        if let pending = self.pendingMove{
            if let pawn = pending.piece as? Pawn{
                let movement = pawn.allowedMovement as! PawnMovement
                let up = movement.up == 2 ? 1 : 0
                let down = movement.down == 2 ? 1 : 0
                movement.setUpDown(up: up, down: down)
            }
            pending.piece.setMoves(moves: allowedMovementLocations(piece: pending.piece))
            self.switchTurns(moved: pending.piece, oldPosition: pending.previousLocation, pieceRemoved: pending.consumedPiece)
            self.pendingMove = nil
        }
    }
    
    func switchTurns(){
        self.currentTurn = (self.currentTurn == _player1) ? _player2 : _player1
        gameDelegate?.didSwitchTurn(player: currentPlayer)
    }
    
    func switchTurns(moved : ChessPiece, oldPosition : Point, pieceRemoved : ChessPiece?){
        
        if gameOver { return }
        
        if let attacker = (currentTurn == _player1) ? player1Check : player2Check{
            let king     = (currentTurn == _player1) ? firstPlayerKing : secondPlayerKing
            playerInCheck(p: currentTurn, moved: moved, oldPosition: oldPosition, consumedPiece: pieceRemoved)
            verifyCheckMate(p: currentTurn, attackingPiece: attacker, attacked: king)
            if pieceRemoved != nil{
                board.addPiece(piece: pieceRemoved!)
            }
            return
        }else if remainingPiecesDraw() {//move has been completed, check for a draw
            gameOver = true
        }
        self.switchTurns()
    }
    
    func pieceDeselected(){
        gameDelegate?.pieceDeselected()
    }
    
    func pieceSelected(piece : ChessPiece){
        if piece.Moves.isEmpty{
            piece.setMoves(moves: allowedMovementLocations(piece: piece))
        }
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
        if self.canChangePiecePosition(piece: piece, newPosition: newPosition){
            piece.origin = Point(newPosition.x, newPosition.y)
            self.pieceMoved(piece: piece, previousLocation: oldPosition, consumedPiece: nil)
            return true
        }
        return false
    }
    
    func addPiece(piece : ChessPiece){
        
        if let king = piece as? King{
            if piece.player.id == 1{
                player1King = king
            }else{
                player2King = king
            }
        }
        
        self.board.addPiece(piece: piece)
    }
    
    func removeAllPieces(){
        for element in self.board.pieces{
            self.board.removePiece(piece: element.value)
        }
    }
    
    func consume(piece1 : ChessPiece, piece2 : ChessPiece) -> ChessPiece?{
        
        if pieceCanEat(piece: piece1, other: piece2){
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
        for i in 0..<8{
            let p1_move = PawnMovement()
            p1_move.setUpDown(up: 2, down: 0)
            let p2_move = PawnMovement()
            p2_move.setUpDown(up: 0, down: 2)
            board.addPiece(piece: Pawn(origin: Point(i,1), movement: p2_move, player: secondPlayer))
            board.addPiece(piece: Pawn(origin: Point(i,6), movement: p1_move, player: firstPlayer))
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
    
    func pieceTapped(piece: ChessPiece) -> [Point]{
        if piece.player.id == currentTurn.id{
            self.selected = piece
            return piece.Moves
        }else if let selectedPiece = self.selected{ //an attack on an opposing player's piece
             let _ = self.consumePiece(piece1: selectedPiece, piece2: piece)
        }
        return [Point]()
    }
    
    //MARK: Game Logic
    
    /*
    The game is immediately drawn when there is no possibility of checkmate for either side with any series of legal moves. This draw is often due to insufficient material, including the endgames
    king against king;
    king against king and bishop;
    king against king and knight;
    king and bishop against king and bishop, with both bishops on squares of the same color (see Checkmate#Unusual mates).[18]
     */
    
    func remainingPiecesDraw() -> Bool{
        
        if board.pieces.count >= 2 && board.pieces.count <= 4{
            var remaining = Dictionary<String, Int>()
            for piece in board.pieces{
                let name = piece.value.name
                remaining[name] = remaining.index(forKey: name) == nil ? 0 : remaining[name]! + 1
            }
            
            //king against king;
            if remaining.count == 2 && remaining[King().name] == 2{
                return true
            }else if remaining.count == 3 && remaining[King().name] == 2{
                if remaining[Bishop().name] == 1{ //king against king and bishop;
                    return true
                }else if remaining[Knight().name] == 1{ //king against king and knight;
                    return true
                }
            }
        }
        return false
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
    
    //can we escape from the current piece? And can we find a location where
    //we won't be in check?
    
    func canEscape(piece : ChessPiece, other : ChessPiece) -> Bool{
        let piece1Locations = Set(allowedMovementLocations(piece: piece))
        let piece2Locations = Set(allowedMovementLocations(piece: other))
        let subtraction = piece1Locations.subtracting(piece2Locations)
        return !subtraction.isEmpty
    }
    
    func pieceCanBeBlockedFromAttackingPiece(attacker : ChessPiece, attacked : ChessPiece) -> ChessPiece?{
        
        let attackLocations = Set(allowedMovementLocations(piece: attacker))
        
        for (_, piece) in self.board.pieces{
            if piece.player == attacked.player{
                let pieceLocations = Set(allowedMovementLocations(piece: piece))
                if !attackLocations.intersection(pieceLocations).isEmpty{
                    return piece
                }
            }
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
                x += direction.increments.x
                y += direction.increments.y
                if x < 0 || y < 0 || y > 7 || x > 7{ //!(x >= 0 && x < 8 && y >= 0 && y < 8){
                    break
                }
                //check if there is something in the way
                if self.board.pieces["\(x)\(y)"] == nil{
                    locations.append(Point(x, y))
                }
                else if let inTheWay = self.board.pieceAt(x: x, y: y){
                    if inTheWay.player != piece.player && !(piece is Pawn){ //if it is an opposing player, add it because we can capture it,
                        //unless it's a pawn at it can only capture diagonally
                        locations.append(Point(x,y))
                    }
                    break
                }
            }
        }
        
        if piece is Knight{
            let possible_locations : [Point] = [Point(piece.x - 1, piece.y - 2),
                                                Point(piece.x + 1, piece.y - 2),
                                                Point(piece.x - 1, piece.y + 2),
                                                Point(piece.x + 1, piece.y + 2)]
            for location in possible_locations{
                if location.x >= 0 && location.x < 8 && location.y >= 0 && location.y < 8{
                    if !self.board.hasPieceAtPoint(point: location){
                        locations.append(location)
                    }
                }
            }
        }
        
        return locations
    }
    
    func canChangePiecePosition(piece : ChessPiece, newPosition : Point) -> Bool{
        
        //verify legitimacy of position change
        let locations = piece.Moves// allowedMovementLocations(piece: piece)
        if !(locations.contains(where: { element in
            return element == newPosition
        })){
            print("Cannot move \(piece) to \(newPosition)")
            return false
        }
        
        return true
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
                if let currentPiece = self.board.pieces["\(x)\(y)"]{
                    
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
                if let currentPiece = self.board.pieces["\(current.x)\(current.y)"]{
                    
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
}








