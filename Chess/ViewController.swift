//
//  ViewController.swift
//  Chess
//
//  Created by Edoardo Franco Vianelli on 1/30/17.
//  Copyright © 2017 Edoardo Franco Vianelli. All rights reserved.
//

import UIKit
import AVFoundation

//wood texture from http://www.psdgraphics.com/file/wood-texture.jpg

class ViewController: UIViewController, GameDelegate, SlidingMenuDelegate, StatusBoxDelegate {

    var player2Kind = PlayerType.Human
    
    var gameOver : Bool = false
    
    var slidingMenu: SlidingMenu?
    var check : Player?
    
    @IBOutlet weak var player2Box: ChessStatusBox!
    @IBOutlet weak var player1Box: ChessStatusBox!
    
    var firstPlayerName : String = ""
    var secondPlayerName : String = ""
    
    @IBOutlet weak var board: UIBoard!
    @IBOutlet weak var statusLabel: UILabel!
    
    var game : Game!
    
    var timer : Timer?
    
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
    
    var audioPlayer : AVAudioPlayer?
    var soundURL : URL?
    
    func getSoundURL() -> URL?{
        let alertSound = URL(fileURLWithPath: Bundle.main.path(forResource: "keyboard_tap", ofType: "mp3")!)
        return alertSound
    }
    
    func playTap(){
        do{
            if soundURL == nil {
                soundURL = getSoundURL()
            }
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL!)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        }catch let error as NSError{
            print(error)
            print("Could not play sound")
        }
    }
    
    func pieceMoved(piece: ChessPiece) {
        if Settings.soundOn {
            playTap()
        }
        if currentPlayer.id == 1{
            player1Box.showMoveApprovalView = true
        }else if currentPlayer is Human{
            player2Box.showMoveApprovalView = true
        }
    }
    
    func switchChangedValue(sender: UISwitch, i: IndexPath) {
        if i.row == 0{
            print("Sound \(sender.isOn ? "on" : "off")")
            Settings.soundOn = sender.isOn
        }else if i.row == 1{
            print("Rotate keyboard \(sender.isOn ? "on" : "off")")
            Settings.rotateKeyboard = sender.isOn
        }else if i.row == 2{
            print("Allowed Moves \(sender.isOn ? "on" : "off")")
            Settings.allowedMoves = sender.isOn
        }else if i.row == 3{
            print("Animations \(sender.isOn ? "on" : "off")")
            Settings.animations = sender.isOn
        }
    }
    
    func selectedIndex(i: IndexPath, content: (text: String, subtitle: String)) {
        if content.text == "New Game"{
            newGame()
        }else if content.text == "Deleted pieces"{
            self.performSegue(withIdentifier: "deletedPiecesSegue", sender: self)
        }else if content.text == "Main Menu"{
            back()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func newGame() {
        let gameStartAlert = UIAlertController(title: "Start new game?", message: "You will lose all progress in the last game", preferredStyle: .alert)
        gameStartAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        gameStartAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
        
            (action : UIAlertAction) in self.game.startGame(clear: true)
        
        }))
        present(gameStartAlert, animated: true, completion: nil)
    }
    
    @IBAction func back() {
        let _ = self.navigationController?.popViewController(animated: true)
    }
    
    var selectedPiece : ChessPiece = ChessPiece(origin: Point(0,0), movement: PawnMovement(), player: Player(name: "", id: 1)){
        didSet{
            let image = pieceImages[selectedPiece.name]!
            if (self.currentPlayer.id == 1 && selectedPiece.player.id == 1){
                player1Box.piece = selectedPiece
                player1Box.image = image!
                player1Box.setWhite()
            }else if (self.currentPlayer.id == 2 && selectedPiece.player.id == 2){
                player2Box.piece = selectedPiece
                player2Box.image = image!
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    func configureSlideMenu(){
        slidingMenu = SlidingMenu(sp: self.view)
        slidingMenu?.addElement(text: "New Game", subtitle: "Start a new game", kind: SlidingMenu.cellIdentifier, section: 0)
        slidingMenu?.addElement(text: "End Game", subtitle: "Quit the current game", kind: SlidingMenu.cellIdentifier, section: 0)
        slidingMenu?.addElement(text: "Deleted pieces", subtitle: "See the game's deleted pieces", kind: SlidingMenu.cellIdentifier, section: 0)
        slidingMenu?.addHeader(name: "Settings")
        slidingMenu?.addSwitch(text: "Sound", section: 1, on: Settings.soundOn)
        slidingMenu?.addSwitch(text: "Keyboard Rotation", section: 1, on: Settings.rotateKeyboard)
        slidingMenu?.addSwitch(text: "Allowed moves", section: 1, on: Settings.allowedMoves)
        slidingMenu?.addSwitch(text: "Animations", section: 1, on: Settings.animations)
        slidingMenu?.addHeader(name: "Other")
        slidingMenu?.addElement(text: "Main Menu", subtitle: "Go back to main menu", kind: SlidingMenu.cellIdentifier, section: 2)
        slidingMenu?.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let player2 = player2Kind == .Human ? Human(name: secondPlayerName, id: 2) : Computer(name: secondPlayerName, id: 2)
        game = Game(p1: Player(name: firstPlayerName, id: 1), p2: player2)
        game.gameDelegate = self
        game.boardDelegate = board
        
        self.configureSlideMenu()
        self.player1Box.delegate = self
        self.player2Box.delegate = self
        self.board.delegate = game
                
        game.startGame(clear: false)
        
        //game.loadTest1()
        
        slidingMenu?.show()
        
        UIView.animate(withDuration: 1, animations: {
            self.slidingMenu?.hide()
        })
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func timeTicked(timer : Timer){
        if gameOver{
            timer.invalidate()
        }
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
        
        if Settings.animations{
            UIView.animate(withDuration: 0.5, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                self.statusLabel.alpha = 0.0
            }, completion: { (completed : Bool) in
                if completed{
                    self.statusLabel.alpha = 1.0
                }
            })
        }
        
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
        
        if Settings.rotateKeyboard{
            self.board.rotate()
        }
    }
    
    func pieceSelected(piece: ChessPiece) {
        self.selectedPiece = piece
    }
    
    func gameStarted() {
        
        timer?.invalidate()
        
        self.statusLabel.text = firstPlayerName + "'s turn"
        self.currentPlayer = Player(name: firstPlayerName, id: 1)
        game.setPlayerNames(p1: firstPlayerName, p2: secondPlayerName)
        
        self.player1Box.resetSeconds()
        self.player2Box.resetSeconds()
        
        timer = Timer(timeInterval: 1.0, repeats: true, block: timeTicked)
        RunLoop.current.add(timer!, forMode: .defaultRunLoopMode)
    }
    
    internal func gameOver(loser: Player) {
        let controller = UIAlertController(title: "GAME OVER", message: loser.description + " lost", preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        present(controller, animated: false, completion: nil)
        self.gameOver = true
    }
    
    func pieceDeselected() {
        //self.selectedPiece = nil
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = (segue.destination as? DeletedPiecesTableViewController){
            dest.first_player = game.firstPlayer
            dest.second_player = game.secondPlayer
            dest.first_pieces = game.player1Deleted
            dest.second_pieces = game.player2Deleted
        }
    }
    
    //MARK: Status Box Delegate
    
    func cancelActionFired() {
        game.undoPendingMove()
    }
    
    func confirmActionFired() {
        game.confirmPendingMove()
    }
}













