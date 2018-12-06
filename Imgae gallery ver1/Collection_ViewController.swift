//
//  Collection_ViewController.swift
//  Imgae gallery ver1
//
//  Created by 周熙岩 on 2018/11/22.
//  Copyright © 2018 DoDo. All rights reserved.
//

import UIKit

class Collection_ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDragDelegate, UICollectionViewDropDelegate{
    //执行drop的函数
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        let destinationIndexPath = coordinator.destinationIndexPath ?? IndexPath(item: 0, section: 0)
        for item in coordinator.items{
            //当drop来自内部
            if let itemSourceIndexPath = item.sourceIndexPath{
                if let localphotoStruc = item.dragItem.localObject{
                    collectionView.performBatchUpdates({
                        self.collectionViewModel.remove(at: itemSourceIndexPath.item)
                        self.collectionViewModel.insert(localphotoStruc as! photoStruc, at: destinationIndexPath.item)
                        self.collection.deleteItems(at: [itemSourceIndexPath])
                        self.collection.insertItems(at: [destinationIndexPath])
                    })
                    //动画
                    coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
                }
                //当drop来自外部
            }else{
                let placeHolder = coordinator.drop(item.dragItem, to: UICollectionViewDropPlaceholder(insertionIndexPath: destinationIndexPath, reuseIdentifier: "placeHolderCell"))
                
            }
        }
        
    }
    //关于是否接受drop(目前是内部拖拽就只需要uiimage，外部就同时需要image和url)
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        let judge = (session.localDragSession?.localContext as? UICollectionView) == collectionView
        return judge ? session.canLoadObjects(ofClass: UIImage.self) : session.canLoadObjects(ofClass: UIImage.self)&&session.canLoadObjects(ofClass: NSURL.self)
    }
    //关于drop类型(move/copy)
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        let judge = (session.localDragSession?.localContext as? UICollectionView) == collectionView
        return UICollectionViewDropProposal(operation: judge ? .move : .copy, intent: .insertAtDestinationIndexPath)
        
    }
    
    //dragd delegated要求的函数之一：提供beginning的drag item
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        session.localContext = collectionView
        return makeDragItems(indexpath: indexPath)
    }
    
    //提供后续添加的drag item
    func collectionView(_ collectionView: UICollectionView, itmsForAdiingsession: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        return makeDragItems(indexpath: indexPath)
    }
    //查找cell并转化为drag item，来提供给delegate
    //todo:待修改，也许需要同时给一个url
    func makeDragItems(indexpath: IndexPath) -> [UIDragItem]{
        if let image = (self.collection.cellForItem(at: indexpath) as? Collection_Cell)?.viewInCollectionCell.backgroundImage{
            let dragItem = UIDragItem(itemProvider: NSItemProvider(object: image))
            //local data
            dragItem.localObject = self.collectionViewModel[indexpath.item]
            return [dragItem]
        }else{
            return []
        }
    }
    
    

    @IBOutlet weak var collection: UICollectionView!{
        didSet{
            collection.dataSource = self
            collection.delegate = self
            collection.dragDelegate = self
            collection.dropDelegate = self
        }
    }
    //model的结构
    struct photoStruc {
        var name:String?
        var url:URL?
        var aspecRatio:Float
    }
    //collection view的model
    var collectionViewModel = [photoStruc(name: "twogirls", url: nil, aspecRatio: 1202/1700), photoStruc(name: "Megumi", url: nil, aspecRatio: 1932/1266),photoStruc(name: "onion", url: nil, aspecRatio: 2396/1920)]
    //有多少个cell
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    //cell的显示倍数
    var scale = CGFloat(0.5)
    //cell大小
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.contentSize.width
        let aspectRatio = self.collectionViewModel[indexPath.item].aspecRatio
        return CGSize(width: self.scale*width, height: self.scale*CGFloat(Float(width)*aspectRatio))
        
    }
    
    //每个cell怎么搞
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        if let collectCell = cell as? Collection_Cell{
            //当是默认图片的时候(?)
            if let picname = self.collectionViewModel[indexPath.item].name{
                collectCell.viewInCollectionCell.backgroundImage = UIImage(named: picname)
            }
            
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
