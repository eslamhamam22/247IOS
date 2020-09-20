//
//  VerifyMobileNumberVC.swift
//  TwentyfourSeven
//
//  Created by Salma  on 12/4/18.
//  Copyright © 2018 Objects. All rights reserved.
//

import UIKit
import MBProgressHUD
import Toaster
import Firebase

class VerifyMobileNumberVC: UITableViewController{

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var infoLbl: UILabel!
    @IBOutlet weak var submitLbl: UILabel!
    @IBOutlet weak var submitBgImg: UIImageView!
    @IBOutlet weak var resendLbl: UILabel!
    @IBOutlet weak var backImg: UIImageView!
    @IBOutlet weak var firstView: UIView!
    @IBOutlet weak var secondView: UIView!
    @IBOutlet weak var thirdView: UIView!
    @IBOutlet weak var forthView: UIView!
    @IBOutlet weak var coveredView: UIView!
    @IBOutlet weak var underlineView: UIView!
    @IBOutlet weak var codeCenterConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var firstViewConstraint: NSLayoutConstraint!
    var isResendAvailable = false
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var verifyMobileNumberPresenter: VerifyMobileNumberPresenter!
    
    var phoneNumber = ""
    var isFacebook = false
    var socialToken = ""
    var loadingView: MBProgressHUD!
    var userDefault = UserDefault()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        verifyMobileNumberPresenter = VerifyMobileNumberPresenter(repository: Injection.provideUserRepository())
        verifyMobileNumberPresenter.setView(view: self)
        setUI()
        setLocalization()
        setGestures()
        setFonts()
    }
   
