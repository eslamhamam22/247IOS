//
//  OrderOfferCell.swift
//  TwentyfourSeven
//
//  Created by Salma  on 2/11/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import UIKit
import Cosmos

class OrderOfferCell: UITableViewCell {

    @IBOutlet weak var delegateImg: UIImageView!
    @IBOutlet weak var delegateNameLbl: UILabel!
    @IBOutlet weak var offerPriceTitleLbl: UILabel!
    @IBOutlet weak var offerPriceLbl: UILabel!
    @IBOutlet weak var offerTimeTitleLbl: UILabel!
    @IBOutlet weak var offerTimeLbl: UILabel!
    @IBOutlet weak var distanceTitleLbl: UILabel!
//    @IBOutlet weak var delegateAddressLbl: UILabel!
    @IBOutlet weak var distanceLbl: UILabel!
    @IBOutlet weak var acceptLbl: UILabel!
    @IBOutlet weak var acceptLblWidth: NSLayoutConstraint!
    @IBOutlet weak var acceptView: UIView!
    @IBOutlet weak var rejectLbl: UILabel!
    @IBOutlet weak var rejectView: UIView!
    @IBOutlet weak var rejectLblWidth: NSLayoutConstraint!
    @IBOutlet weak var starRateView: CosmosView!
    @IBOutlet weak var offerBackground: UIView!

    var offer = Offer()
    var delegate: AcceptOfferDelegate!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setFonts()
        setGestures()
        setCornerRadius(selectedView: acceptView, radius: 6)
        setCornerRadius(selectedView: rejectView, radius: 6)
        setCornerRadius(selectedView: delegateImg, radius: 5)
        setCornerRadius(selectedView: offerBackground, radius: 12)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func setCell(offer: Offer, delegate: AcceptOfferDelegate, deliveryDuration: Int){
        self.offer = offer
        self.delegate = delegate
        
        setDelegateData()
        setTotalPrice()
        
//        if offer.delegate_address != nil{
//            delegateAddressLbl.text = offer.delegate_address!
//        }else{
//            delegateAddressLbl.text = ""
//        }
        
        if offer.dist_to_pickup != nil{
            distanceLbl.text = calculateDistance(distanceInMeters: offer.dist_to_pickup!*1000)
        }else{
            distanceLbl.text = ""
        }
        offerTimeLbl.text = "\(deliveryDuration) \("hr".localized())"
        acceptLbl.text = "accept_offer".localized()
        acceptLblWidth.constant = acceptLbl.intrinsicContentSize.width
        rejectLbl.text = "reject_offer".localized()
        rejectLblWidth.constant = rejectLbl.intrinsicContentSize.width
        offerTimeTitleLbl.text = "offer_time".localized()
        offerPriceTitleLbl.text = "offer_price".localized()
        distanceTitleLbl.text = "offer_distance".localized()
    }
    
    func setFonts(){
        delegateNameLbl.font = Utils.customDefaultFont(delegateNameLbl.font.pointSize)
//        delegateAddressLbl.font = Utils.customDefaultFont(delegateAddressLbl.font.pointSize)
        distanceTitleLbl.font = Utils.customDefaultFont(distanceTitleLbl.font.pointSize)
        offerPriceTitleLbl.font = Utils.customDefaultFont(offerPriceTitleLbl.font.pointSize)
        offerTimeTitleLbl.font = Utils.customDefaultFont(offerTimeTitleLbl.font.pointSize)
        acceptLbl.font = Utils.customDefaultFont(acceptLbl.font.pointSize)
        rejectLbl.font = Utils.customDefaultFont(rejectLbl.font.pointSize)
        offerPriceLbl.font = Utils.customBoldFont(offerPriceLbl.font.pointSize)
        offerTimeLbl.font = Utils.customBoldFont(offerTimeLbl.font.pointSize)
        distanceLbl.font = Utils.customBoldFont(distanceLbl.font.pointSize)
    }
    
