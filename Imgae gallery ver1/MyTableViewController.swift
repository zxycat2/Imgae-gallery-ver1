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
        self.updateModel()
        self.regularTableModel += ["untitled"]
        tableView.reloadData()
    }
    //更新Model的函数
    func updateModel() {
        for index in 0...self.regularTableModel.count-1{
            if self.tableView.cellForRow(at: [0,index])?.textLabel!.text != self.regularTableModel[index]{
                self.regularTableModel[index] = (self.tableView.cellForRow(at: [0,index])?.textLabel!.text)!
            }
        }
    }
    
    var regularTableModel = ["one", "two", "three"]
    
    var deletedTableModel = ["D-one", "D-two", "D-three"]

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
            
            if (cell as! CustomTableViewCell).serialNumber == nil{
                //识别号
                self.tableCellSerialNumber += 1
                
                (cell as! CustomTableViewCell).serialNumber = tableCellSerialNumber
                print(tableCellSerialNumber)
            }
        }else{
            cell.textLabel?.text = self.deletedTableModel[indexPath.row]
        }
        
        print(indexPath)
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

    //反向滑动取消删除
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        self.updateModel()
        if indexPath.section == 1{
            return UISwipeActionsConfiguration(actions: [UIContextualAction(style: .normal, title: "我后悔了", handler: {_,_,_ in
                DispatchQueue.main.async {
                    let cellSerialNumber = (tableView.cellForRow(at: indexPath) as! DeletedTableViewCell).serialNumber
                    let cellName = self.deletedTableModel.remove(at: indexPath.row)
                    self.tableView.deleteRows(at: [indexPath], with: .fade)
                    
                   
                    
                    self.regularTableModel.append(cellName)
                    self.tableView.insertRows(at: [[0,self.regularTableModel.count-1]], with: .automatic)
                    
                    (self.tableView.cellForRow(at: [0,self.regularTableModel.count-1]) as! CustomTableViewCell).serialNumber = cellSerialNumber
                }
            })])
        }else{
            return nil
        }
    }
    // Override to support editing the table view.
    //table编辑和删除
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            switch indexPath.section{
                case 0:
                    DispatchQueue.main.async {
                        let cellSerialNumber = (tableView.cellForRow(at: indexPath) as! CustomTableViewCell).serialNumber
                        let cellName = self.regularTableModel.remove(at: indexPath.row)
                        self.tableView.deleteRows(at: [indexPath], with: .fade)
                        
                        print("yeah")
                        
                        self.deletedTableModel.append(cellName)
                        self.tableView.insertRows(at: [[1,self.deletedTableModel.count-1]], with: .automatic)

                        (self.tableView.cellForRow(at: [1,self.deletedTableModel.count-1]) as! DeletedTableViewCell).serialNumber = cellSerialNumber
                    }
                default:
                    self.galleries.removeValue(forKey: (self.tableView.cellForRow(at: indexPath) as! CustomTableViewCell).serialNumber!)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                    self.deletedTableModel.remove(at: indexPath.row)
            }
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
