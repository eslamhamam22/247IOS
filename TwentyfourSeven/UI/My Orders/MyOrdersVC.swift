//
//  MyOrdersVC.swift
//  TwentyfourSeven
//
//  Created by Dina Ragab on 2/5/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import UIKit
import Toaster
import MBProgressHUD
import UIScrollView_InfiniteScroll
import CoreLocation

class MyOrdersVC: UIViewController {
    
    @IBOutlet weak var noNwView: UIView!
    @IBOutlet weak var noNetworkTitleLbl: UILabel!
    @IBOutlet weak var noNetworkDescLbl: UILabel!
    @IBOutlet weak var noNetworkReloadLbl: UILabel!
    @IBOutlet weak var noNetworkReloadImg: UIImageView!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tabs: UIView!
    @IBOutlet weak var TabsView: NSLayoutConstraint!
    @IBOutlet weak var requestsLbl: UILabel!
    @IBOutlet weak var requestsLine: UIView!
    @IBOutlet weak var requestsView: UIView!
    @IBOutlet weak var myOrdersLbl: UILabel!
    @IBOutlet weak var myOrdersLine: UIView!
    @IBOutlet weak var myOrdersView: UIView!
    @IBOutlet weak var enableRequestsView: UIView!
    @IBOutlet weak var enableReuestsSwitchImg: UIImageView!
    @IBOutlet weak var enableRequestsLbl: UILabel!
    @IBOutlet weak var enableRequestsViewHeight: NSLayoutConstraint!
    
    var userDefault = UserDefault()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var addMoneyView = UIView()
    
    //To determine user click on which tab (driver/user)
    var isUser = true
    var myOrdersPresenter : MyOrdersPresenter!
    var loadingView: MBProgressHUD!
    
    var userCurrentOrders = [Order]()
    var userPastOrders = [Order]()
    
    var delegateCurrentOrders = [Order]()
    var delegatePastOrders = [Order]()
    
    //this flag to indicate end of table view scroll in user tab only
    var endUserInfiniteScroll = false
    //this flag to indicate end of table view scroll in delegate tab only
    var endDelegateInfiniteScroll = false
    //this flag to indicate that we got delegate api response
    var gotDelegateData = false
    //this flag to indicate that we got user api response
    var gotUserData = false
    
    //the max number of current orders
    var maxCurrentOrdersNum = 2
    var locationManager = LocationManager()
    let databaseManager = DatabaseManager()
    
