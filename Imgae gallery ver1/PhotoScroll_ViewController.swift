//
//  PhotoScroll_ViewController.swift
//  Imgae gallery ver1
//
//  Created by 周熙岩 on 2018/12/8.
//  Copyright © 2018 DoDo. All rights reserved.
//

import UIKit

class PhotoScroll_ViewController: UIViewController, UIScrollViewDelegate{
    
    let imageView = UIImageView()
    
    
    @IBOutlet weak var theScrollView: UIScrollView!{
        didSet{
            print("Scroll View did set")
            theScrollView.maximumZoomScale = 500.0
            theScrollView.minimumZoomScale = 0.01
            theScrollView.delegate = self
        }
    }
    var photoURL:URL?{
        didSet{
            let imageData = try? Data(contentsOf: self.photoURL!)
            if (imageData != nil){
                self.image = UIImage(data: imageData!)!
            }else{
                print("cant get the image using URL")
            }
        }
    }
    var photoName:String?{
        didSet{
            print("Scroll:"+photoName!)
            self.image = UIImage(named: self.photoName!)!
        }
    }
    
    var image:UIImage?{
        didSet{
            self.imageView.image = self.image
            imageView.sizeToFit()
            print(theScrollView)
            self.hasImage = true
        }
    }
    var hasImage = false
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if hasImage{
            theScrollView.addSubview(imageView)
            theScrollView.contentSize = imageView.frame.size
        }else{
            print("Failed to fet the Image")
        }
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
