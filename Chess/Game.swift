//
//  Game.swift
//  Chess
//
//  Created by Edoardo Franco Vianelli on 2/8/17.
//  Copyright © 2017 Edoardo Franco Vianelli. All rights reserved.
//

import Foundation

protocol GameProtocol {
    func didSwitchTurn(player : Player)
    func pieceSelected(piece : ChessPiece)
    func pieceDeselected()
}

class Game{
    
    private var player1removed = [ChessPiece]()
    private var player2removed = [ChessPiece]()
    
    var player1Deleted : [ChessPiece]{
        return player1removed
    }
    
    var player2Deleted : [ChessPiece]{
        return player2removed
    }
    
    var delegate : GameProtocol?
        
    private var _player1 : Player
    private var _player2 : Player
    
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
    
    func switchTurns(){
        if currentTurn == _player1{
            self.currentTurn = _player2
        }else{
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
}








