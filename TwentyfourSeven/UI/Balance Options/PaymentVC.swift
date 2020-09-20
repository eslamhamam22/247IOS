//
//  TestVC.swift
//  TwentyfourSeven
//
//  Created by Dina Ragab on 3/16/20.
//  Copyright © 2020 Objects. All rights reserved.
//

import UIKit

class PaymentVC: UIViewController {

    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var backIcon: UIBarButtonItem!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let userDefault = UserDefault()
    
    var paymentData = PaymentData()
    override func viewDidLoad() {
        super.viewDidLoad()
        initWebView()
        setUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func setUI(){
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: Utils.customBoldFont(17), NSAttributedString.Key.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.barStyle = .blackOpaque
        self.navigationItem.title = "Cerdit_Card".localized()

        if appDelegate.isRTL{
            backIcon.image = UIImage(named: "back_ar_ic")
        }else{
            backIcon.image = UIImage(named: "back_ic")
        }
        
    }
    
    @IBAction func backPressed(_ sender: Any) {
        
        if let balance = userDefault.getUserData().balance {
            if balance == 0.0{
                self.dismiss(animated: true) {
                    if let nav = self.topMostController() as? UINavigationController{
                        if let balanceDetailsVC = nav.topViewController as? BalanceDetailsVC {
                            if (balanceDetailsVC.isViewLoaded) {
                                balanceDetailsVC.customizeWalletView()
                                balanceDetailsVC.resetData()
                            }
                        }
                    }
                }
            }else{
                self.navigationController?.popViewController(animated: true)
            }
        }
        
        
    }
    
    
    func topMostController() -> UIViewController {
        var topController: UIViewController? = UIApplication.shared.keyWindow?.rootViewController
        while ((topController?.presentedViewController) != nil) {
            topController = topController?.presentedViewController
        }
        return topController!
    }
    
    func initWebView(){
        webView.loadHTMLString(paymentData.html ?? "", baseURL: nil)
    }


}
