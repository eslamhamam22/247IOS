//
//  RegisterViaMobileVC.swift
//  TwentyfourSeven
//
//  Created by Salma  on 12/2/18.
//  Copyright © 2018 Objects. All rights reserved.
//

import UIKit
import SKCountryPicker
import Foundation
import MBProgressHUD
import Toaster

class RegisterViaMobileVC: UITableViewController {

    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var arrowImg: UIImageView!
    @IBOutlet weak var backImg: UIImageView!
    @IBOutlet weak var countryImg: UIImageView!
    @IBOutlet weak var countryCodeLbl: UILabel!
    @IBOutlet weak var phoneNumberTF: UITextField!
    @IBOutlet weak var verifyLbl: UILabel!
    @IBOutlet weak var verifyView: UIView!
    @IBOutlet weak var countryCodeConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var backTrailingConstarint: NSLayoutConstraint!
    @IBOutlet weak var backLeadingConstranit: NSLayoutConstraint!
    let contryPickerController = CountryPickerController()
    var registerViaMobilePresenter : RegisterViaMobilePresenter!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let useDefault = UserDefault()
    var locationManager = LocationManager()

    var isArabic = false
    var loadingView: MBProgressHUD!

    var phoneNumber = ""
    var isFacebook = false
    var socialToken = ""
    var isFromCodesVC = false
    var countryCode = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        registerViaMobilePresenter = RegisterViaMobilePresenter(repository: Injection.provideUserRepository())
        registerViaMobilePresenter.setView(view: self)
        
        // get user location to get current country
        locationManager.determineMyCurrentLocation(isNeedCountryCode: true)

        if appDelegate.isRTL{
            isArabic = true
        }
        
        self.showloading()

