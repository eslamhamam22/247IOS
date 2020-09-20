//
//  AddCouponVC.swift
//  TwentyfourSeven
//
//  Created by Salma  on 5/20/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import UIKit
import MBProgressHUD
import Toaster

class AddCouponVC: UIViewController {

    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var couponView: UIView!
    @IBOutlet weak var couponTF: UITextField!
    @IBOutlet weak var couponErrorLbl: UILabel!
    @IBOutlet weak var submitLbl: UILabel!
    @IBOutlet weak var cancelLbl: UILabel!
    
    var addCouponPresenter : AddCouponPresenter!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var loadingView: MBProgressHUD!
    var addCouponDelegate: AddCouponDelegate!
    var couponCode = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addCouponPresenter = AddCouponPresenter(repository: Injection.provideOrderRepository(), userRepository: Injection.provideUserRepository())
        addCouponPresenter.setView(view: self)
        setUI()
        setFonts()
        setLocalization()
    }
 
    func setUI(){
        setCornerRadius(selectedView: alertView)
        setCornerRadius(selectedView: couponView)
        couponTF.delegate = self
        if appDelegate.isRTL{
            couponTF.textAlignment = .right
        }else{
            couponTF.textAlignment = .left
        }

        if couponCode != ""{
            couponTF.text = couponCode
        }
        
        couponErrorLbl.text = "coupon_error".localized()
    }
    
    func setFonts(){
        titleLbl.font = Utils.customDefaultFont(titleLbl.font.pointSize)
        couponTF.font = Utils.customDefaultFont(couponTF.font!.pointSize)
        couponErrorLbl.font = Utils.customDefaultFont(couponErrorLbl.font.pointSize)
        submitLbl.font = Utils.customDefaultFont(submitLbl.font.pointSize)
        cancelLbl.font = Utils.customDefaultFont(cancelLbl.font.pointSize)
    }
    
    func setLocalization(){
        titleLbl.text = "add_coupon".localized()
        couponTF.placeholder = "coupon_placeholder".localized()
        submitLbl.text = "submit".localized()
        cancelLbl.text = "editCancel".localized()
    }
    
    func setCornerRadius(selectedView : UIView){
        selectedView.layer.cornerRadius = 12
        selectedView.layer.masksToBounds = true
        selectedView.clipsToBounds = true
    }
    
    @IBAction func submitAction(_ sender: Any) {
        print("submit Action")
        self.view.endEditing(true)
        couponErrorLbl.isHidden = true

        if couponTF.text != ""{
            if couponTF.text != nil{
                couponCode = couponTF.text!
            }
            addCouponPresenter.validateCoupon(code: couponCode)
        }else{
            couponErrorLbl.isHidden = false
        }
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        print("cancel Action")
        addCouponDelegate.addCoupon(coupon: couponCode)
        performSegue(withIdentifier: "exit", sender: self)
    }
    
    @IBAction func dismissKeyboradAction(_ sender: Any) {
        self.view.endEditing(true)
    }
}
extension AddCouponVC : UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        
        return true
    }
}

extension AddCouponVC: AddCouponView{
    
    func showloading() {
        loadingView = MBProgressHUD.showAdded(to: self.view, animated: true)
        loadingView.mode = MBProgressHUDMode.indeterminate
    }
    
    func hideLoading() {
        if(loadingView != nil) {
            loadingView.hide(animated: true)
            loadingView = nil
        }
    }
    
    func showNetworkError() {
        Toast.init(text: "connectionFailed".localized()).show()
    }
    
    func showGeneralError() {
        Toast.init(text: "general_error".localized()).show()
    }
    
    func showSusspendedMsg(msg: String) {
        Toast.init(text:msg).show()
    }
    
    func showSuccess(){
        addCouponDelegate.addCoupon(coupon: couponCode)
        performSegue(withIdentifier: "exit", sender: self)
    }
    
    func showFailure(){
        couponCode = ""
    }
}
