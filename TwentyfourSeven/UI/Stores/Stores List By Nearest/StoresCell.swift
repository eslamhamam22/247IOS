//
//  StoresCell.swift
//  TwentyfourSeven
//
//  Created by Salma  on 1/14/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation
import Kingfisher

class StoresCell: UITableViewCell {
    
    @IBOutlet weak var storeNameLbl: UILabel!
    @IBOutlet weak var distanceLblWidth: NSLayoutConstraint!
    @IBOutlet weak var distanceLbl: UILabel!
    @IBOutlet weak var statusLbl: UILabel!
    @IBOutlet weak var addressLbl: UILabel!
    @IBOutlet weak var storeImg: UIImageView!
    
    var storeDelegate : StoresDelegate!
    var store = Place()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setCell(store : Place, categoryImg: String, delegate: StoresDelegate, latitude: Double, longitude: Double, index: Int, isNearby: Bool){
        
        self.storeDelegate = delegate
        self.store = store
        
        storeImg.contentMode = .scaleAspectFit
        setFonts()
        
        if store.name != nil{
            storeNameLbl.text = "\u{200E}\(store.name!)"
        }else{
            storeNameLbl.text = ""
        }
        
        if store.geometry != nil {
            if store.geometry?.location != nil{
                let location1 = CLLocation(latitude:latitude , longitude: longitude)
                let location2 = CLLocation(latitude: (store.geometry?.location?.lat)!, longitude: (store.geometry?.location?.lng)!)
                
                let distanceInMeters = location1.distance(from: location2)
                print("distanceInMeters: \(distanceInMeters)")
                if Int(distanceInMeters) > 1000{
                    distanceLbl.text = "\(Int(distanceInMeters/1000)) \("Km".localized())"
                }else{
                    distanceLbl.text = "\(Int(distanceInMeters)) \("M".localized())"
                }
            }else{
                distanceLbl.text = ""
            }
        }else{
            distanceLbl.text = ""
        }
        
        //        storeImg.layer.cornerRadius = 2
        //        storeImg.layer.masksToBounds = true
        //        storeImg.clipsToBounds = true
        
        //get place image if photo refrence not found load category image
        //        var getPlaceImage = false
        //        if store.photos != nil{
        //            if (store.photos?.count)! > 0{
        //                if store.photos![0].photo_reference != nil{
        //                    setPlaceImage()
        //                    getPlaceImage = true
        //                }
        //            }
        //        }
        //        if !getPlaceImage{
        
        if store.isValidUrl == nil{
            //load image for first time
            loadPlaceImage(categoryImg: categoryImg, index: index, isNearby: isNearby)
        }else if store.isValidUrl!{
            loadPlaceImage(categoryImg: categoryImg, index: index, isNearby: isNearby)
        }else{
            // not valid image url
            if categoryImg != ""{
                let url = URL(string: (categoryImg))
                print("url \(String(describing: url))")
                self.storeImg.kf.setImage(with: url, placeholder: UIImage(named: "grayscale"))
            }else{
                self.storeImg.image = UIImage(named: "grayscale")
            }
        }
        
        
        //        }
        
        if store.vicinity != nil{
            addressLbl.text = "\u{200E}\(store.vicinity!)"
        }else{
            addressLbl.text = ""
        }
        
        if store.opening_hours != nil{
            if store.opening_hours?.open_now != nil{
                if (store.opening_hours?.open_now)!{
                    statusLbl.text = "openNow".localized()
                    statusLbl.textColor = Colors.hexStringToUIColor(hex: "#4ebf26")
                }else{
                    statusLbl.text = "closed".localized()
                    statusLbl.textColor = Colors.hexStringToUIColor(hex: "#e84450")
                }
            }else{
                statusLbl.text = ""
            }
        }else{
            statusLbl.text = ""
        }
        
        distanceLblWidth.constant = distanceLbl.intrinsicContentSize.width
        
        let selectTap = UITapGestureRecognizer(target: self, action: #selector(selectAction))
        self.contentView.addGestureRecognizer(selectTap)
        
        
    }
    
    func setFonts(){
        
        storeNameLbl.font = Utils.customDefaultFont(storeNameLbl.font.pointSize)
        distanceLbl.font = Utils.customDefaultFont(distanceLbl.font.pointSize)
        addressLbl.font = Utils.customDefaultFont(addressLbl.font.pointSize)
        statusLbl.font = Utils.customDefaultFont(statusLbl.font.pointSize)
    }
    
    @objc func selectAction(){
        print("selectAction")
        if store.place_id != nil{
            storeDelegate.selectedStore(store: store)
        }
    }
    
    func updateStoreUrl(isValid : Bool, index: Int, isNearby: Bool){
        store.isValidUrl = isValid
        storeDelegate.updateStore(store: store, index: index, isNearby: isNearby)
    }
    
    func setPlaceImage(){
        let urlString = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference="+store.photos![0].photo_reference!+"&key="+AppKeys.WEB_API_KEY
        print(urlString)
        let url = URL(string: urlString)
        storeImg.kf.setImage(with: url, placeholder: UIImage(named: "grayscale")) { (result) in
            switch result {
            case .success:
                self.storeImg.contentMode = .scaleToFill
            case .failure:
                self.storeImg.contentMode = .scaleAspectFit
            }
        }
    }
    
    func loadPlaceImage(categoryImg: String, index: Int, isNearby: Bool){
        let imageUrlStr = APIURLs.MAIN_URL + APIURLs.STORES_IMAGES + store.place_id!
//        if index%2 == 0 {
//            imageUrlStr = "http://247dev.objectsdev.com/images/stores/branches/ChIJUUlF7-HmST4R1YOtNp_AGEk"
//        }
        let imageUrl = URL(string: (imageUrlStr))
        print("url \(String(describing: imageUrl))")
        storeImg.kf.setImage(
            with: imageUrl,
            placeholder: UIImage(named: "grayscale"),
            options: [
                .fromMemoryCacheOrRefresh
            ])
        {
            result in
            switch result {
            case .success:
                print("Task done for:")
                self.updateStoreUrl(isValid: true, index: index, isNearby: isNearby)
            case .failure:
                print("Job failed:")
                self.updateStoreUrl(isValid: false, index: index, isNearby: isNearby)
                if categoryImg != ""{
                    let url = URL(string: (categoryImg))
                    print("url \(String(describing: url))")
                    self.storeImg.kf.setImage(with: url, placeholder: UIImage(named: "grayscale"))
                }else{
                    self.storeImg.image = UIImage(named: "grayscale")
                }
            }
        }
    }
}




