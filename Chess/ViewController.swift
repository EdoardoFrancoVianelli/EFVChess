//
//  ViewController.swift
//  Chess
//
//  Created by Edoardo Franco Vianelli on 1/30/17.
//  Copyright © 2017 Edoardo Franco Vianelli. All rights reserved.
//

import UIKit

//wood texture from http://www.psdgraphics.com/file/wood-texture.jpg

class ViewController: UIViewController, GameProtocol {

    @IBOutlet weak var player2Box: ChessStatusBox!
    @IBOutlet weak var player1Box: ChessStatusBox!
    
    var firstTimer = Timer()
    var secondTimer = Timer()
    
    var firstPlayerName : String = ""
    var secondPlayerName : String = ""
    
    @IBOutlet weak var board: UIBoard!
    @IBOutlet weak var statusLabel: UILabel!
    
    var currentPlayer = Player(name: "Player 1", id: 1){
        didSet{
        }
    }
    
    var selectedPiece : ChessPiece? = ChessPiece(x: 0, y: 0, movement: PawnMovement(), player: Player(name: "", id: 1)){
        didSet{
            if (self.currentPlayer.id == 1 && selectedPiece?.player.id == 1){
                player1Box.image = imageForPiece(piece: selectedPiece!)!
                player1Box.setWhite()
            }else if (self.currentPlayer.id == 2 && selectedPiece?.player.id == 2){
                player2Box.image = imageForPiece(piece: selectedPiece!)!
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.board.game.delegate = self
        self.currentPlayer = Player(name: firstPlayerName, id: 1)
        self.board.game.setPlayerNames(p1: firstPlayerName, p2: secondPlayerName)
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func didSwitchTurn(player: Player) {
        self.currentPlayer = player
        player1Box.timerPaused = self.currentPlayer.id != 1
        player2Box.timerPaused = !player1Box.timerPaused
    }
    
    func pieceSelected(piece: ChessPiece) {
        self.selectedPiece = piece
    }
    
    func pieceDeselected() {
        self.selectedPiece = nil
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = (segue.destination as? DeletedPiecesTableViewController){
            dest.first_player = board.game.firstPlayer
            dest.second_player = board.game.secondPlayer
            dest.first_pieces = board.game.player1Deleted
            dest.second_pieces = board.game.player2Deleted
        }
    }
}













