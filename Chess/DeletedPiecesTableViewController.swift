//
//  DeletedPiecesTableViewController.swift
//  Chess
//
//  Created by Edoardo Franco Vianelli on 2/10/17.
//  Copyright © 2017 Edoardo Franco Vianelli. All rights reserved.
//

import UIKit

class DeletedPiecesTableViewController: UITableViewController {

    var first_pieces = [ChessPiece]()
    var second_pieces = [ChessPiece]()
    
    var first_player = Player(name: "", id: 1)
    var second_player = Player(name: "", id: 2)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0{
            return first_player.name
        }
        return second_player.name
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if (first_pieces.count == 0 && second_pieces.count == 0){
            return 0
        }
        
        if (first_pieces.count == 0){
            return 1
        }
        if (second_pieces.count == 0){
            return 1
        }
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0{
            return first_pieces.count
        }else{
            return second_pieces.count
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "deletedPieceId", for: indexPath)

        let piece = (indexPath.section == 0) ? first_pieces[indexPath.row] : second_pieces[indexPath.row]
        
        cell.textLabel?.text = piece.name
        cell.detailTextLabel?.text = piece.player.name
        
        if (piece is Pawn){
            cell.imageView?.image = UIImage(named: "chess-pawn.png")
        }else if (piece is Queen){
            cell.imageView?.image = UIImage(named: "chess-queen.png")
        }else if (piece is Rook){
            cell.imageView?.image = UIImage(named: "chess-rok.png")
        }else if (piece is Knight){
            cell.imageView?.image = UIImage(named: "chess-knight.png")
        }else if (piece is King){
            cell.imageView?.image = UIImage(named: "chess-king.png")
        }else{
            cell.imageView?.image = UIImage(named: "bishop.png")
        }
    
        // Configure the cell...

        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
