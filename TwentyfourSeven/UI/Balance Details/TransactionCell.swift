//
//  TransactionCell.swift
//  TwentyfourSeven
//
//  Created by Dina Ragab on 3/19/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import UIKit

class TransactionCell: UITableViewCell {

    @IBOutlet weak var descImg: UIImageView!
    @IBOutlet weak var transactionAmountLbl: UILabel!
    @IBOutlet weak var transactionTypeLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var transactionDesc: UILabel!
    @IBOutlet weak var transactionAmountWidth: NSLayoutConstraint!
    
    var dateManager = DateManager()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        transactionAmountLbl.font = Utils.customDefaultFont(transactionAmountLbl.font.pointSize)
        transactionTypeLbl.font = Utils.customDefaultFont(transactionTypeLbl.font.pointSize)
        timeLbl.font = Utils.customDefaultFont(timeLbl.font.pointSize)
        dateLbl.font = Utils.customDefaultFont(dateLbl.font.pointSize)
        transactionDesc.font = Utils.customDefaultFont(transactionDesc.font.pointSize)
    }
    
    func setCell(transaction : Transaction){
        
        if let amount = transaction.amount{
            self.transactionAmountLbl.text = "\(String(format: "%.2f", amount)) \("sar".localized())"
            if amount >= 0 {
                self.transactionAmountLbl.textColor = Colors.hexStringToUIColor(hex: "4EBF26")
            }else{
                self.transactionAmountLbl.textColor = Colors.hexStringToUIColor(hex: "E84450")
            }
        }else{
            self.transactionAmountLbl.text = ""
        }
        
        transactionAmountWidth.constant = self.transactionAmountLbl.intrinsicContentSize.width
        
        if let transactionDescription = transaction.transaction_desc{
            transactionDesc.text = transactionDescription
            descImg.isHidden = false
        }else{
            descImg.isHidden = true
            transactionDesc.text = ""
        }
        
        if let transactionDate = transaction.created_at{
            dateLbl.text = dateManager.getDateFormatted(dateStr: transactionDate, format: "dd MMM yyyy")
            timeLbl.text = dateManager.getDateFormatted(dateStr: transactionDate, format: "hh:mm a")
        }else{
            dateLbl.text = ""
            timeLbl.text = ""
        }
        
        if let transactionTitle = transaction.paymentTitle{
            transactionTypeLbl.text = transactionTitle
        }else{
            transactionTypeLbl.text = ""
        }
        
        if let transationImg = transaction.payment_method{
            descImg.image = setPaymentImage(method: transationImg)
            descImg.isHidden = false
        }else{
            descImg.isHidden = true
        }
    }
    
    func setPaymentImage(method : Int) -> UIImage{
        
        if method == 0{
            return UIImage(named: "withdraw_ic")!
        }else if method == 1{
            return UIImage(named: "transfer_ic")!
        }else if method == 2{
            return UIImage(named: "credit")!
        }else if method == 3{
            return UIImage(named: "sadad")!
        }
        
        return UIImage(named: "withdraw_ic")!
    }
    
  
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
