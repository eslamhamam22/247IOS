//
//  NotificationListVC.swift
//  TwentyfourSeven
//
//  Created by Dina Ragab on 1/9/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import UIKit
import Toaster
import MBProgressHUD
import UIScrollView_InfiniteScroll

class NotificationListVC: UIViewController {
    
    @IBOutlet weak var notificationSwitchImg: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    //@IBOutlet weak var notificationSwtitch: UISwitch!
    @IBOutlet weak var noDataView: UIView!
    @IBOutlet weak var noDataLbl: UILabel!
    @IBOutlet weak var notificationStatuslbl: UILabel!
    
    //no network
    @IBOutlet weak var noNetworkView: UIView!
    @IBOutlet weak var noNetworkTitleLbl: UILabel!
    @IBOutlet weak var noNetworkDescLbl: UILabel!
    @IBOutlet weak var noNetworkReloadLbl: UILabel!
    @IBOutlet weak var noNetworkReloadImg: UIImageView!
    
    var userDefault = UserDefault()
    var loadingView: MBProgressHUD!
    var notifications = [Notification]()
    var notificationListPresenter : NotificationListPresenter!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var unseenNotificationCount = 0
    var selectedOrderId = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        initPresenter()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        intializeNotificationList()
    }
    
    func intializeNotificationList(){
        self.noDataView.isHidden = true
        self.tableView.isHidden = true
        notificationListPresenter.resetData()
        notificationListPresenter.getUserNotifications()
    }
    
    func initPresenter(){
        notificationListPresenter = NotificationListPresenter(repository: Injection.provideUserRepository())
        notificationListPresenter.setView(view: self)
    }
    
    func setUI(){
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.noDataView.isHidden = true
        self.noNetworkView.isHidden = true
        
       setupNotificationSwitch()
       setStrings()
        setFonts()
        setGesture()
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: Utils.customBoldFont(17), NSAttributedString.Key.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.barStyle = .blackOpaque
        self.tableView.addInfiniteScroll { (scrollView) -> Void in
            self.notificationListPresenter.getUserNotifications()
        }
    }
    
    func setStrings(){
        self.navigationItem.title = "notifications_screen_title".localized()
        noDataLbl.text = "no_data".localized()
        notificationStatuslbl.text = "notifications_title".localized()
        
        noNetworkTitleLbl.text = "no_network_title".localized()
        noNetworkDescLbl.text = "no_network_desc".localized()
        noNetworkReloadLbl.text = "no_network_reload".localized()
    }
    
    func setFonts(){
        noDataLbl.font = Utils.customDefaultFont(noDataLbl.font.pointSize)
        notificationStatuslbl.font = Utils.customDefaultFont(notificationStatuslbl.font.pointSize)
        
        noNetworkTitleLbl.font = Utils.customBoldFont(noNetworkTitleLbl.font.pointSize)
        noNetworkDescLbl.font = Utils.customDefaultFont(noNetworkDescLbl.font.pointSize)
        noNetworkReloadLbl.font = Utils.customDefaultFont(noNetworkReloadLbl.font.pointSize)
    }
    
    func setGesture(){
        let reloadTap = UITapGestureRecognizer(target: self, action: #selector(reloadAction))
        noNetworkReloadImg.addGestureRecognizer(reloadTap)
        
        let reloadLblTap = UITapGestureRecognizer(target: self, action: #selector(reloadAction))
        noNetworkReloadLbl.addGestureRecognizer(reloadLblTap)
    }
    
    func setupNotificationSwitch(){
        
        let switchTab = UITapGestureRecognizer(target: self, action: #selector(self.switchIsChanged))
        notificationSwitchImg.addGestureRecognizer(switchTab)
        
        if userDefault.getUserData().notifications_enabled != nil{
            if userDefault.getUserData().notifications_enabled!{
                notificationSwitchImg.image = UIImage(named: "switch_on")
            }else{
                notificationSwitchImg.image = UIImage(named: "switch_off")
            }
        }else{
            notificationSwitchImg.image = UIImage(named: "switch_on")
        }
        
    }
    
    @objc func switchIsChanged() {
        if userDefault.getUserData().notifications_enabled != nil{
            if self.userDefault.getUserData().notifications_enabled!{
                notificationListPresenter.changeNotificationStatus(status: false)
            }else {
                notificationListPresenter.changeNotificationStatus(status: true)
            }
        }else{
            notificationListPresenter.changeNotificationStatus(status: false)
        }
    }

    @objc func reloadAction(){
        notificationListPresenter.getUserNotifications()
    }
    
    func getFormattedDate(dateTxt : String) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ" //Your date format
        //dateFormatter.timeZone = TimeZone(abbreviation: "GMT+0:00") //Current time zone
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale?
        let date = dateFormatter.date(from: dateTxt)
        if date != nil{
            if(appDelegate.isRTL) {
                dateFormatter.locale = NSLocale(localeIdentifier: "ar_EG") as Locale?
            }else{
                dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale?
            }
            dateFormatter.dateFormat = "dd MMM yyyy h:mm a"
            
            let dateString = dateFormatter.string(from: date!)
            return dateString
        }
        
        return ""
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDelegateOrder"{
            let navigationVC = segue.destination as! UINavigationController
            let vc = navigationVC.topViewController as! DelegateOrderDetailsVC
            vc.orderID = selectedOrderId
        }else if segue.identifier == "toUserOrder"{
            let navigationVC = segue.destination as! UINavigationController
            let vc = navigationVC.topViewController as! UserOrderDetailsVC
            vc.orderID = selectedOrderId
        }
    }
}
extension NotificationListVC : UITableViewDelegate , UITableViewDataSource{
    
  
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return notifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let dateLbl = cell.contentView.viewWithTag(1) as! UILabel
        let notificationsContent = cell.contentView.viewWithTag(2) as! UILabel
        let notificationDotImg = cell.contentView.viewWithTag(3) as! UIImageView