    func setGestures(){
        
        let acceptTab = UITapGestureRecognizer(target: self, action: #selector(acceptOffer))
        acceptView.addGestureRecognizer(acceptTab)
        
        let acceptLblTab = UITapGestureRecognizer(target: self, action: #selector(acceptOffer))
        acceptLbl.addGestureRecognizer(acceptLblTab)
        
        let rejectTab = UITapGestureRecognizer(target: self, action: #selector(rejectOffer))
        rejectView.addGestureRecognizer(rejectTab)
        
        let rejectLblTab = UITapGestureRecognizer(target: self, action: #selector(rejectOffer))
        rejectLbl.addGestureRecognizer(rejectLblTab)
        
        let delegateNameTab = UITapGestureRecognizer(target: self, action: #selector(delegateProfilePressed))
        delegateNameLbl.addGestureRecognizer(delegateNameTab)
        
        let delegateImgTab = UITapGestureRecognizer(target: self, action: #selector(delegateProfilePressed))
        delegateImg.addGestureRecognizer(delegateImgTab)
    }
    
    func setDelegateRate(rate: Double){
        starRateView.update()
        starRateView.settings.updateOnTouch = false
        starRateView.rating = rate
    }
    
    func setDelegateData(){
        var delegate = UserData()
        if offer.delegate != nil{
            delegate = offer.delegate!
        }
        
        if delegate.name != nil{
            delegateNameLbl.text = delegate.name!
        }else{
            delegateNameLbl.text = ""
        }
        
        delegateImg.image = UIImage(named: "avatar")
        if delegate.image != nil{
            if delegate.image?.medium != nil{
                let url = URL(string: (delegate.image?.medium)!)
                print("url \(String(describing: url))")
                self.delegateImg.kf.setImage(with: url, placeholder: UIImage(named: "avatar"))
            }
        }
        
        if delegate.delegate_rating != nil{
            setDelegateRate(rate: delegate.delegate_rating!)
        }else{
            setDelegateRate(rate: 5)
        }
    }
    
    func setTotalPrice(){
        var totalValue = 0.0
        
        if offer.cost != nil{
            totalValue = offer.cost!
        }
        
//        if offer.vat != nil{
//            totalValue += offer.vat!
//        }
        offerPriceLbl.text = getPrice(price: totalValue)
    }
    
    func setCornerRadius(selectedView : UIView, radius: CGFloat){
        selectedView.layer.cornerRadius = radius
        selectedView.layer.masksToBounds = true
        selectedView.clipsToBounds = true
    }
    
    func calculateDistance(distanceInMeters : Double) -> String{
        if Int(distanceInMeters) > 1000{
            let distance = distanceInMeters/1000
            if distance.truncatingRemainder(dividingBy: 1) == 0 {
                return "\(Int(distanceInMeters/1000)) \("Km".localized())"
            }else{
                return "\(String(format: "%.1f", distanceInMeters/1000)) \("Km".localized())"
            }
        }else{
            if distanceInMeters.truncatingRemainder(dividingBy: 1) == 0 {
                return "\(Int(distanceInMeters)) \("M".localized())"
            }else{
                return "\(String(format: "%.1f", distanceInMeters)) \("M".localized())"
            }
        }
    }
    
    
    func getPrice(price: Double) -> String{
//        if price.truncatingRemainder(dividingBy: 1) == 0 {
//            return "\(Int(price)) \("sar".localized())"
//        }else{
            let priceStr = String(format: "%.2f", price)
            return "\(priceStr) \("sar".localized())"
//        }
    }
    
    @objc func acceptOffer(){
        if offer.id != nil{
            delegate.acceptOffer(offerID: offer.id!, offerPrice: offerPriceLbl.text!)
        }
    }
    
    @objc func rejectOffer(){
        if offer.id != nil{
            delegate.rejectOffer(offerID: offer.id!, offerPrice: offerPriceLbl.text!)
        }
    }
    
    @objc func delegateProfilePressed(){
        if offer.delegate != nil{
            if offer.delegate?.id != nil{
                delegate.delegateProfilePressed(delegateId: (offer.delegate?.id)!)
            }
        }
    }
}
