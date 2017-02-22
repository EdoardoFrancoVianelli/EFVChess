//
//  PlayerOptionsViewController.swift
//  Chess
//
//  Created by Edoardo Franco Vianelli on 2/14/17.
//  Copyright © 2017 Edoardo Franco Vianelli. All rights reserved.
//

import UIKit

class PlayerOptionsViewController: UIViewController {

    @IBOutlet weak var player1Box: UITextField!
    @IBOutlet weak var player2Box: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    
        if let dest = (segue.destination as? ViewController){
            dest.firstPlayerName = player1Box.text!
            dest.secondPlayerName = player2Box.text!
        }
    }
    

}
