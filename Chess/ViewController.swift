//
//  ViewController.swift
//  Chess
//
//  Created by Edoardo Franco Vianelli on 1/30/17.
//  Copyright © 2017 Edoardo Franco Vianelli. All rights reserved.
//

import UIKit

class ViewController: UIViewController, GameProtocol {

    var firstPlayerName : String = ""
    var secondPlayerName : String = ""
    
    @IBOutlet weak var board: UIBoard!
    @IBOutlet weak var statusLabel: UILabel!
    
    var currentPlayer = Player(name: "Player 1", id: 1){
        didSet{
            setStatusLabel()
        }
    }
    
    var selectedPiece : ChessPiece? = ChessPiece(x: 0, y: 0, movement: PawnMovement(), player: Player(name: "", id: 1)){
        didSet{
            setStatusLabel()
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

    func setStatusLabel(){
        statusLabel.text = currentPlayer.name + "'s turn\n"
        if let select = selectedPiece{
            statusLabel.text! += select.name + "\(select.origin)"
        }
    }
    
    func didSwitchTurn(player: Player) {
        self.currentPlayer = player
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