    var selectedOrder = Order()
    //this flag to indicate that we delegate hax reached max wallet balance
    var delegateReachedMax = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initPresenter()
        setUI()
        setFonts()
        setStrings()
        setGestures()
    }
    
    func initPresenter(){
        myOrdersPresenter = MyOrdersPresenter(repository: Injection.provideDelegateRepository(), userRepository: Injection.provideUserRepository())
        myOrdersPresenter.setView(view: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //to determine user/delegate
        checkUserType()
        setupRequestsSwitch()
        
        if self.appDelegate.isNotificationAllowed && !appDelegate.myOrdersNeedUpdate{
            if isUser{
                selectMyOrders()
            }else{
                selectRequests()
            }
        }else{
            //if user disallowed app notification permission
            appDelegate.myOrdersNeedUpdate = false
            self.myOrdersPresenter.resetData()
            self.resetData()
        }
        
    }
    
    func checkDelgateMaximumBalance(){
        if !isUser{
            if let maximumBalance = self.userDefault.getMaximumBalance(){
                if let balance = userDefault.getUserData().balance {
                    if -balance > maximumBalance{
                        delegateReachedMax = true
                    }
                }
            }
        }
    }
    
    func setUI(){
        setupTableView()
        if appDelegate.isRTL{
            let layer = self.myOrdersView.layer
            layer.addBorder(edge: .left, color: Colors.hexStringToUIColor(hex: "#bcc5d3"), thickness: 0.5)
        }else{
            let layer = self.requestsView.layer
            layer.addBorder(edge: .left, color: Colors.hexStringToUIColor(hex: "#bcc5d3"), thickness: 0.5)
        }
        self.tableView.isHidden = true
        self.noNwView.isHidden = true
    }
    
    
    func setupRequestsSwitch(){
        
        let switchTab = UITapGestureRecognizer(target: self, action: #selector(self.switchIsChanged))
        enableReuestsSwitchImg.addGestureRecognizer(switchTab)
        
        if (self.userDefault.getUserData().delegate_details?.active) != nil{
            if (self.userDefault.getUserData().delegate_details?.active)!{
                enableReuestsSwitchImg.image = UIImage(named: "switch_on")
            }else{
                enableReuestsSwitchImg.image = UIImage(named: "switch_off")
            }
        }else{
            enableReuestsSwitchImg.image = UIImage(named: "switch_off")
        }
        
        
    }
    
    @objc func addMoney(){
        print("addMoney")
        self.performSegue(withIdentifier: "paymentOptions", sender: self)
    }
    
    //this methid to reset data and view when user ecievers notification (order status changed/user become delegate)
    func userRecievesNotification(){
        print("userRecievesNotification")
        //reset all data and arrays in view and presenter
        Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.refreshData), userInfo: nil, repeats: false)
    }
    
    
    @objc func refreshData(){
        myOrdersPresenter.resetData()
        resetData()
    }
    
    func resetData(){
        appDelegate.myOrdersNeedUpdate = false
        userCurrentOrders.removeAll()
        userPastOrders.removeAll()
        delegateCurrentOrders.removeAll()
        delegatePastOrders.removeAll()
        
        endUserInfiniteScroll = false
        endDelegateInfiniteScroll = false
        gotDelegateData = false
        gotUserData = false
        
        checkUserType()
        
        if isUser{
            selectMyOrders()
        }else{
            selectRequests()
            
        }
    }
    
    
    //delegate enable/disable recieving requests
    @objc func switchIsChanged() {
        // print(locationManager.locationStatus)
        if (self.userDefault.getUserData().delegate_details?.active) != nil{
            if (self.userDefault.getUserData().delegate_details?.active)!{
                self.myOrdersPresenter.changeDelegateRequestsStatus(enable: false)
            }else{
                checkLocationServices()
            }
        }else{
            self.myOrdersPresenter.changeDelegateRequestsStatus(enable: true)
        }
    }
    
    func checkLocationServices(){
        if locationManager.isLocationServicesAvailable(){
            self.myOrdersPresenter.changeDelegateRequestsStatus(enable: true)
        }else{
            if CLLocationManager.locationServicesEnabled() {
                Toast(text: "permissionDenied".localized()).show()
            }else{
                locationManager.determineMyCurrentLocation(isNeedCountryCode: false)
            }
        }
        
    }
    
    func changeImageWithAnimation(image : UIImage){
        UIView.transition(with: enableReuestsSwitchImg, duration: 0.2, options: .transitionCrossDissolve, animations: {
            self.enableReuestsSwitchImg.image = image
        }, completion: nil)
    }
    
    func checkUserType(){
        //show tabs only for delegate
        
        if userDefault.getUserData().is_delegate != nil{
            if userDefault.getUserData().is_delegate!{
                TabsView.constant = 60
                tabs.isHidden = false
                if !isUser{
                    enableRequestsViewHeight.constant = 60
                    enableRequestsView.isHidden = false
                }else{
                    enableRequestsViewHeight.constant = 0
                    enableRequestsView.isHidden = true
                }
                
                
            }else{
                TabsView.constant = 0
                tabs.isHidden = true
                if !isUser{
                    enableRequestsViewHeight.constant = 60
                    enableRequestsView.isHidden = false
                }else{
                    enableRequestsViewHeight.constant = 0
                    enableRequestsView.isHidden = true
                }
                
            }
        }else{
            TabsView.constant = 0
            tabs.isHidden = true
            if !isUser{
                enableRequestsViewHeight.constant = 60
                enableRequestsView.isHidden = false
            }else{
                enableRequestsViewHeight.constant = 0
                enableRequestsView.isHidden = true
            }
            
        }
        
    }
    
    func setupTableView(){
        self.tableView.register(OrderCell.self, forCellReuseIdentifier: "orderCell")
        self.tableView.register(UINib(nibName: "OrderCell", bundle: nil), forCellReuseIdentifier: "orderCell")
        self.tableView.tableFooterView = UIView()
        
        //        self.tableView.addInfiniteScroll { (scrollView) -> Void in
        //            self.notificationListPresenter.getUserNotifications()
        //        }
    }
    
    func setStrings(){
        myOrdersLbl.text = "my_orders".localized()
        requestsLbl.text = "delivery_requests".localized()
        enableRequestsLbl.text = "requests_availability".localized()
        noNetworkTitleLbl.text = "no_network_title".localized()
        noNetworkDescLbl.text = "no_network_desc".localized()
        noNetworkReloadLbl.text = "no_network_reload".localized()
        
        self.navigationItem.title = "my_orders".localized()
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: Utils.customBoldFont(17), NSAttributedString.Key.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.barStyle = .blackOpaque
    }
    
    func setFonts(){
        requestsLbl.font = Utils.customDefaultFont(requestsLbl.font.pointSize)
        myOrdersLbl.font = Utils.customDefaultFont(myOrdersLbl.font.pointSize)
        enableRequestsLbl.font = Utils.customDefaultFont(enableRequestsLbl.font.pointSize)
        noNetworkTitleLbl.font = Utils.customBoldFont(noNetworkTitleLbl.font.pointSize)
        noNetworkDescLbl.font = Utils.customDefaultFont(noNetworkDescLbl.font.pointSize)
        noNetworkReloadLbl.font = Utils.customDefaultFont(noNetworkReloadLbl.font.pointSize)
    }
    
    func setGestures(){
        let myOrdersTab = UITapGestureRecognizer(target: self, action: #selector(self.selectMyOrders))
        myOrdersView.addGestureRecognizer(myOrdersTab)
        
        let requestsTab = UITapGestureRecognizer(target: self, action: #selector(self.selectRequests))
        requestsView.addGestureRecognizer(requestsTab)
        
        let reloadTap = UITapGestureRecognizer(target: self, action: #selector(reloadData))
        noNetworkReloadImg.addGestureRecognizer(reloadTap)
        
        let reloadLblTap = UITapGestureRecognizer(target: self, action: #selector(reloadData))
        noNetworkReloadLbl.addGestureRecognizer(reloadLblTap)
    }
    
    @objc func reloadData(){
        if isUser{
            self.myOrdersPresenter.getUserCurrentOrders(showLoading: true)
        }else{
            self.myOrdersPresenter.getDelegateCurrentOrders(showLoading: true)
        }
    }
    
    @objc func selectMyOrders(){
        isUser = true
        changeRequestingOrderHeight(height: 0)
        //self.enableRequestsViewHeight.constant = 0
        self.enableRequestsView.isHidden = true
        changeLineWidth(lineView: myOrdersLine, isHidden: false)
        changeLineWidth(lineView: requestsLine, isHidden: true)
        changeHighlightedTextColor(label: myOrdersLbl, ishighlighted: true)
        changeHighlightedTextColor(label: requestsLbl, ishighlighted: false)
        
        //to optimize requests not to call data every time in view will appear only when there is no data
        if userPastOrders.count == 0 && userCurrentOrders.count == 0 && !gotUserData{
            self.myOrdersPresenter.getUserCurrentOrders(showLoading: true)
        }
    
        // add inifinte scroll in case user inifinte scroll wasn't ended
        if !endUserInfiniteScroll{
            self.tableView.addInfiniteScroll { (scrollView) -> Void in
                self.myOrdersPresenter.getUserCurrentOrders(showLoading: false)
            }
        }
        self.tableView.reloadData()
    }
    
    
    @objc func selectRequests(){
        isUser = false
        changeRequestingOrderHeight(height: 60)
        //self.enableRequestsViewHeight.constant = 60
        self.enableRequestsView.isHidden = false
        changeLineWidth(lineView: myOrdersLine, isHidden: true)
        changeLineWidth(lineView: requestsLine, isHidden: false)
        changeHighlightedTextColor(label: myOrdersLbl, ishighlighted: false)
        changeHighlightedTextColor(label: requestsLbl, ishighlighted: true)
        
        if delegatePastOrders.count == 0 && delegateCurrentOrders.count == 0 && !gotDelegateData{
            self.myOrdersPresenter.getDelegateCurrentOrders(showLoading: true)
        }
        
        // add inifinte scroll in case delegate inifinte scroll wasn't ended
        if !endDelegateInfiniteScroll{
            self.tableView.addInfiniteScroll { (scrollView) -> Void in
                self.myOrdersPresenter.getDelegateCurrentOrders(showLoading: false)
            }
        }
        self.checkDelgateMaximumBalance()
        self.tableView.reloadData()
        
    }
    
    
    func changeRequestingOrderHeight(height : CGFloat){
        
       // self.enableRequestsViewHeight.constant = height

        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.enableRequestsViewHeight.constant = height
            self.view.layoutIfNeeded()
        })
    }
    
    func changeLineWidth(lineView : UIView , isHidden : Bool){
        
        UIView.transition(with: lineView, duration: 0.5, options: .curveLinear, animations: {
            lineView.isHidden = isHidden
        }, completion: nil)
        
        //        lineView.layer.removeAllAnimations()
        //        let anim = CABasicAnimation(keyPath: "bounds.size.width")
        //        anim.duration = 0.5
        //        anim.fromValue = 0
        //        anim.toValue = self.view.frame.width/2
        //        lineView.layer.position =  CGPoint(x: self.view.frame.minX, y: self.view.frame.minY)
        //        lineView.layer.anchorPoint = CGPoint(x: 0, y: 0)
        //        lineView.layer.add(anim, forKey: "anim")
    }
    
    func changeHighlightedTextColor(label : UILabel , ishighlighted : Bool){
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            if ishighlighted{
                label.textColor = Colors.hexStringToUIColor(hex: "#212121")
            }else{
                label.textColor = Colors.hexStringToUIColor(hex: "#bcc5d3")
            }
        })
    }
    
    @objc func seeMoreOrders(){
        self.performSegue(withIdentifier: "allCurrentOrders", sender: self)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "allCurrentOrders"{
            let navigationVC = segue.destination as! UINavigationController
            let vc = navigationVC.topViewController as! CurrentOrdersList
            vc.isUser = self.isUser
            if isUser{
                vc.orders = self.userCurrentOrders
            }else{
                vc.orders = self.delegateCurrentOrders
            }
        }else if segue.identifier == "userOrderDetails"{
            let navigationVC = segue.destination as! UINavigationController
            let vc = navigationVC.topViewController as! UserOrderDetailsVC
            if selectedOrder.id != nil{
                vc.orderID = selectedOrder.id!
            }
        }else if segue.identifier == "delegateOrderDetails"{
            let navigationVC = segue.destination as! UINavigationController
            let vc = navigationVC.topViewController as! DelegateOrderDetailsVC
            if selectedOrder.id != nil{
                vc.orderID = selectedOrder.id!
            }
        }else if segue.identifier == "toChat"{
            let navVc = segue.destination as! UINavigationController
            let vc = navVc.topViewController as! ChatVC
            vc.isFromMyOrders = true
            vc.isDelegateOfOrder = !isUser
            vc.order = selectedOrder
        }
    }
}

