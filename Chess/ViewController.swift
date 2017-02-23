//
//  ViewController.swift
//  Chess
//
//  Created by Edoardo Franco Vianelli on 1/30/17.
//  Copyright © 2017 Edoardo Franco Vianelli. All rights reserved.
//

import UIKit

//wood texture from http://www.psdgraphics.com/file/wood-texture.jpg

class ViewController: UIViewController, GameDelegate {

    var check : Player?
    
    @IBOutlet weak var player2Box: ChessStatusBox!
    @IBOutlet weak var player1Box: ChessStatusBox!
    
    var firstTimer = Timer()
    var secondTimer = Timer()
    
    var firstPlayerName : String = ""
    var secondPlayerName : String = ""
    
    @IBOutlet weak var board: UIBoard!
    @IBOutlet weak var statusLabel: UILabel!
    
    func updateStatusLabel(){
        statusLabel.text = "\(currentPlayer.name)'s turn"
    }
    
    var currentPlayer = Player(name: "Player 1", id: 1){
        didSet{
            updateStatusLabel()
            if currentPlayer.id == 1{
                statusLabel.textAlignment = .left
            }else{
                statusLabel.textAlignment = .right
            }
            player1Box.glow = currentPlayer.id == 1
            player2Box.glow = currentPlayer.id == 2
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    @IBAction func newGame() {
        board.startGame()
    }
    
    @IBAction func back() {
        let _ = self.navigationController?.popViewController(animated: true)
    }
    
    var selectedPiece : ChessPiece = ChessPiece(x: 0, y: 0, movement: PawnMovement(), player: Player(name: "", id: 1)){
        didSet{
            if (self.currentPlayer.id == 1 && selectedPiece.player.id == 1){
                player1Box.piece = selectedPiece
                player1Box.image = imageForPiece(piece: selectedPiece)!
                player1Box.setWhite()
            }else if (self.currentPlayer.id == 2 && selectedPiece.player.id == 2){
                player2Box.piece = selectedPiece
                player2Box.image = imageForPiece(piece: selectedPiece)!
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.board.game.delegate = self
        self.currentPlayer = Player(name: firstPlayerName, id: 1)
        self.board.game.setPlayerNames(p1: firstPlayerName, p2: secondPlayerName)
        let timer = Timer(timeInterval: 1.0, repeats: true, block: timeTicked)
        RunLoop.current.add(timer, forMode: .defaultRunLoopMode)
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func timeTicked(timer : Timer){
        if currentPlayer.id == 1{
            player1Box.secondsPassed += 1
        }else{
            player2Box.secondsPassed += 1
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    internal func playerInCheck(player: Player) {
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            
            self.statusLabel.alpha = 0.0
            
        }, completion: { (completed : Bool) in
            if completed{
                self.statusLabel.alpha = 1.0
            }
        })
        
        statusLabel.text = "\(currentPlayer.name)'s turn"
        self.statusLabel.text?.append(" -> in Check!")
    }
    
    func didSwitchTurn(player: Player) {
        if let chk = check{
            if chk != player{
                check = nil
            }else{
                self.statusLabel.text?.append(" -> in Check!")
            }
        }
        self.currentPlayer = player
    }
    
    func pieceSelected(piece: ChessPiece) {
        self.selectedPiece = piece
    }
    
    func pieceDeselected() {
        //self.selectedPiece = nil
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