//    override var preferredStatusBarStyle: UIStatusBarStyle {
//        return .lightContent
//    }
    
    func setUI(){
      
        textField.delegate = self
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        changeViewsColor(isActive: false)
        coveredView.isHidden = false
        textField.textAlignment = .left
        
//        Timer.scheduledTimer(timeInterval: 300
//            , target: self, selector: #selector(self.enableResend), userInfo: nil, repeats: false)
        Timer.scheduledTimer(timeInterval: 60
            , target: self, selector: #selector(self.enableResend), userInfo: nil, repeats: false)
        textField.becomeFirstResponder()
        if appDelegate.isRTL{
            backImg.image = UIImage(named: "back_ar_ic-1")
            codeCenterConstraint.constant = 25
            firstViewConstraint.constant = 42
            textField.defaultTextAttributes.updateValue(28,
                                                        forKey: NSAttributedString.Key.kern)
        }else{
            backImg.image = UIImage(named: "back_ic-1")
            codeCenterConstraint.constant = 25
            firstViewConstraint.constant = -8
            textField.defaultTextAttributes.updateValue(25.0,
                                                        forKey: NSAttributedString.Key.kern)
        }
    }
    
    func setLocalization(){
        titleLbl.text = "verifyMobile".localized()
        infoLbl.text = "enterDigits".localized()
        submitLbl.text = "submit".localized()
        resendLbl.text = "resendCode".localized()
        textField.text = "0000"
        textField.textColor = Colors.hexStringToUIColor(hex: "#f2f6f8")
    }
    

    
    func setGestures(){
        
        let submitTab = UITapGestureRecognizer(target: self, action: #selector(self.submitPressed))
        submitBgImg.addGestureRecognizer(submitTab)
        
        let submitLblTab = UITapGestureRecognizer(target: self, action: #selector(self.submitPressed))
        submitLbl.addGestureRecognizer(submitLblTab)
        
        let backTab = UITapGestureRecognizer(target: self, action: #selector(self.backPressed))
        backImg.addGestureRecognizer(backTab)
        
        let resendTab = UITapGestureRecognizer(target: self, action: #selector(self.resendPressed))
        resendLbl.addGestureRecognizer(resendTab)
        
        let keyboardTap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        keyboardTap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(keyboardTap)
        
    }
    
    func setFonts(){
        titleLbl.font = Utils.customBoldFont(titleLbl.font.pointSize)
        submitLbl.font = Utils.customBoldFont(submitLbl.font.pointSize)
        infoLbl.font = Utils.customDefaultFont(infoLbl.font.pointSize)
        resendLbl.font = Utils.customDefaultFont(resendLbl.font.pointSize)
        textField.font = Utils.customBoldFont(textField.font!.pointSize)
    }
    
    func changeViewsColor(isActive : Bool){
        if isActive{
            firstView.backgroundColor = Colors.hexStringToUIColor(hex: "#498bca")
            secondView.backgroundColor = Colors.hexStringToUIColor(hex: "#498bca")
            thirdView.backgroundColor = Colors.hexStringToUIColor(hex: "#498bca")
            forthView.backgroundColor = Colors.hexStringToUIColor(hex: "#498bca")

        }else{
            firstView.backgroundColor = Colors.hexStringToUIColor(hex: "#f2f6f8")
            secondView.backgroundColor = Colors.hexStringToUIColor(hex: "#f2f6f8")
            thirdView.backgroundColor = Colors.hexStringToUIColor(hex: "#f2f6f8")
            forthView.backgroundColor = Colors.hexStringToUIColor(hex: "#f2f6f8")
        }
    }
    
    @objc func enableResend(){
        self.isResendAvailable = true
        print("enable resend")
    }
    
    @objc func hideKeyboard(){
        self.view.endEditing(true)
    }
    
    @objc func backPressed(){
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func submitPressed() {
        if coveredView.isHidden{
            if userDefault.getToken() != nil{
                verifyMobileNumberPresenter.updateVerifyMobileNumber(mobileNumber: self.phoneNumber, code: textField.text!)
            }else{
                verifyMobileNumberPresenter.verifyMobileNumber(mobileNumber: self.phoneNumber, code: textField.text!, socialToken: socialToken, isFacebook: isFacebook)
            }
        }
    }
    
    @objc func resendPressed() {
        if userDefault.getToken() != nil{
           verifyMobileNumberPresenter.updateRequestCode(mobileNumber: self.phoneNumber)
        }else{
            verifyMobileNumberPresenter.sendVerificationMsg(mobileNumber: self.phoneNumber)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toUserTabs"{
            let vc = segue.destination as! UserTabBar
            vc.selectedIndex = 2
        }
    }
}

extension VerifyMobileNumberVC{
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0{
            return UITableView.automaticDimension
        }else{
            return 180
        }
    }
    
}

extension VerifyMobileNumberVC : UITextFieldDelegate{
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField.text == "0000"{
            textField.text = ""
            textField.textColor = Colors.hexStringToUIColor(hex: "#498bca")
        }
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.text == ""{
            textField.text = "0000"
            textField.textColor = Colors.hexStringToUIColor(hex: "#f2f6f8")
            changeViewsColor(isActive: false)
        }
        return true
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        //        print("textFieldDidChange \(textField.text?.count)")
        
        textField.text = textField.text?.replacedArabicDigitsWithEnglish
        if textField.text?.count != 0{
            changeViewsColor(isActive: true)
        }else{
            changeViewsColor(isActive: false)
        }
        
        if textField.text == ""{
            textField.text = "0000"
            textField.textColor = Colors.hexStringToUIColor(hex: "#f2f6f8")
        }else{
            textField.textColor = Colors.hexStringToUIColor(hex: "#498bca")
        }
        
        if textField.text?.count == 4 {
            if textField.text == "0000"{
                coveredView.isHidden = false
            }else{
                coveredView.isHidden = true
                submitPressed()
            }
            self.view.endEditing(true)
        }else{
            coveredView.isHidden = false
        }

        if (textField.text?.contains("1"))!{
            let str = textField.text! as NSString
            let pos = str.range(of: "1").location
            print("pos ", pos)
            if pos != 3 {
                if appDelegate.isRTL{
                    textField.defaultTextAttributes.updateValue(32.0,
                                                                forKey: NSAttributedString.Key.kern)
                }else{
                    textField.defaultTextAttributes.updateValue(30.0,
                                                                forKey: NSAttributedString.Key.kern)
                }
            }
        }else{
            print("not found")
            if appDelegate.isRTL{
                textField.defaultTextAttributes.updateValue(28,
                                                            forKey: NSAttributedString.Key.kern)
            }else{
                textField.defaultTextAttributes.updateValue(25.0,
                                                            forKey: NSAttributedString.Key.kern)
            }
            
        }
        
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard let text = textField.text else {
            return true }
        let newLength = text.count + string.count - range.length
        if newLength > 4 {
            self.view.endEditing(true)
        }
        return newLength <= 4
        
    }
}
extension VerifyMobileNumberVC : VerifyMobileNumberView{
   
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
 
    func showInavlidCode() {
        Toast.init(text: "invalidCode".localized()).show()
    }
    
    func showSuccess(data: VerifyCodeData){
        if userDefault.getToken() != nil{ //from change phone number
            print("change phone number")
            if data.user != nil{
                let userData = data.user!
                userDefault.setUserData(userData: userData)
                verifyMobileNumberPresenter.refreshToken()
            }

        }else{ // register with phone for first time
            self.showloading()
            if data.token != nil{
                let token  = "Bearer " + data.token!
                userDefault.setToken(token)
            }
            
            if data.refresh_token != nil{
                userDefault.setRefreshToken(data.refresh_token)
            }
            
            if data.user != nil{
                let userData = data.user!
                if appDelegate.cityName != ""{
                    userData.city = appDelegate.cityName
                }
                userDefault.setUserData(userData: userData)
            }
            
            if data.firebase_token != nil{
                userDefault.setFirebaseToken(data.firebase_token)
                Auth.auth().signIn(withCustomToken: data.firebase_token!) { (user, error) in
                    self.hideLoading()
                    print("result auth signIn")
                    DispatchQueue.main.async {
                        self.checkNavigation(data: data)
                    }
                }
            }else{
                self.hideLoading()
                checkNavigation(data: data)
            }
            
        }
    }
    
    func checkNavigation(data: VerifyCodeData){
        if data.registeredBefore != nil{
            if data.registeredBefore!{
                if data.user != nil{
                    if data.user?.name != nil{
                        if data.user?.name != ""{
                            // registered before and have name
                            performSegue(withIdentifier: "toUserTabs", sender: self)
                        }else{
                            performSegue(withIdentifier: "toEditProfile", sender: self)
                        }
                    }else{
                        performSegue(withIdentifier: "toEditProfile", sender: self)
                    }
                }else{
                    performSegue(withIdentifier: "toEditProfile", sender: self)
                }
                performSegue(withIdentifier: "toUserTabs", sender: self)
            }else{
                performSegue(withIdentifier: "toEditProfile", sender: self)
            }
        }
    }
    
    func showSentCodeSuccess() {
        Toast.init(text: "codeSent".localized()).show()
    }
    
    func showPhoneError() {
        Toast.init(text: "phoneNoError".localized()).show()
    }
    
    func showTimeError(msg : String){
        Toast.init(text: msg).show()
    }
    
    func showSuccessRefreshToken(data : VerifyCodeData){
        
        if data.token != nil{
            let token  = "Bearer " + data.token!
            userDefault.setToken(token)
        }
        
        if data.refresh_token != nil{
            userDefault.setRefreshToken(data.refresh_token)
        }
        
        self.presentingViewController?.presentingViewController?.dismiss(animated: false, completion: nil)
    }
    
    func showSusspendedMsg(msg : String){
        Toast.init(text:msg).show()
    }
}