extension MyOrdersVC :UITableViewDelegate , UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isUser{
            if section == 0 {
                if self.userCurrentOrders.count > maxCurrentOrdersNum{
                    return maxCurrentOrdersNum
                }else{
                    if self.userCurrentOrders.count > 0 {
                        return self.userCurrentOrders.count
                    }else{
                        return 1
                    }
                }
            }else if section == 1{
                if self.userPastOrders.count > 0 {
                    return self.userPastOrders.count
                }else{
                    return 1
                }
            }
        }else{
     
            if section == 0 {
                //current orders
                if delegateReachedMax{
                    if self.delegateCurrentOrders.count > maxCurrentOrdersNum{
                        return maxCurrentOrdersNum
                    }else{
                        if self.delegateCurrentOrders.count > 0 {
                            return self.delegateCurrentOrders.count
                        }else{
                            return 1
                        }
                    }
                }else{
                    return 1
                }
            }else if section == 1{
                //history orders
                if self.delegatePastOrders.count > 0 {
                    return self.delegatePastOrders.count
                }else{
                    return 1
                }
            }
        }
       
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var arrayUsed = [Order]()
        if isUser{
            if indexPath.section == 0 {
                arrayUsed = self.userCurrentOrders
            }else if indexPath.section == 1{
                arrayUsed = self.userPastOrders
            }
        }else{
            if indexPath.section == 0 {
                arrayUsed = self.delegateCurrentOrders
            }else if indexPath.section == 1{
                arrayUsed = self.delegatePastOrders
            }
        }
        
        if !isUser && delegateReachedMax && indexPath.section == 0 && gotDelegateData{
            let cell = tableView.dequeueReusableCell(withIdentifier: "maxCell", for: indexPath)
            let maxTitle = cell.contentView.viewWithTag(1) as! UILabel
            maxTitle.font = Utils.customBoldFont(maxTitle.font.pointSize)
            maxTitle.text = "maxWalletTitle".localized()
            
            let maxContent = cell.contentView.viewWithTag(2) as! UILabel
            maxContent.font = Utils.customDefaultFont(maxContent.font.pointSize)
            maxContent.text = "maxWalletContent".localized()
            
            addMoneyView = cell.contentView.viewWithTag(3)!
            addMoneyView.layer.setCornerRadious(radious: 10.0, maskToBounds: true)
            let addMoney = UITapGestureRecognizer(target: self, action: #selector(self.addMoney))
            addMoneyView.addGestureRecognizer(addMoney)

            let addMoneyLbl = cell.contentView.viewWithTag(4) as! UILabel
            addMoneyLbl.font = Utils.customDefaultFont(addMoneyLbl.font.pointSize)
            addMoneyLbl.text = "addMoney".localized()
            
            cell.selectionStyle = .none

            return cell
        }else{
            if arrayUsed.count > 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "orderCell", for: indexPath) as! OrderCell
                var order = Order()
                if isUser{
                    if arrayUsed.indices.contains(indexPath.row){
                        if indexPath.section == 0 {
                            order = arrayUsed[indexPath.row]
                        }else if indexPath.section == 1{
                            order = arrayUsed[indexPath.row]
                        }
                    }
                }else{
                    if arrayUsed.indices.contains(indexPath.row){
                        
                        if indexPath.section == 0 {
                            order = arrayUsed[indexPath.row]
                        }else if indexPath.section == 1{
                            order = arrayUsed[indexPath.row]
                        }
                    }
                }
                cell.setCell(indexPath : indexPath, showCarDetails: isUser, order: order)
                cell.separatorInset = .zero
                cell.isUserInteractionEnabled = true
                cell.selectionStyle = .none
                return cell
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "noDataCell", for: indexPath)
                cell.separatorInset = UIEdgeInsets(top: 0, left: 10000, bottom: 0, right: 0);
                let noDataLbl = cell.contentView.viewWithTag(2) as! UILabel
                noDataLbl.font = Utils.customBoldFont(noDataLbl.font.pointSize)
                let headerImg = cell.contentView.viewWithTag(1) as! UIImageView
                if indexPath.section == 0 {
                    noDataLbl.text = "emptyCurrentOrders".localized()
                }else{
                    noDataLbl.text = "emptyPastOrders".localized()
                }
                headerImg.image = UIImage(named: "no_active_orders")
                cell.isUserInteractionEnabled = false
                cell.selectionStyle = .none
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "headerCell")
        cell?.selectionStyle = .none
        let headerTitle = cell?.contentView.viewWithTag(1) as! UILabel
        headerTitle.font = Utils.customBoldFont(headerTitle.font.pointSize)
        let headerImg = cell?.contentView.viewWithTag(2) as! UIImageView
        let seeMoreView = cell?.contentView.viewWithTag(3)
        let seeMoreTap = UITapGestureRecognizer(target: self, action: #selector(self.seeMoreOrders))
        seeMoreView!.addGestureRecognizer(seeMoreTap)
        seeMoreView!.layer.cornerRadius = 10.0
        seeMoreView!.layer.masksToBounds = true
        seeMoreView!.clipsToBounds = true
        
        let seeMoreLbl = cell?.contentView.viewWithTag(4) as! UILabel
        seeMoreLbl.font = Utils.customBoldFont(seeMoreLbl.font.pointSize)
        seeMoreLbl.text = "showAll".localized()
        
        if section == 0 {
            headerTitle.text = "current_orders".localized()
            headerImg.image = UIImage(named: "current_orders")
            var ordersArr = [Order]()
            if isUser{
                ordersArr = self.userCurrentOrders
            }else{
                ordersArr = self.delegateCurrentOrders
            }
            if ordersArr.count > maxCurrentOrdersNum{
                seeMoreView!.isHidden = false
            }else{
                seeMoreView!.isHidden = true
            }
            cell?.isUserInteractionEnabled = true
        }else{
            headerTitle.text = "historyOrders".localized()
            headerImg.image = UIImage(named: "history_ic")
            seeMoreView!.isHidden = true
            cell?.isUserInteractionEnabled = false
        }
        
        for constraint in (cell?.contentView.constraints)!{
            if constraint.identifier == "ImageCenterVertical"{
                if section == 0 {
                    constraint.constant = -5
                }else{
                    constraint.constant = 0
                }
            }
            
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var arrayUsed = [Order]()
        
        if isUser{
            if indexPath.section == 0 {
                arrayUsed = self.userCurrentOrders
            }else if indexPath.section == 1{
                arrayUsed = self.userPastOrders
            }
        }else{
            if indexPath.section == 0 {
                arrayUsed = self.delegateCurrentOrders
            }else if indexPath.section == 1{
                arrayUsed = self.delegatePastOrders
            }
        }
        
        if !isUser && delegateReachedMax && indexPath.section == 0{
            return UITableView.automaticDimension
            
        }else{
            if arrayUsed.count > 0 {
                return UITableView.automaticDimension
            }else{
                return 200
            }
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (!isUser && delegateReachedMax && section == 0 && gotDelegateData){
            return 0
        }
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        print("\(indexPath.row) \(indexPath.section)")
       
        if !(!isUser && delegateReachedMax && indexPath.section == 0 && gotDelegateData){
            
            var arrayUsed = [Order]()
            if isUser{
                if indexPath.section == 0 {
                    arrayUsed = self.userCurrentOrders
                }else if indexPath.section == 1{
                    arrayUsed = self.userPastOrders
                }
                self.selectedOrder = arrayUsed[indexPath.row]
                if canPerformSegueWithIdentifier(identifier: "userOrderDetails"){
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "userOrderDetails", sender: self)
                    }
                }
            }else{
                if indexPath.section == 0 {
                    arrayUsed = self.delegateCurrentOrders
                }else if indexPath.section == 1{
                    arrayUsed = self.delegatePastOrders
                }
                self.selectedOrder = arrayUsed[indexPath.row]
                
                if canPerformSegueWithIdentifier(identifier: "delegateOrderDetails"){
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "delegateOrderDetails", sender: self)
                    }
                }
            }
        }
    }
    
    func canPerformSegueWithIdentifier(identifier: NSString) -> Bool {
        let templates:NSArray = self.value(forKey: "storyboardSegueTemplates") as! NSArray
        let predicate:NSPredicate = NSPredicate(format: "identifier=%@", identifier)
        
        let filteredtemplates = templates.filtered(using: predicate)
        return (filteredtemplates.count>0)
    }
}

