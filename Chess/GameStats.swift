//
//  GameStats.swift
//  Chess
//
//  Created by Edoardo Franco Vianelli on 6/6/17.
//  Copyright © 2017 Edoardo Franco Vianelli. All rights reserved.
//

import Foundation

class GameStats{
    private var p1_elapsed = 0
    private var p2_elapsed = 0
    private var player1removed = [ChessPiece]()
    private var player2removed = [ChessPiece]()
    
    var player1Elapsed : Int{
        return p1_elapsed
    }
    
    var player2Elapsed : Int{
        return p2_elapsed
    }
    
    func player1TimeTicked(){
        p1_elapsed += 1
    }
    
    func player2TimeTicked(){
        p2_elapsed += 1
    }
    
    init(){
        self.p1_elapsed = 0
        self.p2_elapsed = 0
        self.player1removed = [ChessPiece]()
        self.player2removed = [ChessPiece]()
    }
    
    init(p1Elapsed : Int, p2Elapsed : Int){
        self.p1_elapsed = p1Elapsed
        self.p2_elapsed = p2Elapsed
    }
}
