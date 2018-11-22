//
//  ViewInCollectionCell.swift
//  Imgae gallery ver1
//
//  Created by 周熙岩 on 2018/11/22.
//  Copyright © 2018 DoDo. All rights reserved.
//

import UIKit

class ViewInCollectionCell: UIView {
    
    //从lecture黏贴的，*需要更改*
    var backgroundImage: UIImage? { didSet { setNeedsDisplay() } }
    
    override func draw(_ rect: CGRect) {
        backgroundImage?.draw(in: bounds)
    }

}
