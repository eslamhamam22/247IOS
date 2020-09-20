//
//  MyAddressCell.swift
//  TwentyfourSeven
//
//  Created by Salma  on 12/30/18.
//  Copyright © 2018 Objects. All rights reserved.
//

import UIKit

class MyAddressCell: UITableViewCell {

    @IBOutlet weak var addressNameLbl: UILabel!
    @IBOutlet weak var addressDetailsLbl: UILabel!
    @IBOutlet weak var deleteAddressIcon: UIImageView!
    @IBOutlet weak var selectAddressIcon: UIImageView!
    @IBOutlet weak var iconTopConstraint: NSLayoutConstraint!

    var address = Address()
    var isFromOrder = false
    var addressesDelegate : AddressesDelegate!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if isFromOrder{
            if selected{ //select address
                selectAddressIcon.isHidden = false
                addressNameLbl.textColor = Colors.hexStringToUIColor(hex: "366DB3")
                addressesDelegate.selectAddress(address: self.address)
            }else{
                selectAddressIcon.isHidden = true
                addressNameLbl.textColor = Colors.hexStringToUIColor(hex: "3F4247")
            }
        }
    }

    func setCell(address: Address, delegate: AddressesDelegate, isFromOrder: Bool){
        self.address = address
        self.isFromOrder = isFromOrder
        self.addressesDelegate = delegate
        
        if address.address_title != nil {
            addressNameLbl.text = address.address_title
        }else{
            addressNameLbl.text = ""
        }
        
        if address.address != nil{
            addressDetailsLbl.text = address.address
        }else{
            addressDetailsLbl.text = ""
        }
        
        addressNameLbl.font = Utils.customDefaultFont(addressNameLbl.font.pointSize)
        addressDetailsLbl.font = Utils.customDefaultFont(addressDetailsLbl.font.pointSize)

        if appDelegate.isRTL{
            iconTopConstraint.constant = -3
        }else{
            iconTopConstraint.constant = 0
        }

        selectAddressIcon.isHidden = true

        if isFromOrder{
            deleteAddressIcon.isHidden = true
        }
        
        let deleteTab = UITapGestureRecognizer(target: self, action: #selector(self.deleteAddress))
        deleteAddressIcon.addGestureRecognizer(deleteTab)
    }
    
    @objc func deleteAddress(){
        if address.id != nil{
            self.addressesDelegate.deleteAddress(id: address.id!)
        }
    }
}
