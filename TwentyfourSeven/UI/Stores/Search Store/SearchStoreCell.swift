//
//  SearchStoreCell.swift
//  TwentyfourSeven
//
//  Created by Salma  on 1/28/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import UIKit
import GooglePlaces

class SearchStoreCell: UITableViewCell {

    @IBOutlet weak var addressLbl: UILabel!
    @IBOutlet weak var addressTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setCell(address : String, title: String){
        addressLbl.text = "\u{200E}\(address)"
        addressTitle.text = "\u{200E}\(title)"
        
        addressLbl.font = Utils.customDefaultFont(addressLbl.font.pointSize)
        addressTitle.font = Utils.customDefaultFont(addressTitle.font.pointSize)
    }
}
