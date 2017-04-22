//
//  Settings.swift
//  Chess
//
//  Created by Edoardo Franco Vianelli on 4/16/17.
//  Copyright © 2017 Edoardo Franco Vianelli. All rights reserved.
//

import Foundation

let soundKey = "SoundOn"
let rotateKeyboardKey = "rotate"

class Settings
{
    static var soundOn : Bool {
        get{
            if (UserDefaults.standard.object(forKey: soundKey) != nil){
                return UserDefaults.standard.bool(forKey: soundKey)
            }else{
                return true
            }
        }
        set{
            UserDefaults.standard.set(newValue, forKey: soundKey)
        }
    }
    
    static var rotateKeyboard : Bool{
        get{
            if (UserDefaults.standard.object(forKey: rotateKeyboardKey) != nil){
                return UserDefaults.standard.bool(forKey: rotateKeyboardKey)
            }else{
                return true
            }
        }set{
            UserDefaults.standard.set(newValue, forKey: rotateKeyboardKey)
        }
    }
}
