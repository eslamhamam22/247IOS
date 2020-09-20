//
//  StoresHeaderCell.swift
//  TwentyfourSeven
//
//  Created by Salma  on 1/14/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import UIKit

class StoresHeaderCell: UITableViewCell {

    @IBOutlet weak var headerLbl: UILabel!
    @IBOutlet weak var buttonWidth: NSLayoutConstraint!
    @IBOutlet weak var buttonLbl: UILabel!
    @IBOutlet weak var buttonBgImg: UIView!

    var storesDelegate : StoresDelegate!
    var isNearBy = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setCell(isNearBy : Bool, delegate: StoresDelegate){
        self.storesDelegate = delegate
        self.isNearBy = isNearBy
        
        setFonts()
        setGestures()
       
        buttonBgImg.layer.cornerRadius = 10
        buttonBgImg.layer.masksToBounds = true
        buttonBgImg.clipsToBounds = true
        
        if isNearBy {
            headerLbl.text = "NearbyStores".localized()
            buttonLbl.text = "moreStores".localized()
        }else{
            headerLbl.text = "activeStores".localized()
            buttonLbl.text = "showAll".localized()
        }
        buttonWidth.constant = buttonLbl.intrinsicContentSize.width
    }
    
    func setFonts(){
        headerLbl.font = Utils.customBoldFont(headerLbl.font.pointSize)
        buttonLbl.font = Utils.customDefaultFont(buttonLbl.font!.pointSize)
    }
    
    func setGestures(){
        let moreTap = UITapGestureRecognizer(target: self, action: #selector(moreAction))
        buttonBgImg.addGestureRecognizer(moreTap)
        
        let moreLblTap = UITapGestureRecognizer(target: self, action: #selector(moreAction))
        buttonLbl.addGestureRecognizer(moreLblTap)
    }
    
    @objc func moreAction(){
       storesDelegate.selectedHeader(isNearBy: self.isNearBy)
    }
}
