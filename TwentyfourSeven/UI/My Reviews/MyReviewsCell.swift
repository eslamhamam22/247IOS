//
//  MyRatingCell.swift
//  TwentyfourSeven
//
//  Created by Salma  on 3/19/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import UIKit

class MyReviewsCell: UITableViewCell {

    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var rateImg: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var reviewLbl: UILabel!
    @IBOutlet weak var timeWidth: NSLayoutConstraint!
    @IBOutlet weak var nameTop: NSLayoutConstraint!

    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var review = Review()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setCell(review: Review){
        
        self.review = review
        
        if review.comment != nil{
            reviewLbl.text = review.comment
        }else{
            reviewLbl.text = ""
        }
        
        if review.created_at != nil{
            timeLbl.text = getFormattedDate(dateTxt: review.created_at!)
            timeLbl.text = "\(getFormattedDate(dateTxt: review.created_at!))\n\(getFormattedTime(dateTxt: review.created_at!))"
//            timeWidth.constant = timeLbl.intrinsicContentSize.width
        }else{
            timeLbl.text = ""
//            timeWidth.constant = 0
        }
        
        if appDelegate.isRTL{
            nameTop.constant = -3
        }else{
            nameTop.constant = 2
        }
        
        setFonts()
        setCornerRadius(selectedView: profileImg, radius: 5)
        setRateEmoji()
        setReviewerData()
    }
    
    func setReviewerData(){
        if review.created_by != nil{
            if review.created_by?.name != nil{
                nameLbl.text = review.created_by?.name
            }else{
                nameLbl.text = ""
            }
            
            if review.created_by?.image != nil{
                if review.created_by?.image!.medium != nil{
                    let url = URL(string: (review.created_by?.image?.medium)!)
                    print("url \(String(describing: url))")
                    self.profileImg.kf.setImage(with: url, placeholder: UIImage(named: "avatar"))
                }else{
                    profileImg.image = UIImage(named: "avatar")
                }
            }else{
                profileImg.image = UIImage(named: "avatar")
            }
        }else{
            nameLbl.text = ""
            profileImg.image = UIImage(named: "avatar")
        }
    }
    
    func setRateEmoji(){
        var rate = 0
        if review.rating != nil{
            rate = review.rating!
        }
        if rate == 1{ //very bad
            rateImg.image = UIImage(named: "review_very_bad")
        }else if rate == 2{ //bad
            rateImg.image = UIImage(named: "review_bad")
        }else if rate == 3{ //normal
            rateImg.image = UIImage(named: "review_normal")
        }else if rate == 4{ //good
            rateImg.image = UIImage(named: "review_good")
        }else if rate == 5{ //very good
            rateImg.image = UIImage(named: "review_very_good")
        }
    }
    
    func setFonts(){
        reviewLbl.font = Utils.customDefaultFont(reviewLbl.font.pointSize)
        nameLbl.font = Utils.customDefaultFont(nameLbl.font.pointSize)
        timeLbl.font = Utils.customDefaultFont(timeLbl.font.pointSize)
    }
    
    func setCornerRadius(selectedView : UIView, radius: CGFloat){
        selectedView.layer.cornerRadius = radius
        selectedView.layer.masksToBounds = true
        selectedView.clipsToBounds = true
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
            dateFormatter.dateFormat = "dd MMM yyyy"
            
            let dateString = dateFormatter.string(from: date!)
            return dateString
        }
        
        return ""
    }
    
    func getFormattedTime(dateTxt : String) -> String{
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
            dateFormatter.dateFormat = "h:mm a"
            
            let dateString = dateFormatter.string(from: date!)
            return dateString
        }
        
        return ""
    }
}
