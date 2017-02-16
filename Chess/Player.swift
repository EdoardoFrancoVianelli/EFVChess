//
//  Player.swift
//  Chess
//
//  Created by Edoardo Franco Vianelli on 2/8/17.
//  Copyright © 2017 Edoardo Franco Vianelli. All rights reserved.
//

import Foundation

protocol PlayerProtocol{
    func nameDidChange(previousName : String, newName : String)
}

class Player : Equatable, CustomStringConvertible {
    
    var delegate : PlayerProtocol?
    
    private var _name : String
    private var _id : Int
    
    var id : Int{
        return self._id
    }
    
    var description: String{
        return "\(name) : \(id)"
    }
    
    var name : String{
        get {
            return self._name
        }
        set {
            let oldValue = name
            self._name = newValue
            delegate?.nameDidChange(previousName: oldValue, newName: name)
        }
    }
    
    init(name : String, id : Int) {
        self._name = name
        self._id = id
    }
    
    public static func ==(lhs : Player, rhs : Player) -> Bool{
        return lhs.id == rhs.id
    }
}

class Human : Player{
    override init(name : String, id : Int){
        super.init(name: name, id: id)
    }
}

class Computer : Player{
    override init (name : String, id : Int){
        super.init(name: name, id: id)
    }
}








