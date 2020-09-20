//
//  OrderCellTableViewCell.swift
//  TwentyfourSeven
//
//  Created by Dina Ragab on 2/6/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import UIKit

class OrderCell: UITableViewCell {
    
    @IBOutlet weak var fromToConstraint: NSLayoutConstraint!
    @IBOutlet weak var pinToPintVConstraint: NSLayoutConstraint!
    @IBOutlet weak var orderNumView: UIView!
    @IBOutlet weak var orderNumLbl: UILabel!
    @IBOutlet weak var orderStatus: UILabel!
    @IBOutlet weak var orderCar: UIImageView!
    @IBOutlet weak var orderDestination: UILabel!
    @IBOutlet weak var driverName: UILabel!
    @IBOutlet weak var orderSource: UILabel!
    @IBOutlet weak var orderDate: UILabel!
    @IBOutlet weak var dotsImg: UIImageView!
    
    var userDefault = UserDefault()
    var order = Order()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    override func awakeFromNib() {
        super.awakeFromNib()
        setCornerRadius(selectedView: orderNumView, radious: 10.0)
        orderStatus.font = Utils.customDefaultFont(orderStatus.font.pointSize)
        orderDestination.font = Utils.customDefaultFont(orderDestination.font.pointSize)
        driverName.font = Utils.customDefaultFont(driverName.font.pointSize)
        orderSource.font = Utils.customDefaultFont(orderSource.font.pointSize)
        orderDate.font = Utils.customDefaultFont(orderDate.font.pointSize)
    }
    
  
    func setCell(indexPath : IndexPath , showCarDetails : Bool , order : Order){

        /* Hide car and driver details in 2 cases
          - if user is opened driverTab
          - in orders if there is no delegate inn response
            and after hiding change vertical constarint */
        
        if showCarDetails{
            if order.delegate != nil{
                if order.delegate?.name != nil{
                    driverName.text = order.delegate?.name!
                }else{
                    driverName.text = ""
                }
                driverName.isHidden = false
                orderCar.isHidden = false
                pinToPintVConstraint.constant = 40.5
                fromToConstraint.constant = 34.5
                dotsImg.image = UIImage(named: "line")
            }else{
                driverName.text = ""
                driverName.isHidden = true
                orderCar.isHidden = true
                pinToPintVConstraint.constant = 20.5
                fromToConstraint.constant = 17
                dotsImg.image = UIImage(named: "line_small")
            }
            
        }else{
            driverName.isHidden = true
            orderCar.isHidden = true
            pinToPintVConstraint.constant = 20.5
            fromToConstraint.constant = 17
            dotsImg.image = UIImage(named: "line_small")
        }
        
        //set data
        if order.id != nil{
            orderNumLbl.text = "\(String(describing: order.id!))"
        }else{
            orderNumLbl.text = ""
        }
        
        if order.created_at != nil{
            orderDate.text = getFormattedDate(dateTxt: order.created_at!)
        }else{
            orderDate.text = ""
        }
        
        if order.status != nil{
            
            if order.status! == "new"{
                orderStatus.text = "newStatus".localized()
                orderStatus.textColor = Colors.hexStringToUIColor(hex: "498BCA")
            }else if order.status! == "delivery_in_progress"{
                orderStatus.text = "beignDeliveredStatus".localized()
                orderStatus.textColor = Colors.hexStringToUIColor(hex: "5CACF9")
            }else if order.status! == "cancelled"{
                orderStatus.text = "CancelledStatus".localized()
                orderStatus.textColor = Colors.hexStringToUIColor(hex: "E84450")
            }else if order.status! == "pending"{
                orderStatus.text = "pendingStatus".localized()
                orderStatus.textColor = Colors.hexStringToUIColor(hex: "A5AAB2")
            }else if order.status! == "assigned"{
                orderStatus.text = "assignedStatus".localized()
                orderStatus.textColor = Colors.hexStringToUIColor(hex: "FF9F3E")
            }else if order.status! == "in_progress"{
                orderStatus.text = "inProgressStatus".localized()
                orderStatus.textColor = Colors.hexStringToUIColor(hex: "d8ca72")
            }else if order.status! == "delivered"{
                orderStatus.text = "DeliveredStatus".localized()
                orderStatus.textColor = Colors.hexStringToUIColor(hex: "4DD552")
            }
        }else{
            orderStatus.text = ""
        }
        
        if order.store_name != nil{
            orderSource.text = order.store_name!
        }else if order.from_address != nil{
            orderSource.text = order.from_address!
        }
        
     
        
        if order.to_address != nil{
            orderDestination.text =  order.to_address!
        }else{
            orderDestination.text = ""
        }
        
    }
    
    func getFormattedDate(dateTxt : String) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ" //Your date format
        //dateFormatter.timeZone = TimeZone(abbreviation: "GMT+0:00") //Current time zone
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale?
        let date = dateFormatter.date(from: dateTxt)
        if date != nil{
            if(appDelegate.isRTL) {
                dateFormatter.locale = NSLocale(localeIdentifier: "ar_EG") as Locale?
            }else{
                dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale?
            }
            dateFormatter.dateFormat = "dd MMM yyyy h:mm a"
            
            let dateString = dateFormatter.string(from: date!)
            return dateString
        }
        
        return ""
    }
  
    func setCornerRadius(selectedView : UIView , radious : CGFloat){
        selectedView.layer.cornerRadius = radious
        selectedView.layer.masksToBounds = true
        selectedView.clipsToBounds = true
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
