//
//  CustomTableViewCell.swift
//  Imgae gallery ver1
//
//  Created by 周熙岩 on 2018/12/13.
//  Copyright © 2018 DoDo. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell, UITextFieldDelegate {
    
    var serialNumber:Int?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    @IBOutlet weak var textView: UITextField!{
        didSet{
            self.textView.delegate = self
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.textLabel?.text =  self.textView.text
        self.textView.resignFirstResponder()
        self.textView.isHidden = true
        
        return true
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
