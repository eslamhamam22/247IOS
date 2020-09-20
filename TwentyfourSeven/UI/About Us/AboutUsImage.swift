//
//  AboutUsImage.swift
//  TwentyfourSeven
//
//  Created by Geek on 6/27/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import UIKit

class AboutUsImage: UIViewController {

    @IBOutlet weak var imageHeight: NSLayoutConstraint!
    @IBOutlet weak var backImg: UIBarButtonItem!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }
 
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func setUI(){
        let image = UIImage(named: "Artboard")
        let heightInPoints = image!.size.height
        // let heightInPixels = heightInPoints * image!.scale
        
        self.imageHeight.constant = heightInPoints
        
        if appDelegate.isRTL{
            backImg.image = UIImage(named: "back_ar_ic")
        }else{
            backImg.image = UIImage(named: "back_ic")
        }
        
        self.navigationItem.title = "aboutUs".localized()
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: Utils.customBoldFont(17), NSAttributedString.Key.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.barStyle = .blackOpaque

    }
    
    @IBAction func backAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
