//
//  Collection_ViewController.swift
//  Imgae gallery ver1
//
//  Created by 周熙岩 on 2018/11/22.
//  Copyright © 2018 DoDo. All rights reserved.
//

import UIKit

class Collection_ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    

    @IBOutlet weak var collection: UICollectionView!{
        didSet{
            collection.dataSource = self
            collection.delegate = self
        }
    }
    //临时
    let pciDic = [ "twogirls", "Megumi", "onion"]
    //有多少个cell
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    //cell高度
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        print("size"+String(indexPath.item))
        
        let width = collectionView.contentSize.width
        let cgfloarImageHeight = UIImage(named: self.pciDic[indexPath.item])?.size.height
        let cgfloarImageWidth = UIImage(named: self.pciDic[indexPath.item])?.size.width
        let floatImageHeight = Float(cgfloarImageHeight!)
        let floatImageWidth = Float(cgfloarImageWidth!)
        print(floatImageHeight)
        print(floatImageWidth)
        let aspectRatio = floatImageHeight/floatImageWidth
        
        return CGSize(width: 0.9*width, height: 0.9*CGFloat(Float(width)*aspectRatio))
        
    }
    
    //每个cell怎么搞
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        if let collectCell = cell as? Collection_Cell{
            collectCell.viewInCollectionCell.backgroundImage = UIImage(named: self.pciDic[indexPath.item])
        }
        print("create"+String(indexPath.item))
        return cell
    }
    
   
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
