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
    func timeWasSet(player : Player, time : Int)
}

enum PlayerType {
    case Human
    case CPU
}

func inRange(x : Int, lo : Int, hi : Int) -> Bool{
    return x >= lo && x <= hi
}

class Game : BoardDelegate{
    
    private var player1King : King
    private var player2King : King
    private var undoStack = [Move]()
    private var redoStack = [Move]()
    private var board = ChessBoard(player1Name: "", player2Name: "")
    private var _stats = GameStats()
    
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
    
    private var pendingMove : Move?{
        get{
            return undoStack.popLast()
        }set{
            if newValue == nil {
                return
            }
            undoStack.append(newValue!)
        }
    }
    
    var gameOver : Bool = false{
        didSet{
            if gameOver{
                gameDelegate?.gameOver(loser: currentPlayer)
            }
        }
    }
    
    var Stats : GameStats{
        return _stats
    }
    
    var gameDelegate : GameDelegate?
    
    var boardDelegate : ChessBoardDelegate?{
        set{
            board.delegate = newValue
        }get{
            return board.delegate
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
    
    private func verifyCheckMate(p : Player, attacked : ChessPiece) -> Bool{ //check if the current player is in checkmate
        //checkmate if the attacking piece cannot be blocked or eaten
        
        if let kingAttacker = pieceVulnerable(piece: attacked){
            let blockingPiece = pieceCanBeBlockedFromAttackingPiece(attacker: kingAttacker, attacked: attacked)
            let escape_possible = canEscapeAll(piece: attacked)
            return blockingPiece == nil && !escape_possible
        }
        
        return false
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
            if let movement = pending.piece.allowedMovement as? PawnMovement{
                let up = movement.up == 2 ? 1 : movement.up
                let down = movement.down == 2 ? 1 : movement.down
                movement.setUpDown(up: up, down: down)
            }
            switchTurns(moved: pending.piece, oldPosition: pending.previousLocation, pieceRemoved: pending.consumedPiece)
            self.pendingMove = nil
        }
    }
    
    func clearAndSaveGame(){
        removeAllPieces()
        createGamePieces()
        saveGame()
    }
    
    private func loadGame(clear : Bool){
        if clear {
            clearAndSaveGame()
            return
        }
        do {
            let fileContents = try String(contentsOfFile: Settings.gameFilePath)
            print(fileContents)
            let lines = fileContents.components(separatedBy: "\n")
            let player1Info = lines[0].components(separatedBy: ",")
            let player2Info = lines[1].components(separatedBy: ",")
            let p1Name = player1Info[0] /*Grab the name of the first player*/
            let p2Name = player2Info[0] /*Grab the name of the second player*/
            self._player1 = Human(name: p1Name, id: 1)
            self._player2 = player2Info[2] == "0" ? Human(name: p2Name, id: 2) : Computer(name: p2Name, id: 2)
            self._stats = GameStats(p1Elapsed: Int(player1Info[1])!, p2Elapsed: Int(player2Info[1])!)//init the stats
            self.gameDelegate?.timeWasSet(player: _player1, time: self._stats.player1Elapsed)
            self.gameDelegate?.timeWasSet(player: _player2, time: self._stats.player2Elapsed)
            for i in 2..<lines.count-1{ //skip the last newline
                let line_components = lines[i].components(separatedBy: Settings.fileDelimiter)
                let (x, y) = (Int(line_components[1]),Int(line_components[2]))
                let player_id = Int(line_components[3])
                if x == nil || y == nil || player_id == nil{
                    createGamePieces()
                    return
                }
                let line_player = player_id == 1 ? _player1 : _player2
                let origin = Point(x!, y!)
                var piece : ChessPiece?
                if line_components[0] == Queen().name{
                    piece = Queen(origin: origin, movement: QueenMovement(), player: line_player)
                }else if line_components[0] == King().name{
                    piece = King(origin: origin, movement: KingMovement(), player: line_player)
                }else if line_components[0] == Bishop().name{
                    piece = Bishop(origin: origin, movement: BishopMovement(), player: line_player)
                }else if line_components[0] == Knight().name{
                    piece = Knight(origin: origin, movement: KnightMovement(), player: line_player)
                }else if line_components[0] == Rook().name{
                    piece = Rook(origin: origin, movement: RookMovement(), player: line_player)
                }else if line_components[0] == Pawn().name{
                    let p1_move = PawnMovement()
                    p1_move.setUpDown(up: 2, down: 0)
                    let p2_move = PawnMovement()
                    p2_move.setUpDown(up: 0, down: 2)
                    piece = Pawn(origin: origin, movement: line_player.id == 1 ? p1_move : p2_move, player: line_player)
                }
                if let thisPiece = piece{
                    addPiece(piece: thisPiece)
                }else{
                    //handle error
                    createGamePieces()
                    return
                }
            }
        }catch{
            print("File does not exist, starting new game")
            clearAndSaveGame()
        }
    }
    
    private func saveGame(){
        //queen, king, bishop, knight, rook, pawn
        var wholeFile = ""
        wholeFile += "\(_player1.name),\(Stats.player1Elapsed),\(0)\n"
        wholeFile += "\(_player2.name),\(Stats.player2Elapsed),\(self._player2 is Computer ? 1 : 0)\n"
        for piecePair in self.board.pieces{
            wholeFile += (piecePair.value.name + Settings.fileDelimiter)
            wholeFile += "\(piecePair.value.origin.x)" + Settings.fileDelimiter
            wholeFile += "\(piecePair.value.origin.y)" + Settings.fileDelimiter
            wholeFile += "\(piecePair.value.player.id)" + "\n"
        }
        do{
            try wholeFile.write(toFile: Settings.gameFilePath, atomically: true, encoding: String.Encoding.utf8)
        }catch{
            print("Something went wrong")
        }
        //print(wholeFile)
    }
    
    private func switchTurns(){
        self.currentTurn = (self.currentTurn == _player1) ? _player2 : _player1
        self.saveGame()
        gameDelegate?.didSwitchTurn(player: currentPlayer)
        
        if _player2 is Computer && currentTurn == _player2{
            executeAITurn(player: _player2)
        }
    }
    
    func pieceExists(piece : ChessPiece) -> Bool{
        return self.board.pieceAt(x: piece.x, y: piece.y) == piece
    }
    
    private func switchTurns(moved : ChessPiece, oldPosition : Point, pieceRemoved : ChessPiece?){
        
        if gameOver { return }
        
        if let _ = (currentTurn == _player1) ? player1Check : player2Check{
            let king     = (currentTurn == _player1) ? firstPlayerKing : secondPlayerKing
            playerInCheck(p: currentTurn, moved: moved, oldPosition: oldPosition, consumedPiece: pieceRemoved)
            
            if verifyCheckMate(p: currentTurn, attacked: king){
                self.gameOver = true
            }
            
            if pieceRemoved != nil{
                board.addPiece(piece: pieceRemoved!)
            }
            return
        }else if remainingPiecesDraw() {//move has been completed, check for a draw
            gameOver = true
        }
        self.switchTurns()
    }
    
    private func pieceDeselected(){
        gameDelegate?.pieceDeselected()
    }
    
    private func pieceSelected(piece : ChessPiece){
        piece.setMoves(moves: allowedMovementLocations(piece: piece, beyondPieces: false))
        gameDelegate?.pieceSelected(piece: piece)
    }
    
    private func pieceRemoved(piece : ChessPiece){
        /*
        if piece.player == _player1{
            player1removed.append(piece)
        }else if piece.player == _player2{
            player2removed.append(piece)
        }
         */
    }
    
    func setPlayerNames(p1 : String, p2 : String){
        self._player1.name = p1
        self._player2.name = p2
    }
    
    func createMove(_ piece : ChessPiece, _ previousLocation : Point, _ newLocation : Point, _ consumedPiece : ChessPiece?) -> Move{
        return Move(piece: piece, previousLocation: previousLocation, newLocation: newLocation, consumedPiece: consumedPiece)
    }
    
    private func executeMove(move : Move){
        self.pendingMove = move
        if let to_capture = move.consumedPiece{
            if pieceCanEat(piece: move.piece, other: to_capture){
                self.board.removePiece(piece: to_capture)
                move.piece.origin = Point(to_capture.x, to_capture.y)
                pieceRemoved(piece: to_capture)
            }else {
                print("\(move.piece) cannot eat \(to_capture)")
                return
            }
        }
        move.piece.origin = move.newLocation
        self.gameDelegate?.pieceMoved(piece: move.piece)
    }
    
    private func changePiecePosition(piece: ChessPiece, newPosition : Point) -> Bool{
        
        if pendingMove != nil || gameOver || piece.player != currentPlayer{
            return false
        }
        let oldPosition = piece.origin
        if self.canChangePiecePosition(piece: piece, newPosition: newPosition){
            executeMove(move: createMove(piece, oldPosition, newPosition, nil))
            return true
        }
        return false
    }
    
    private func addPiece(piece : ChessPiece){
        
        if let king = piece as? King{
            if piece.player.id == 1{
                player1King = king
            }else{
                player2King = king
            }
        }
        
        self.board.addPiece(piece: piece)
    }
    
    private func removeAllPieces(){
        for element in self.board.pieces{
            self.board.removePiece(piece: element.value)
        }
    }
    
    private func consumePiece(piece1 : ChessPiece, piece2 : ChessPiece) -> Bool{
        if piece1.player == piece2.player || currentPlayer != piece1.player || pendingMove != nil{
            return false
        }
        let oldPosition = piece1.origin
        self.executeMove(move: createMove(piece1, oldPosition, piece2.origin, piece2))
        return true
    }
    
    //MARK: Game initialization code

    private func createGamePieces(){
        self.removeAllPieces()
        self.initPawns()
        self.initRooks()
        self.initKnights()
        self.initBishops()
        self.initKings()
        self.initQueens()
    }
    
    private func start()
    {
        gameDelegate?.gameStarted()
        if currentPlayer.id == 2{
            self.switchTurns()
        }
    }
    
    func startGame(clear : Bool){
        self.gameOver = false
        loadGame(clear: clear)
        start()
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
        addPiece(piece: King(origin: Point(3,0), movement: KingMovement(), player: secondPlayer))
        addPiece(piece: King(origin: Point(3,7), movement: KingMovement(), player: firstPlayer))
    }
    
    private func initQueens(){
        addPiece(piece: Queen(origin: Point(4,0), movement: QueenMovement(), player: secondPlayer))
        addPiece(piece: Queen(origin: Point(4,7), movement: QueenMovement(), player: firstPlayer))
    }

    internal func moveRequested(newLocation: (x: Float, y: Float)) -> Bool{
        if selected == nil{
            return false
        }
        
        let x = Int(newLocation.x)
        let y = Int(newLocation.y)
        //let x_diff = newLocation.x - Float(Int(newLocation.x))
        //let y_diff = newLocation.y - Float(Int(newLocation.y))
        //DispatchQueue.main.async {
            let increments : [(x : Int, y : Int)] = [(0,0), (0, 1), (0, -1), (1, 0), (-1, 0)]
            //let conditions : [Bool] = [true, (y_diff >= 0.9), (y_diff <= 0.1), (x_diff >= 0.9), (x_diff <= 0.1)]
            for i in 0..<increments.count{
                let current : (x : Int, y : Int) = (x + increments[i].x, y + increments[i].y)
                if self.changePiecePosition(piece: self.selected!, newPosition: Point(current.x, current.y)){
                    return true
                }
            }
        //}

        return false
        /*
        
        let rounded : (x : Int, y : Int) = (Int(roundf(newLocation.x)), Int(roundf(newLocation.y)))
        DispatchQueue.main.async {
            let _ = self.changePiecePosition(piece: self.selected!, newPosition: Point(Int(newLocation.x), Int(rounded.y)))
            //let _ = self.changePiecePosition(piece: self.selected!, newPosition: Point(rounded.x, rounded.y))
        }
 
         */
        
        
        
        //self.changePiecePosition(piece: self.selected!, newPosition: Point(Int(newLocation.x), Int(newLocation.y)))
    }
    
    internal func pieceDropped(piece: ChessPiece, newLocation : Point) -> Bool{
        //check if there is a piece in the same location
        if let targetedPiece = self.board.pieceAt(x: newLocation.x, y: newLocation.y){
            if targetedPiece.player != piece.player && piece.Moves.contains(targetedPiece.origin){
                let _ = self.consumePiece(piece1: piece, piece2: targetedPiece)
                return true
            }else{
                return false
            }
        }
        
        return self.changePiecePosition(piece: piece, newPosition: newLocation)
    }
    
    internal func pieceTapped(piece: ChessPiece) -> [Point]{
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
    
    private func remainingPiecesDraw() -> Bool{
        
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
    
    private func pieceCanEat(piece : ChessPiece, other : ChessPiece) -> Bool{
        
        if piece.player == other.player{
            return false
        }
        
        let allowed  = allowedMovementLocations(piece: piece, beyondPieces: false).contains(where: { (p : Point) in
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
    
    private func canEscapeAll(piece : ChessPiece) -> Bool{
        //get all the opposing pieces
        let opposing = self.board.pieces.filter({
            (key : String, value : ChessPiece) in
            return value.player.id == (piece.player.id == 1 ? 2 : 1)
        })
        
        var locations = Set(allowedMovementLocations(piece: piece, beyondPieces: false))
        
        for piecePair in opposing{
            let allowed_moves = Set(allowedMovementLocations(piece: piecePair.value, beyondPieces: true))
            locations.subtract(allowed_moves)
            if locations.isEmpty{
                return false
            }
        }
        
        return !locations.isEmpty
    }
    
    private func canEscape(piece : ChessPiece, other : ChessPiece) -> Bool{
        let piece1Locations = Set(allowedMovementLocations(piece: piece, beyondPieces: true))
        let piece2Locations = Set(allowedMovementLocations(piece: other, beyondPieces: true))
        let subtraction = piece1Locations.subtracting(piece2Locations)
        return !subtraction.isEmpty
    }
    
    private func pieceCanBeBlockedFromAttackingPiece(attacker : ChessPiece, attacked : ChessPiece) -> ChessPiece?{
        
        let attackLocations = Set(allowedMovementLocations(piece: attacker, beyondPieces: false))
        
        for (_, piece) in self.board.pieces{
            if piece.player == attacked.player && piece.origin.x != attacked.origin.x && piece.origin.y != attacked.origin.y{
                let pieceLocations = Set(allowedMovementLocations(piece: piece, beyondPieces: false))
                if !attackLocations.intersection(pieceLocations).isEmpty{
                    return piece
                }
            }
        }
        
        return nil
    }
    
    private func allowedMovementLocations(piece : ChessPiece, beyondPieces : Bool) -> [Point]{
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
                    if !beyondPieces{
                        break
                    }
                }
            }
        }
        
        /*Special cases*/
        
        /*
                   ___
                    |
                 |  |  |
                 |--k--|
                 |  |  |
                    |
                    |
                   ---
 
        */
        
        if piece is Knight{
            let knight_increments : [(x : Int, y : Int)] = [(-1,-2), (-1,2), (1,2), (1,-2), (2,-1), (2,1), (-2,-1), (-2,1)]
            for inc in knight_increments{
                let location = Point(piece.x + inc.x, piece.y + inc.y)
                if location.x >= 0 && location.x < 8 && location.y >= 0 && location.y < 8{
                    if let obstructingPiece = self.board.pieceAt(x: location.x, y: location.y){
                        if obstructingPiece.player.id != piece.player.id{
                            locations.append(location)
                        }
                    }else{
                        locations.append(location)
                    }
                }
            }
        }else if piece is Pawn{
            let (x, y) = (piece.origin.x, piece.origin.y)
            let possiblePoints = [Point(x - 1, y-1), Point(x+1, y-1), Point(x-1, y+1), Point(x+1, y+1)]
            let startIndex = piece.player.id == 1 ? 0 : 2
            for i in startIndex..<possiblePoints.count{
                /*is this a valid location and is there an opposing piece*/
                let location = possiblePoints[i]
                if inRange(x: location.x, lo: 0, hi: 7) &&
                    inRange(x: location.y, lo: 0, hi: 7) {
                    if let diagonalPiece = self.board.pieceAt(x: location.x, y: location.y) {
                        if diagonalPiece.player.id != piece.player.id{
                            locations.append(location)
                        }
                    }
                }
            }
        }
        
        return locations
    }
    
    private func canChangePiecePosition(piece : ChessPiece, newPosition : Point) -> Bool{
        
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
    
    private func pieceVulnerable(piece : ChessPiece) -> ChessPiece? {
        
        let desired_player = piece.player == _player1 ? _player2 : _player1
        
        for current_piece in self.board.pieces.values{
            if current_piece.player == desired_player{
                let piece_moves = allowedMovementLocations(piece: current_piece, beyondPieces: false)
                if piece_moves.contains(piece.origin){
                    return piece
                }
            }
        }
        
        return nil
    }
    
    func tick(){
        if currentTurn == _player1{
            _stats.player1TimeTicked()
        }else{
            _stats.player2TimeTicked()
        }
    }
    
    /*MARK: AI Functions*/
    
    func MovesForPiece(piece : ChessPiece) -> [Move]{
        var moves = [Move]()
        for location in piece.Moves{
            let capturedPiece = board.pieceAt(x: location.x, y: location.y)
            let currentMove = Move(piece: piece, previousLocation: piece.origin, newLocation: location, consumedPiece: capturedPiece)
            moves.append(currentMove)
        }
        return moves
    }
    
    func GetAllMoves(player : Player) -> [Move]{
        var moves = [Move]()
        
        let player_pieces = board.pieces.flatMap({ $1.player == player ? $1 : nil })
        
        for piece in player_pieces{
            piece.setMoves(moves: allowedMovementLocations(piece: piece, beyondPieces: false))
            moves.append(contentsOf: MovesForPiece(piece: piece))
        }
        
        return moves
    }
    
    /*
     player 1 is the white pieces
     player 2 is the black pieces
     */
    
    func pieceValue(piece : ChessPiece) -> Int{
        if piece is Pawn{
            return 10
        }else if piece is Knight{
            return 30
        }else if piece is Bishop{
            return 30
        }else if piece is Rook{
            return 50
        }else if piece is Queen{
            return 90
        }else if piece is King{
            return 100
        }
        return 0
    }
    
    func executeAITurn(player : Player){
        /*Get all the moves and prioritize the ones that result in a capture*/
        var allMoves = GetAllMoves(player: player).sorted(by: { (m1 : Move, m2 : Move) in
            
            let firstValue = m1.consumedPiece == nil ? 0 : pieceValue(piece: m1.consumedPiece!)
            let secondValue = m2.consumedPiece == nil ? 0 : pieceValue(piece: m2.consumedPiece!)
            
            return m1.consumedPiece != nil && m2.consumedPiece == nil && firstValue > secondValue
        })
    
        while true { /*GET OUT OF CHECK IF NEEDED*/
            if allMoves.isEmpty { /*WE LOST*/
                if verifyCheckMate(p: player, attacked: player2King){
                    gameOver = true
                }
                return
            }
            /*GET A RANDOM MOVE*/
            let random_index = 0
            //let start_count = self.player2Deleted.count
            executeMove(move: allMoves[random_index])
            if player2Check == nil /*&& start_count <= self.player2Deleted.count*/{
                break
            }
            allMoves.remove(at: random_index) /*REMOVE THE MOVE THAT WOULD BRING US TO CHECK*/
            undoPendingMove() /*THE PREVIOUS MOVE GOT US IN CHECK SO IT WAS NO GOOD, UNDO IT*/
        }
        
        self.confirmPendingMove()
    }
}








