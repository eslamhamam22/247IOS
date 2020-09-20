//
//  AlertManager.swift
//  TwentyfourSeven
//
//  Created by Dina Ragab on 2/25/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import UIKit

class AlertManager {
    
    func showAlert( alertMsg : String , okText : String , cancelText : String , color : UIColor ,tintColor : UIColor , completion: @escaping (_ success: Bool) -> ()){
        
        let alert = UIAlertController(title: "", message:alertMsg, preferredStyle: UIAlertController.Style.alert)
        alert.setValue(NSAttributedString(string: alertMsg, attributes: [NSAttributedString.Key.font : Utils.customDefaultFont(15.0)
            , NSAttributedString.Key.foregroundColor : color]), forKey: "attributedMessage")

        alert.addAction(UIAlertAction(title: okText, style: UIAlertAction.Style.default, handler: { (action) in
                completion(true)
        }))
        //change text color of alert view buttons
        alert.view.tintColor = tintColor
        alert.addAction(UIAlertAction(title: cancelText, style: UIAlertAction.Style.cancel, handler: nil))
        topMostController().present(alert, animated: true, completion: nil)
    }
    
    func topMostController() -> UIViewController {
        var topController: UIViewController? = UIApplication.shared.keyWindow?.rootViewController
        while ((topController?.presentedViewController) != nil) {
            topController = topController?.presentedViewController
        }
        return topController!
    }
}
