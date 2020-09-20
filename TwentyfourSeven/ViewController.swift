//
//  ViewController.swift
//  TwentyfourSeven
//
//  Created by Salma Ali on 11/26/18.
//  Copyright © 2018 Objects. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var viewHeight: UIView!
    @IBOutlet weak var viewH: NSLayoutConstraint!
    
    @IBOutlet weak var scrollH: NSLayoutConstraint!
    @IBOutlet weak var imageH: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
//        let image = UIImage(named: "download")
        
//        self.img.kf.setImage(with: URL(string: "https://247dev.objectsdev.com/images/users/medium/5cb337e740076480165101.jpg"),
//                                          placeholder: nil,
//                                          options: nil,
//                                          progressBlock: nil,
//                                          completionHandler: { image, error, cacheType, imageURL in
//                                            if image != nil && error == nil{
//                                                let heightInPoints = image!.size.height
//                                                let heightInPixels = heightInPoints * image!.scale
//
//                                                self.imageH.constant = heightInPixels
//                                            }
//
//        })
        let image = UIImage(named: "download")
        let heightInPoints = image!.size.height
       // let heightInPixels = heightInPoints * image!.scale
        
        self.imageH.constant = heightInPoints
    }


}

