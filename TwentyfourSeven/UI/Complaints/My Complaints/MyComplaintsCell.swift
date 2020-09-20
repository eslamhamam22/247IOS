//
//  MyComplaintsCell.swift
//  TwentyfourSeven
//
//  Created by Salma  on 3/25/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import UIKit

class MyComplaintsCell: UITableViewCell {

    @IBOutlet weak var orderNumView: UIView!
    @IBOutlet weak var orderNumLbl: UILabel!
    @IBOutlet weak var complaintStatusLbl: UILabel!
    @IBOutlet weak var complaintTitleLbl: UILabel!
    @IBOutlet weak var complaintDescLbl: UILabel!
    @IBOutlet weak var orderDateLbl: UILabel!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setCornerRadius(selectedView: orderNumView, radious: 10.0)
        orderNumLbl.font = Utils.customDefaultFont(orderNumLbl.font.pointSize)
        complaintStatusLbl.font = Utils.customDefaultFont(complaintStatusLbl.font.pointSize)
        complaintTitleLbl.font = Utils.customDefaultFont(complaintTitleLbl.font.pointSize)
        complaintDescLbl.font = Utils.customDefaultFont(complaintDescLbl.font.pointSize)
        orderDateLbl.font = Utils.customDefaultFont(orderDateLbl.font.pointSize)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

    func setCell(complaint: Complaint){
        
        setStatus(complaint: complaint)
        if complaint.title != nil{
            complaintTitleLbl.text = "\(complaint.title!)"
        }else{
            complaintTitleLbl.text = ""
        }
        
        if complaint.desc != nil{
            complaintDescLbl.text = complaint.desc
        }else{
            complaintDescLbl.text = ""
        }
        
        if complaint.related_order != nil{
            if complaint.related_order?.id != nil{
                orderNumLbl.text = String(describing: (complaint.related_order?.id!)!)
            }else{
                orderNumLbl.text = ""
            }
        }else{
            orderNumLbl.text = ""
        }
        
        if complaint.created_at != nil{
            orderDateLbl.text = getFormattedDate(dateTxt: complaint.created_at!)
        }else{
            orderDateLbl.text = ""
        }
    }
    
    func setStatus(complaint: Complaint){
        
        if complaint.status != nil{
            if complaint.status == "pending"{
                complaintStatusLbl.text = "complaint_inprogress".localized()
                complaintStatusLbl.textColor = Colors.hexStringToUIColor(hex: "#e84450")
            }else if complaint.status == "resolved"{
                complaintStatusLbl.text = "complaint_resolved".localized()
                complaintStatusLbl.textColor = Colors.hexStringToUIColor(hex: "#4ebf26")
            }else{
                complaintStatusLbl.text = ""
            }
        }else{
            complaintStatusLbl.text = ""
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
}
