//
//  MyAccountVC.swift
//  TwentyfourSeven
//
//  Created by Salma  on 12/6/18.
//  Copyright © 2018 Objects. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import Toaster
import MBProgressHUD
import UserNotifications
import Firebase

class MyAccountVC: UITableViewController {

    @IBOutlet weak var editImg: UIBarButtonItem!
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var rateImg: UIImageView!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var rateLbl: UILabel!
    
    @IBOutlet weak var userRateTitleLbl: UILabel!
    @IBOutlet weak var userRateLbl: UILabel!
    @IBOutlet weak var userRateView: UIView!
    @IBOutlet weak var userStarBottom: NSLayoutConstraint!
    @IBOutlet weak var userRateFullView: UIView!
    @IBOutlet weak var delegateRateTitleLbl: UILabel!
    @IBOutlet weak var delegateRateLbl: UILabel!
    @IBOutlet weak var delegateRateView: UIView!
    @IBOutlet weak var delegateStarBottom: NSLayoutConstraint!
    @IBOutlet weak var delegateRateFullView: UIView!
    
    @IBOutlet weak var walletTitleLbl: UILabel!
    @IBOutlet weak var walletLbl: UILabel!
    @IBOutlet weak var noOfOrdersTitleLbl: UILabel!
    @IBOutlet weak var noOfOrdersLbl: UILabel!
    @IBOutlet weak var carDetailsLbl: UILabel!
    @IBOutlet weak var myAddressesLbl: UILabel!
    @IBOutlet weak var myComplaintLbl: UILabel!
    @IBOutlet weak var myReviewsLbl: UILabel!
    @IBOutlet weak var logoutLbl: UILabel!
    @IBOutlet weak var becomeDriverLbl: UILabel!
    @IBOutlet weak var becomeDriverFirstLbl: UILabel!
    @IBOutlet weak var becomeDriverView: UIView!
    @IBOutlet weak var logoutIcon: UIImageView!
    
    let userDefault = UserDefault()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var myAccountPresenter : MyAccountPresenter!
    var loadingView: MBProgressHUD!
    var isUserRate = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initPresenter()
        