        dateLbl.font = Utils.customDefaultFont(dateLbl.font.pointSize)
        notificationsContent.font = Utils.customDefaultFont(notificationsContent.font.pointSize)
        cell.contentView.backgroundColor = UIColor.white

        if self.notifications[indexPath.row].created_at != nil{
            dateLbl.text = getFormattedDate(dateTxt : self.notifications[indexPath.row].created_at!)
        }else{
            dateLbl.text = ""
        }
        
        if self.notifications[indexPath.row].message != nil{
            notificationsContent.text = self.notifications[indexPath.row].message!
        }else{
            notificationsContent.text = ""
        }
        
        if indexPath.row < self.unseenNotificationCount{
            //unseen notification
            notificationsContent.textColor = Colors.hexStringToUIColor(hex: "3f4247")
            notificationDotImg.isHidden = false
           
        }else{
            //seen notification
            notificationDotImg.isHidden = true
            notificationsContent.textColor = Colors.hexStringToUIColor(hex: "#8A949D")
           
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if notifications[indexPath.row].link_to != nil{
            if self.notifications[indexPath.row].link_to! == "account"{
                self.tabBarController?.selectedIndex = 3
            }else if self.notifications[indexPath.row].link_to! == "orders"{
                self.tabBarController?.selectedIndex = 1
            }else if self.notifications[indexPath.row].link_to! == "delegate_order_details"{
                if notifications[indexPath.row].order != nil{
                    if notifications[indexPath.row].order?.id != nil{
                        self.selectedOrderId = (notifications[indexPath.row].order?.id)!
                        performSegue(withIdentifier: "toDelegateOrder", sender: self)
                    }
                }
            }else if self.notifications[indexPath.row].link_to! == "order_details"{
                if notifications[indexPath.row].order != nil{
                    if notifications[indexPath.row].order?.id != nil{
                        self.selectedOrderId = (notifications[indexPath.row].order?.id)!
                        performSegue(withIdentifier: "toUserOrder", sender: self)
                    }
                }
            }
        }
    }
}

extension NotificationListVC : NotificationListView{
    
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
        }else{
            tableView.finishInfiniteScroll()
        }
    }
    
    func showNetworkError() {
//        Toast.init(text: "connectionFailed".localized()).show()
        self.noNetworkView.isHidden = false
        self.tableView.isHidden = true
        self.noDataView.isHidden = true

    }
    
    func showGeneralError() {
        Toast.init(text: "general_error".localized()).show()
    }
    
    func showSusspendedMsg(msg : String){
        Toast.init(text:msg).show()
    }
    
    func setNotifications(notifications : [Notification] , unseenMsgsCount : Int){
        self.noDataView.isHidden = true
        self.noNetworkView.isHidden = true
        self.tableView.isHidden = false
//        self.notifications = notifications.reversed()
        self.notifications = notifications
        self.unseenNotificationCount = unseenMsgsCount
        self.tableView.reloadData()
        notificationListPresenter.maskNotificationsAsSeen()
    }
    
    func showNoData(){
        self.noDataView.isHidden = false
        self.tableView.isHidden = true
        self.noNetworkView.isHidden = true
    }
    
    func stopInfinitScroll(){
        self.tableView.removeInfiniteScroll()
    }
    
    func changeNotificationStatusSuccessfully(userData : UserData){
        print("changeNotificationStatusSuccessfully")
        if notificationSwitchImg.image == UIImage(named: "switch_on"){
            UIView.transition(with: notificationSwitchImg, duration: 0.2, options: .transitionCrossDissolve, animations: {
                self.notificationSwitchImg.image = UIImage(named: "switch_off")
            }, completion: nil)
        }else if notificationSwitchImg.image == UIImage(named: "switch_off"){
            UIView.transition(with: notificationSwitchImg, duration: 0.2, options: .transitionCrossDissolve, animations: {
                self.notificationSwitchImg.image = UIImage(named: "switch_on")
            }, completion: nil)
        }

        if userData.notifications_enabled != nil{
            let user = userDefault.getUserData()
            user.notifications_enabled = userData.notifications_enabled!
            self.userDefault.setUserData(userData: user)

        }
    }
    
    func markNotificationSeenSuccessfully(){
        print("markNotificationSeenSuccessfully")
        let user = userDefault.getUserData()
        user.unseen_notifications_count  = 0
        self.userDefault.setUserData(userData: user)
        userDefault.setNotificationUnread(false)
        if self.tabBarController != nil{
            if let userTabBar = self.tabBarController as? UserTabBar{
                userTabBar.checkunreadNotifications()
            }
        }

    }
}