        setGestures()
        setUI()
        setLocalization()
        setFonts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillAppear")
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.getUserLocation), name: NSNotification.Name(rawValue: "gotLocation"), object: nil)

        
        if isArabic{
            // set language arabic
            self.useDefault.setLanguage("ar")
            self.appDelegate.initLanguage()
            UIView.appearance().semanticContentAttribute = UISemanticContentAttribute.forceLeftToRight
            backImg.semanticContentAttribute = UISemanticContentAttribute.forceLeftToRight
            if backLeadingConstranit != nil{
                backLeadingConstranit.isActive = false
            }
            backTrailingConstarint.constant = 10
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "gotLocation"), object: nil)

        if isArabic && !isFromCodesVC{
            UIView.appearance().semanticContentAttribute = UISemanticContentAttribute.forceRightToLeft
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func setUI(){
        verifyView.layer.cornerRadius = 10
        verifyView.layer.masksToBounds = true
        verifyView.clipsToBounds = true
        
        phoneNumberTF.attributedPlaceholder = NSAttributedString(string: "phoneNo".localized(),
                                                               attributes: [NSAttributedString.Key.foregroundColor: Colors.hexStringToUIColor(hex: "#498bca")])
        
        phoneNumberTF.textAlignment = .left

        if appDelegate.isRTL{
            backImg.image = UIImage(named: "back_ar_ic")
            
        }else{
            backImg.image = UIImage(named: "back_ic")

        }
    }
    
    func setLocalization(){
        if useDefault.getToken() != nil{
            titleLbl.text = "changePhone".localized()
        }else{
            titleLbl.text = "registerViaMobile".localized()
        }
        verifyLbl.text = "verify".localized()
    }
    
    func setFonts(){
        
        titleLbl.font = Utils.customBoldFont(titleLbl.font.pointSize)
        verifyLbl.font = Utils.customBoldFont(verifyLbl.font.pointSize)
        phoneNumberTF.font = Utils.customDefaultFont((phoneNumberTF.font?.pointSize)!)
        countryCodeLbl.font = Utils.customDefaultFont(countryCodeLbl.font.pointSize)
    }
    
    func setGestures(){
        
        let countryTab = UITapGestureRecognizer(target: self, action: #selector(self.countryCodeButtonClicked))
        countryImg.addGestureRecognizer(countryTab)
        
        let arrowTab = UITapGestureRecognizer(target: self, action: #selector(self.countryCodeButtonClicked))
        arrowImg.addGestureRecognizer(arrowTab)
        
        let backTab = UITapGestureRecognizer(target: self, action: #selector(self.backPressed))
        backImg.addGestureRecognizer(backTab)
        
        let verifyTab = UITapGestureRecognizer(target: self, action: #selector(self.verifyAction))
        verifyView.addGestureRecognizer(verifyTab)
        
        let verifyLblTab = UITapGestureRecognizer(target: self, action: #selector(self.verifyAction))
        verifyLbl.addGestureRecognizer(verifyLblTab)
        
        let keyboardTap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        keyboardTap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(keyboardTap)

//        NotificationCenter.default.addObserver(self,
//                                               selector: #selector(self.keyboardWillShow(notification:)),
//                                               name: UIResponder.keyboardWillShowNotification, object: nil)
//        NotificationCenter.default.addObserver(self,
//                                               selector: #selector(self.keyboardWillHide(notification:)),
//                                               name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
//    @objc func keyboardWillShow(notification: NSNotification) {
//        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue{
//            print("keyboardSize.height \(keyboardSize.height)")
//            countryImgCenter.constant = -105
//        }
//    }
//    @objc func keyboardWillHide(notification: NSNotification) {
//        if ((notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue) != nil {
//            countryImgCenter.constant = 0
//        }
//    }
    
    func setCountryCode(countryCode : String){
        let country = Country(countryCode: countryCode)
      
        countryCodeLbl.text = country.dialingCode
        countryCodeConstraint.constant = self.countryCodeLbl.intrinsicContentSize.width
        countryImg.image = country.flag
    }
    
    @objc func hideKeyboard(){
        self.view.endEditing(true)
    }
    
    @objc func backPressed(){
        self.dismiss(animated: false, completion: nil)
    }
    
    @objc func verifyAction(){
        self.view.endEditing(true)
        if phoneNumberTF.text?.replacedArabicDigitsWithEnglish != nil && countryCodeLbl.text != nil{
            self.phoneNumber = countryCodeLbl.text! + (phoneNumberTF.text?.replacedArabicDigitsWithEnglish)! 
            print("phone: \(phoneNumberTF.text!.replacedArabicDigitsWithEnglish)")
            if phoneNumberTF.text != ""{
                if useDefault.getToken() != nil{
                    registerViaMobilePresenter.updateRequestCode(mobileNumber: (phoneNumberTF.text?.replacedArabicDigitsWithEnglish)!, countryCode: self.countryCodeLbl.text!)
                }else{
                     registerViaMobilePresenter.sendVerificationMsg(mobileNumber: (phoneNumberTF.text?.replacedArabicDigitsWithEnglish)!, countryCode: self.countryCodeLbl.text!)
                }
            }else{
                showEmptyMobileNumber()
            }
        }else{
            showGeneralError()
        }
    }
    
    @objc func getUserLocation()
    {
        self.hideLoading()
        
        self.appDelegate.cityName = locationManager.city

        if locationManager.locationStatus == "denied"{
            Toast(text: "permissionDenied".localized()).show()
        }
        
        if self.countryCode == "" || self.countryCode == "Error"{
            print("user location in home \(locationManager.countryCode)")
            self.countryCode = locationManager.countryCode
            if self.countryCode == ""{
                self.setCountryCode(countryCode: "SA")
            }else if self.countryCode != "Error"{
                self.setCountryCode(countryCode: self.countryCode)
            }else{
                self.setCountryCode(countryCode: "SA")
            }
        }
    }
    
    @objc func countryCodeButtonClicked() {
        
        let countryController = CountryPickerWithSectionViewController.presentController(on: self) { (country: Country) in
            self.countryImg.image = country.flag
            self.countryCodeLbl.text = country.dialingCode
            self.countryCodeConstraint.constant = self.countryCodeLbl.intrinsicContentSize.width
            self.isFromCodesVC = false
        }
        // can customize the countryPicker here e.g font and color
        countryController.detailColor = UIColor.red
        countryController.separatorLineColor = UIColor.clear
        // set language english
        if isArabic {
            self.isFromCodesVC = true
            self.useDefault.setLanguage("en")
            self.appDelegate.initLanguage()
        }
//        countryController.navigationController?.navigationBar.barTintColor = UIColor.red
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toVerifyMobile"{
            let verifyVC = segue.destination as! VerifyMobileNumberVC
            verifyVC.phoneNumber = self.phoneNumber
            verifyVC.isFacebook = self.isFacebook
            verifyVC.socialToken = self.socialToken
            
        }
    }
}

extension RegisterViaMobileVC{
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0{
            return UITableView.automaticDimension
        }else{
            return 200
        }
    }
}

extension RegisterViaMobileVC : RegisterViaMobileView{
    
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
    
    func showEmptyMobileNumber() {
        Toast.init(text: "emptyPhoneNumber".localized()).show()
    }
    
    func showPhoneError() {
        Toast.init(text: "phoneNoError".localized()).show()
    }
    
    func navigateToVerify(){
//        Toast.init(text: "codeSent".localized()).show()
        performSegue(withIdentifier: "toVerifyMobile", sender: self)
    }
    
    func showTimeError(msg : String){
        Toast.init(text: msg).show()
    }
    
    func showSusspendedMsg(msg : String){
        Toast.init(text:msg).show()
    }
}
