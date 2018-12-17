//
//  MyTableViewController.swift
//  Imgae gallery ver1
//
//  Created by 周熙岩 on 2018/12/12.
//  Copyright © 2018 DoDo. All rights reserved.
//

import UIKit

class MyTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.galleries.updateValue((splitViewController?.viewControllers[1])!, forKey: 1)
        

    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0{
            return self.regularTableModel.count
        }else{
            return self.deletedTableModel.count
        }
    }
    @IBAction func addButton(_ sender: Any) {
        self.regularTableModel += ["untitled"]
        tableView.reloadData()
    }
    
    var regularTableModel = ["one", "two", "three"]
    
    var deletedTableModel = ["one", "two", "three"]

    var tableCellSerialNumber = 0
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var identifier = ""
        if indexPath.section == 0{
            identifier = "regularCell"
        }else{
            identifier = "deletedCell"
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        if indexPath.section == 0{
            //隐藏textField
            (cell as! CustomTableViewCell).textView.isHidden = true
            cell.textLabel?.text = self.regularTableModel[indexPath.row]
            //双击手势
            let doubleTap = UITapGestureRecognizer(target: self, action: #selector(enableEditting))
            doubleTap.numberOfTapsRequired = 2
            cell.addGestureRecognizer(doubleTap)
            //单击手势
            let singleTap = UITapGestureRecognizer(target: self, action: #selector(segueWayToGallery))
            singleTap.numberOfTapsRequired = 1
            cell.addGestureRecognizer(singleTap)
            //单击双击共存
            singleTap.require(toFail: doubleTap)
            //识别号
            self.tableCellSerialNumber += 1
            
            (cell as! CustomTableViewCell).serialNumber = tableCellSerialNumber
            print(tableCellSerialNumber)
        }else{
            cell.textLabel?.text = self.deletedTableModel[indexPath.row]
        }
        
        
        return cell
    }
    //双击后触发
    @objc func enableEditting(sender:UITapGestureRecognizer){
        let sender = sender.view as! CustomTableViewCell
        let tmpText = sender.textLabel?.text
        sender.textLabel?.text = ""
        sender.textView.isHidden = false
        sender.textView.text = tmpText
        sender.textView.becomeFirstResponder()
    }
    //单击后触发
    @objc func segueWayToGallery(sender:UITapGestureRecognizer){
        if let destination = self.galleries[(sender.view as! CustomTableViewCell).serialNumber!]{
            splitViewController?.showDetailViewController(destination, sender: sender)
        }else{
            performSegue(withIdentifier:"segueToGallery", sender: sender)
        }
    }
    //header内容
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Galleries"
        default:
            return "Deleted galleries"
        }
    }
    
    
    //gallery的segue页面
    var galleries:[Int:UIViewController] = [:]
    
    //准备seuge gallery页面 identifier:segueToGallery
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            let senderCellSerialNumber = ((sender as! UIGestureRecognizer).view as! CustomTableViewCell).serialNumber
        self.galleries.updateValue(segue.destination, forKey: senderCellSerialNumber!)
        
    }
 

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    
    // Override to support editing the table view.
    //table编辑和删除
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            switch indexPath.section{
                case 0:
                    tableView.deselectRow(at: indexPath, animated: true)
                    self.regularTableModel.remove(at: indexPath.row)
                default:
                    tableView.deselectRow(at: indexPath, animated: true)
                    self.deletedTableModel.remove(at: indexPath.row)
            }
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
 

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
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}