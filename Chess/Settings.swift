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
let movesAllowed = "allowedMoves"
let animationsEnabled = "animations"

class Settings
{
    static func getSettingWithName(name : String) -> Any?{
        if (UserDefaults.standard.object(forKey: name) != nil){
            return UserDefaults.standard.object(forKey: name)
        }else{
            return nil
        }
    }
    
    static var allowedMoves : Bool{
        get{
            if let setting = getSettingWithName(name: movesAllowed) as? Bool{
                return setting
            }
            return true
        }set{
            UserDefaults.standard.set(newValue, forKey: movesAllowed)
        }
    }
    
    static var animations : Bool{
        get{
            if let setting = getSettingWithName(name: animationsEnabled) as? Bool{
                return setting
            }
            return true
        }set{
            UserDefaults.standard.set(newValue, forKey: animationsEnabled)
        }
    }
    
    static var soundOn : Bool {
        get{
            if let setting = getSettingWithName(name: soundKey) as? Bool{
                return setting
            }
            return true
        }
        set{
            UserDefaults.standard.set(newValue, forKey: soundKey)
        }
    }
    
    static var rotateKeyboard : Bool{
        get{
            if let setting = getSettingWithName(name: rotateKeyboardKey) as? Bool{
                return setting
            }
            return true
        }set{
            UserDefaults.standard.set(newValue, forKey: rotateKeyboardKey)
        }
    }
}