extension MyOrdersVC : MyOrdersView{
    
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
        self.noNwView.isHidden = false
    }
    
    func showGeneralError() {
        Toast.init(text: "general_error".localized()).show()
    }
    
    func showSusspendedMsg(msg : String){
        Toast.init(text:msg).show()
    }
    
    
    func showNoData(){
        
    }
    
    func stopInfinitScroll(){
        self.tableView.removeInfiniteScroll()
    }
    
    func changeDelegateRequestsStatusSuccessfully(active : Bool?){
        print("changeDelegateRequestsStatusSuccessfully")
        
        if (self.userDefault.getUserData().delegate_details?.active) != nil{
            if (self.userDefault.getUserData().delegate_details?.active)!{
                UIView.transition(with: enableReuestsSwitchImg, duration: 0.2, options: .transitionCrossDissolve, animations: {
                    self.enableReuestsSwitchImg.image = UIImage(named: "switch_off")
                }, completion: nil)
            }else{
                UIView.transition(with: enableReuestsSwitchImg, duration: 0.2, options: .transitionCrossDissolve, animations: {
                    self.enableReuestsSwitchImg.image = UIImage(named: "switch_on")
                }, completion: nil)
            }
        }else{
            UIView.transition(with: enableReuestsSwitchImg, duration: 0.2, options: .transitionCrossDissolve, animations: {
                if(active ?? false){
                    self.enableReuestsSwitchImg.image = UIImage(named: "switch_on")
                }else{
                    self.enableReuestsSwitchImg.image = UIImage(named: "switch_off")
                }
            }, completion: nil)
        }
        
        if active != nil{
            let user = userDefault.getUserData()
            if user.delegate_details == nil{
                let delegateDetails = RequestsActivation(active: active!)
                user.delegate_details = delegateDetails
                self.userDefault.setUserData(userData: user)
            }else{
                user.delegate_details?.active = active
                self.userDefault.setUserData(userData: user)
            }
        }
        
        databaseManager.checkDelagateLocation()
        
    }
    
    func stopInfinitScroll(type : String){
        self.noNwView.isHidden = true
        self.tableView.isHidden = false
        if type.contains("user"){
            gotUserData = true
            endUserInfiniteScroll = true
        }else if type.contains("delegate"){
            gotDelegateData = true
            endDelegateInfiniteScroll = true
        }
        
        self.tableView.removeInfiniteScroll()
    }
    
    func setUserData(currentOrders : [Order] , pastOrders : [Order] , type : String){
        self.noNwView.isHidden = true
        self.tableView.isHidden = false
        
        gotUserData = true
        self.userCurrentOrders = currentOrders
        self.userPastOrders = pastOrders
        if type.contains("user") && isUser{
            self.tableView.reloadData()
        }
    }
    
    func setDelegateData(currentOrders : [Order] , pastOrders : [Order] , type : String){
        self.noNwView.isHidden = true
        self.tableView.isHidden = false
        
        gotDelegateData = true
        self.delegateCurrentOrders = currentOrders
        self.delegatePastOrders = pastOrders
        if type.contains("delegate") && !isUser{
            self.tableView.reloadData()
        }
    }
    
    func showDelegateNoData(currentOrders : [Order], type : String){
        self.noNwView.isHidden = true
        gotDelegateData = true
        endDelegateInfiniteScroll = true
        self.tableView.isHidden = false
        
        self.delegateCurrentOrders = currentOrders
        if type.contains("delegate") && !isUser{
            self.tableView.reloadData()
        }
        self.tableView.removeInfiniteScroll()
    }
    
    func showUserNoData(currentOrders : [Order] , type : String){
        self.noNwView.isHidden = true
        endUserInfiniteScroll = true
        gotUserData = true
        self.tableView.isHidden = false
        
        self.userCurrentOrders = currentOrders
        if type.contains("user") && isUser{
            self.tableView.reloadData()
        }
        
        self.tableView.removeInfiniteScroll()
        
    }
    
    func showChangeRequestsStatusNetworkError(){
        Toast.init(text: "connectionFailed".localized()).show()
    }
    
    
    
}

