//
//  LoginVC.swift
//  TwentyfourSeven
//
//  Created by Dina Ragab on 11/29/18.
//  Copyright © 2018 Objects. All rights reserved.
//

import UIKit
//import GoogleSignIn
import MBProgressHUD
import Toast_Swift
import Toaster
import Firebase

class LoginVC: UITableViewController  {
    
    @IBOutlet weak var titleLbl: UILabel!
    
    @IBOutlet weak var mobileLbl: UILabel!
    @IBOutlet weak var mobileBgImg: UIImageView!
    
    @IBOutlet weak var googleLbl: UILabel!
    @IBOutlet weak var googleBgImg: UIImageView!
    
    @IBOutlet weak var facebookLbl: UILabel!
    @IBOutlet weak var facebookBgImg: UIImageView!

    @IBOutlet weak var infoLbl: UILabel!
    @IBOutlet weak var termsAndConditionsLbl: UILabel!
    @IBOutlet weak var skipLoginLbl: UILabel!

    var loginPresenter : LoginPresenter!
    var loadingView: MBProgressHUD!
    var isFacebook = false
    var socialToken = ""
    var userDefault = UserDefault()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        GIDSignIn.sharedInstance().uiDelegate = self
        loginPresenter = LoginPresenter(repository: Injection.provideUserRepository())
        loginPresenter.setView(view: self)
        
        if let countryCode = (Locale.current as NSLocale).object(forKey: .countryCode) as? String {
            print(countryCode)
        }
        
        if userDefault.getPlayerID() != nil{
            loginPresenter.unregisterPlayerId()
        }
        
        logoutFirebase()
        setUI()
        setLocalization()
        setGestures()
        setFonts()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func setUI(){
        //set status bar background to red
//        let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
//        if statusBar.responds(to:#selector(setter: UIView.backgroundColor)) {
//            statusBar.backgroundColor = Colors.hexStringToUIColor(hex: "E84450")
//
        // Add a background view to the table view
//        let backgroundImage = UIImage(named: "bg")
//        let imageView = UIImageView(image: backgroundImage)
//        imageView.contentMode = .scaleToFill
////        imageView.frame = self.tableView.frame
//        imageView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
//
//        self.tableView.backgroundView = imageView
        
    }
    
