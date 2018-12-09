//
//  Collection_ViewController.swift
//  Imgae gallery ver1
//
//  Created by 周熙岩 on 2018/11/22.
//  Copyright © 2018 DoDo. All rights reserved.
//

import UIKit

extension URL {
    var imageURL: URL {
        if let url = UIImage.urlToStoreLocallyAsJPEG(named: self.path) {
            // this was created using UIImage.storeLocallyAsJPEG
            return url
        } else {
            // check to see if there is an embedded imgurl reference
            for query in query?.components(separatedBy: "&") ?? [] {
                let queryComponents = query.components(separatedBy: "=")
                if queryComponents.count == 2 {
                    if queryComponents[0] == "imgurl", let url = URL(string: queryComponents[1].removingPercentEncoding ?? "") {
                        return url
                    }
                }
            }
            return self.baseURL ?? self
        }
    }
}
extension UIImage
{
    private static let localImagesDirectory = "UIImage.storeLocallyAsJPEG"
    
    static func urlToStoreLocallyAsJPEG(named: String) -> URL? {
        var name = named
        let pathComponents = named.components(separatedBy: "/")
        if pathComponents.count > 1 {
            if pathComponents[pathComponents.count-2] == localImagesDirectory {
                name = pathComponents.last!
            } else {
                return nil
            }
        }
        if var url = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
            url = url.appendingPathComponent(localImagesDirectory)
            do {
                try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
                url = url.appendingPathComponent(name)
                if url.pathExtension != "jpg" {
                    url = url.appendingPathExtension("jpg")
                }
                return url
            } catch let error {
                print("UIImage.urlToStoreLocallyAsJPEG \(error)")
            }
        }
        return nil
    }
    
    func storeLocallyAsJPEG(named name: String) -> URL? {
        if let imageData = self.jpegData(compressionQuality: 1.0) {
            if let url = UIImage.urlToStoreLocallyAsJPEG(named: name) {
                do {
                    try imageData.write(to: url)
                    return url
                } catch let error {
                    print("UIImage.storeLocallyAsJPEG \(error)")
                }
            }
        }
        return nil
    }
}
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
                var photoAspectRatio:Float = 1.0
                let placeHolder = coordinator.drop(item.dragItem, to: UICollectionViewDropPlaceholder(insertionIndexPath: destinationIndexPath, reuseIdentifier: "placeHolderCell"))
                //获取图片的长宽比
                item.dragItem.itemProvider.loadObject(ofClass: UIImage.self, completionHandler: {(provider, error) in
                    if let photo = provider as? UIImage{
                        photoAspectRatio = Float(photo.size.height/photo.size.width)
                        
                    }else{
                        print("Can not get the aspeact ratio")
                        placeHolder.deletePlaceholder()
                    }
                })
                // 获取图片url
                item.dragItem.itemProvider.loadObject(ofClass: NSURL.self, completionHandler: {(provider, error) in
                    DispatchQueue.main.async {
                        if var photoURL = provider as? URL{
                            photoURL = photoURL.imageURL
                            placeHolder.commitInsertion(dataSourceUpdates: {insertionPath in
                                self.collectionViewModel.insert(photoStruc(name: nil, url: photoURL, aspecRatio: photoAspectRatio), at: insertionPath.item)
                            })
                        }else{
                            print("Can not get the URL")
                            placeHolder.deletePlaceholder()
                        }
                    }
                })
                
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
    //查找cell并转化为drag item，来提供给delegate（本地drag）
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
    
    
    //初始化collection
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
        return self.collectionViewModel.count
    }
    
    //cell的显示倍数
    var scale = CGFloat(0.5)
    //cell大小(宽度统一，高度根据长宽比自动变化)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.contentSize.width
        let aspectRatio = self.collectionViewModel[indexPath.item].aspecRatio
        return CGSize(width: self.scale*width, height: self.scale*CGFloat(Float(width)*aspectRatio))
    }
    //单击cell后执行perform segue
    @objc func performSegueToScrollView(sender: UITapGestureRecognizer){
        performSegue(withIdentifier: "segueToScrollView", sender: sender)
    }
    
    //每个cell怎么搞
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        //单击手势
        let tap = UITapGestureRecognizer(target: self, action:  #selector(performSegueToScrollView))
        cell.addGestureRecognizer(tap)
        if let collectCell = cell as? Collection_Cell{
            //当是默认图片的时候(?)
            if let picname = self.collectionViewModel[indexPath.item].name{
                collectCell.viewInCollectionCell.backgroundImage = UIImage(named: picname)
            }else{
                //当是外部图片，靠url拿图片
                let imageData = try? Data(contentsOf: self.collectionViewModel[indexPath.item].url!)
                if (imageData != nil){
                    collectCell.viewInCollectionCell.backgroundImage = UIImage(data: imageData!)
                }else{
                    print("cant get the image using URL")
                }
            }
            
        }
        print("create"+String(indexPath.item))
        return cell
    }
    
   
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    //准备scrollView的segue way页面
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("!!")
        if let point = (sender as? UITapGestureRecognizer)?.location(in: self.collection){
            let index = self.collection.indexPathForItem(at: point)?.item
            print(index!)
            let scrollView = segue.destination as! PhotoScroll_ViewController
            if let photoName = (self.collectionViewModel[index!]).name{
                print(photoName)
                scrollView.photoName = photoName
            }else{
                let photoURL = (self.collectionViewModel[index!]).url
                scrollView.photoURL = photoURL
            }
            
        }
    }
 

}