        setUI()
        setLocalization()
        setFonts()
    }
    
    func initPresenter(){
        myAccountPresenter = MyAccountPresenter(repository: Injection.provideUserRepository())
        myAccountPresenter.setView(view: self)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUserData()
    }
    
    
    
    func setUI(){
        
        setCornerRadius(selectedView: profileImg, radius: 10)
        setCornerRadius(selectedView: userRateView, radius: 12)
        setCornerRadius(selectedView: delegateRateView, radius: 12)
        setShadow(selectedView: userRateView)
        setShadow(selectedView: delegateRateView)
        
        rateImg.isHidden = true
        rateLbl.isHidden = true
        
        if appDelegate.isRTL{
            logoutIcon.image = UIImage(named: "logout_ar_ic")
            userStarBottom.constant = -6
            delegateStarBottom.constant = -6
        }else{
            logoutIcon.image = UIImage(named: "logout_ic")
            userStarBottom.constant = -2
            delegateStarBottom.constant = -2
        }
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: Utils.customBoldFont(17), NSAttributedString.Key.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.barStyle = .blackOpaque
        
        becomeDriverView.layer.cornerRadius = 12
        becomeDriverView.layer.masksToBounds = true
        becomeDriverView.clipsToBounds = true
    }
    
    func setLocalization(){
        self.navigationItem.title = "myAccount".localized()
        walletTitleLbl.text = "myWallet".localized()
        //walletLbl.text = "2.000 sr"
        noOfOrdersTitleLbl.text = "noOfOrders".localized()
        carDetailsLbl.text = "carDetailsTitle".localized()
        myAddressesLbl.text = "myAddresses".localized()
        myComplaintLbl.text = "myComplaints".localized()
        myReviewsLbl.text = "myReviews".localized()
        logoutLbl.text = "logout".localized()
        becomeDriverFirstLbl.text = "becomedriverFirst".localized()
        becomeDriverLbl.text = "becomedriverSecond".localized()
        noOfOrdersLbl.text = "200".localized()
        userRateTitleLbl.text = "user_rate".localized()
        delegateRateTitleLbl.text = "delegate_rate".localized()
    }
    
    func setFonts(){
        walletTitleLbl.font = Utils.customDefaultFont(walletTitleLbl.font.pointSize)
        noOfOrdersTitleLbl.font = Utils.customDefaultFont(noOfOrdersTitleLbl.font.pointSize)
        carDetailsLbl.font = Utils.customDefaultFont(carDetailsLbl.font.pointSize)
        myAddressesLbl.font = Utils.customDefaultFont(myAddressesLbl.font.pointSize)
        myComplaintLbl.font = Utils.customDefaultFont(myComplaintLbl.font.pointSize)
        myReviewsLbl.font = Utils.customDefaultFont(myReviewsLbl.font.pointSize)
        logoutLbl.font = Utils.customDefaultFont(logoutLbl.font.pointSize)
        becomeDriverLbl.font = Utils.customDefaultFont(becomeDriverLbl.font.pointSize)
        becomeDriverFirstLbl.font = Utils.customDefaultFont(becomeDriverFirstLbl.font.pointSize)
        noOfOrdersLbl.font = Utils.customBoldFont(noOfOrdersLbl.font.pointSize)
        walletLbl.font = Utils.customBoldFont(walletLbl.font.pointSize)
        userNameLbl.font = Utils.customDefaultFont(userNameLbl.font.pointSize)
        rateLbl.font = Utils.customDefaultFont(rateLbl.font.pointSize)
        userRateTitleLbl.font = Utils.customDefaultFont(userRateTitleLbl.font.pointSize)
        delegateRateTitleLbl.font = Utils.customDefaultFont(delegateRateTitleLbl.font.pointSize)
        userRateLbl.font = Utils.customDefaultFont(userRateLbl.font.pointSize)
        delegateRateLbl.font = Utils.customDefaultFont(delegateRateLbl.font.pointSize)

    }
    
    func setUserData(){
        let userData = userDefault.getUserData()
        
        if userData.name != nil{
            userNameLbl.text = userData.name
        }else{
            userNameLbl.text = ""
        }
        
        if userData.image != nil{
            if userData.image?.medium != nil{
                let url = URL(string: (userData.image?.medium)!)
                print("url \(String(describing: url))")
//                self.profileImg.kf.setImage(with: url, placeholder: UIImage(named: "avatar"), options: [.forceRefresh])
                self.profileImg.kf.setImage(with: url, placeholder: UIImage(named: "avatar"))
            }
        }
        
        
        setUserRate(userData: userData)
        if let balance = userDefault.getUserData().balance {
            setUserWallet(budget: balance)
        }else{
            setUserWallet(budget: 0)
        }
    }
    
    func setUserWallet(budget : Double){
        if budget >= 0 {
            walletLbl.textColor = Colors.hexStringToUIColor(hex: "#4ebf26")
        }else{
            walletLbl.textColor = Colors.hexStringToUIColor(hex: "#e84450")
        }
        
        walletLbl.text = "\(String(format: "%.2f", budget)) \("sar".localized())"

        self.tableView.reloadData()

    }
    
    func setUserRate(userData: UserData){
        if userData.is_delegate != nil{
            if userData.is_delegate!{
                delegateRateFullView.isHidden = false
            }else{
                delegateRateFullView.isHidden = true
            }
        }else{
            delegateRateFullView.isHidden = true
        }
        
        if userData.rating != nil{
            userRateLbl.text = String(format: "%.2f", userData.rating!)
        }else{
            userRateLbl.text = "5.00"
        }
        
        if userData.delegate_rating != nil{
            delegateRateLbl.text = String(format: "%.2f", userData.delegate_rating!)
        }else{
            delegateRateLbl.text = "5.00"
        }
    }
    
    func setCornerRadius(selectedView : UIView, radius: CGFloat){
        selectedView.layer.cornerRadius = radius
        selectedView.layer.masksToBounds = true
        selectedView.clipsToBounds = true
    }
    
    func setShadow(selectedView : UIView){
        selectedView.layer.borderColor = UIColor.lightGray.cgColor
        selectedView.layer.borderWidth = 0
        selectedView.layer.masksToBounds = false
        selectedView.layer.shadowOffset = CGSize(width: 2, height: 2)
        selectedView.layer.shadowRadius = 3
        selectedView.layer.shadowOpacity = 0.1
    }
    
    @IBAction func editProfileAction(_ sender: Any) {
        performSegue(withIdentifier: "toEditProfile", sender: self)
    }
    
    @IBAction func userRateAction(_ sender: Any) {
        self.isUserRate = true
        performSegue(withIdentifier: "toMyReviews", sender: self)
    }

    @IBAction func delegateRateAction(_ sender: Any) {
        self.isUserRate = false
        performSegue(withIdentifier: "toMyReviews", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toEditProfile"{
            let editNavigationController = segue.destination as! UINavigationController
            let editVC = editNavigationController.topViewController as! EditProfileVC
            editVC.isFromMyAccount = true
        }else if segue.identifier == "toMyReviews"{
            let navigationController = segue.destination as! UINavigationController
            let reviewsVC = navigationController.topViewController as!  MyReviewsVC
            reviewsVC.isUser = self.isUserRate
        }
    }
}