    func setGestures(){
        
        let mobileLoginTab = UITapGestureRecognizer(target: self, action: #selector(self.loginWithMobile))
        mobileBgImg.addGestureRecognizer(mobileLoginTab)
        
        let googleLoginTab = UITapGestureRecognizer(target: self, action: #selector(self.loginWithGoogle))
        googleBgImg.addGestureRecognizer(googleLoginTab)
        
        let FBloginTab = UITapGestureRecognizer(target: self, action: #selector(self.loginWithFacebook))
        facebookBgImg.addGestureRecognizer(FBloginTab)
        
        let termsAndConditionsTab = UITapGestureRecognizer(target: self, action: #selector(self.navigateToTermsAndCoditions))
        termsAndConditionsLbl.addGestureRecognizer(termsAndConditionsTab)
        
        let termsAndConditionsTitleTab = UITapGestureRecognizer(target: self, action: #selector(self.navigateToTermsAndCoditions))
        infoLbl.addGestureRecognizer(termsAndConditionsTitleTab)
        
        
        let skipLoginTab = UITapGestureRecognizer(target: self, action: #selector(self.skipLoginAction))
        skipLoginLbl.addGestureRecognizer(skipLoginTab)
    }
    
    func setLocalization(){
        
        titleLbl.text = "loginTitle".localized()
        mobileLbl.text = "loginMobile".localized()
        facebookLbl.text = "loginFB".localized()
        googleLbl.text = "loginGoogle".localized()
        infoLbl.text = "termsTitle".localized()
        termsAndConditionsLbl.text = "termsAndConditions".localized()
        skipLoginLbl.text = "skipLogin".localized()
    }
    
    func setFonts(){
        titleLbl.font = Utils.customBoldFont(titleLbl.font.pointSize)
        mobileLbl.font = Utils.customBoldFont(mobileLbl.font.pointSize)
        facebookLbl.font = Utils.customBoldFont(facebookLbl.font.pointSize)
        googleLbl.font = Utils.customBoldFont(googleLbl.font.pointSize)
        infoLbl.font = Utils.customDefaultFont(infoLbl.font.pointSize)
        termsAndConditionsLbl.font = Utils.customDefaultFont(termsAndConditionsLbl.font.pointSize)
        skipLoginLbl.font = Utils.customDefaultFont(skipLoginLbl.font.pointSize)
    }
    
    func logoutFirebase(){
        // logout from firebase
        let firebaseAuth = Auth.auth()
        do{
            try firebaseAuth.signOut()
        }catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    @objc func loginWithMobile()
    {
        performSegue(withIdentifier: "toRegisterMobile", sender: self)
    }
    
    @objc func loginWithGoogle()
    {
        loginPresenter.LoginWithGoogle()
    }

    @objc func loginWithFacebook()
    {
        loginPresenter.LoginWithFacebook(self)
    }
    
    @objc func navigateToTermsAndCoditions(){
        performSegue(withIdentifier: "toTermsAndConditions", sender: self)
    }
    
    @objc func skipLoginAction(){
        performSegue(withIdentifier: "toTabs", sender: self)
    }
    
//    public func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
//        self.present(viewController, animated: true, completion: nil)
//    }
//
//    public func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
//        viewController.dismiss(animated: true, completion: nil)
//    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toRegisterMobile" {
            let registerMobileVC = segue.destination as! RegisterViaMobileVC
            registerMobileVC.isFacebook = self.isFacebook
            registerMobileVC.socialToken = self.socialToken
        }else if segue.identifier == "toTabs"{
            let vc = segue.destination as! UserTabBar
            vc.selectedIndex = 2
        }
    }
}

extension LoginVC {
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0{
            return 170
        }else if indexPath.row == 1{
            return 145
        }else if indexPath.row == 5{
            return 110
        }else if indexPath.row == 6{
            print("height: \(tableView.bounds.size.height)")
            if tableView.bounds.size.height >= 896.0{
                return 80 + ((tableView.bounds.size.height - 667.0)/2)
            }else if tableView.bounds.size.height > 667.0{
                return 80 + ((tableView.bounds.size.height - 667.0)/3) - 5
            }
            return 80
            
        }else if indexPath.row == 7{
            print("height: \(tableView.bounds.size.height)")
            print("screen height: \(screenHeight)")
            if tableView.bounds.size.height > 800 {
                if tableView.bounds.size.height == 812{ // iphone x
                    return 35
                }
                return 40
            }else if tableView.bounds.size.height == 736.0{
                return 10
//            }else{
//                return 40
            }
            return 0

        }else if indexPath.row == 8{
            return 80
//            return 0
        }else if indexPath.row == 3 || indexPath.row == 4{ //google and facebook
            return 0
        }
        return 70
    }
    // Screen height.
    public var screenHeight: CGFloat {
        return UIScreen.main.bounds.height
    }
}

extension LoginVC : LoginView{
  
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
   
    func showInavlidToken() {
        Toast.init(text: "general_error".localized()).show()
    }
    
    func showSuccess(isRegisteredBefore : Bool, token: String, isFacebook: Bool, data : VerifyCodeData){
        self.socialToken = token
        self.isFacebook = isFacebook
        if !isRegisteredBefore{
            performSegue(withIdentifier: "toRegisterMobile", sender: self)
        }else{
            saveUserData(data: data)
        }
    }
    
    func saveUserData(data: VerifyCodeData){
        
        self.showloading()
        if data.token != nil{
            let token  = "Bearer " + data.token!
            userDefault.setToken(token)
        }
        
        if data.refresh_token != nil{
            userDefault.setRefreshToken(data.refresh_token)
        }
        
        if data.user != nil{
            userDefault.setUserData(userData: data.user!)
        }
        
        if data.firebase_token != nil{
            userDefault.setFirebaseToken(data.firebase_token)
            Auth.auth().signIn(withCustomToken: data.firebase_token!) { (user, error) in
                self.hideLoading()
                print("result auth signIn")
                DispatchQueue.main.async {
                    self.navigateToHome()
                }
            }
        }else{
            self.hideLoading()
            self.navigateToHome()
        }
    }
    
    func navigateToHome(){
        performSegue(withIdentifier: "toTabs", sender: self)
    }
    
    func showSusspendedMsg(msg : String){
        Toast.init(text:msg).show()
    }
    
}
