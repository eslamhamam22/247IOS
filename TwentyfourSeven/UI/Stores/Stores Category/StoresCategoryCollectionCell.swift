//
//  StoresCategoryCollectionCell.swift
//  TwentyfourSeven
//
//  Created by Salma  on 1/13/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import UIKit
import Kingfisher

class StoresCategoryCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var categoryImg: UIImageView!
    @IBOutlet weak var categoryNameLbl: UILabel!
    @IBOutlet weak var categoryLine: UIView!
    @IBOutlet weak var categoryLineBottom: NSLayoutConstraint!

    func setCell(category : Category, index: Int){
        if category.name != nil{
            categoryNameLbl.text = category.name!
        }else{
            categoryNameLbl.text = ""
        }
        categoryNameLbl.font = Utils.customDefaultFont(categoryNameLbl.font.pointSize)
        
        if category.image != nil{
            let url = URL(string: (category.image?.big)!)
            print("url \(String(describing: url))")
            //                self.profileImg.kf.setImage(with: url, placeholder: UIImage(named: "avatar"), options: [.forceRefresh])
            self.categoryImg.kf.setImage(with: url, placeholder: UIImage(named: "grayscale"))
        }else{
            self.categoryImg.image = UIImage(named: "grayscale")
        }
        
        if index%3 == 0{
            categoryLine.isHidden = true
        }else{
            categoryLine.isHidden = false
        }
        
        if index > 3{
            categoryLineBottom.constant = 0
        }else{
            categoryLineBottom.constant = 0
        }
    }
}
