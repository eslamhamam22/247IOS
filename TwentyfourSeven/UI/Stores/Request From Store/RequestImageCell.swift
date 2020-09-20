//
//  RequestImageCell.swift
//  TwentyfourSeven
//
//  Created by Salma  on 1/23/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import UIKit
import Kingfisher

class RequestImageCell: UICollectionViewCell {
    
    @IBOutlet weak var uploadedImg: UIImageView!
    @IBOutlet weak var deleteImg: UIImageView!
    
    var image = DelegateImageData()
    var delegate: RequestFromStoreDelegate!
    
    func setCell(image: DelegateImageData, isPlusImage: Bool, delegate: RequestFromStoreDelegate){
        self.image = image
        self.delegate = delegate
        
        if isPlusImage{
            uploadedImg.image = UIImage(named: "add_img_btn")
            deleteImg.isHidden = true
        }else{
            if image.image != nil{
                if image.image!.small != nil{
                    let url = URL(string: (image.image!.small)!)
                    print("url \(String(describing: url))")
                    uploadedImg.kf.setImage(with: url, placeholder: UIImage(named: "default"))
                    if image.image?.small != ""{
                        deleteImg.isHidden = false
                    }else{
                        deleteImg.isHidden = true
                    }
                }else{
                    uploadedImg.image = UIImage(named: "default")
                    deleteImg.isHidden = true
                }
            }else{
                uploadedImg.image = UIImage(named: "default")
                deleteImg.isHidden = true
            }
        }
        
        uploadedImg.layer.cornerRadius = 10
        uploadedImg.layer.masksToBounds = true
        uploadedImg.clipsToBounds = true
        
        let deleteTap = UITapGestureRecognizer(target: self, action: #selector(deletePressed))
        deleteImg.addGestureRecognizer(deleteTap)
    }
    
    @objc func deletePressed(){
        print("delete Pressed")
        if image.id != nil{
            delegate.deleteImage(id: image.id!)
        }
    }
}