extension MyAccountVC{
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0{
            return UITableView.automaticDimension
        }else if indexPath.row == 3{
            if userDefault.getUserData().is_delegate != nil{
                if userDefault.getUserData().is_delegate!{
                    return 70
                }else{
                    return 0
                }
            }else{
                return 0
            }
        }else if indexPath.row == 4 || indexPath.row == 1 || indexPath.row == 5{
            return 70
        }else if indexPath.row == 7{
            return 70
        }else if indexPath.row == 8{
            let profileHeight = 145 + userNameLbl.intrinsicContentSize.height
            let calculatedHeight = 70*6 + profileHeight
            
            if userDefault.getUserData().is_delegate != nil{
                if userDefault.getUserData().is_delegate!{
                    return 0
                }else{
                    if tableView.bounds.size.height - calculatedHeight > 0{
                        return tableView.bounds.size.height - calculatedHeight
                    }else{
                        return 0
                    }
                }
            }else{
                if tableView.bounds.size.height - calculatedHeight > 0{
                    return tableView.bounds.size.height - calculatedHeight
                }else{
                    return 0
                }
            }
        }else if indexPath.row == 9{
            if userDefault.getUserData().is_delegate != nil{
                if userDefault.getUserData().is_delegate!{
                    return 0
                }else{
                    return 70
                }
            }else{
                return 70
            }
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 7{ //logout
            if userDefault.getPlayerID() != nil{
                self.myAccountPresenter.unRegisterPushNotifications()
            }else{
                self.unRegisterSuccessfully()
            }
        }else if indexPath.row == 3{
            performSegue(withIdentifier: "toCarDetails", sender: self)
        }else if indexPath.row == 4{
            performSegue(withIdentifier: "toMyAddresses", sender: self)
        }else if indexPath.row == 5{
            performSegue(withIdentifier: "toMyComplaints", sender: self)
        }else if indexPath.row == 9{
            if userDefault.getUserData().has_delegate_request != nil{
                if userDefault.getUserData().has_delegate_request!{
                    Toast.init(text: "requestAlreadySent".localized()).show()
                }else{
                    performSegue(withIdentifier: "toBecomeADelegate", sender: self)
                }
            }else{
                performSegue(withIdentifier: "toBecomeADelegate", sender: self)
            }
        }else if indexPath.row == 1{
            if userDefault.getUserData().is_delegate != nil{
                if userDefault.getUserData().is_delegate!{
                    self.performSegue(withIdentifier: "BalanceDetails", sender: self)
                }
            }
        }
    }
}

extension MyAccountVC : MyAccountView{
    
    func showloading() {
        if(loadingView != nil) {
            loadingView.hide(animated: true)
            loadingView = nil
        }
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
    
    func showSusspendedMsg(msg : String){
        Toast.init(text:msg).show()
    }
    
    func unRegisterSuccessfully(){
        
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            center.removeAllDeliveredNotifications()
        }
        
        if (FBSDKAccessToken.current() != nil){
            let login = FBSDKLoginManager()
            login.logOut()
            FBSDKAccessToken.setCurrent(nil)
            FBSDKProfile.setCurrent(nil)
        }
        
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        
        userDefault.removeSession()
    }
    
}
