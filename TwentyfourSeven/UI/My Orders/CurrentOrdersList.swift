//
//  CurrentOrdersList.swift
//  TwentyfourSeven
//
//  Created by Dina Ragab on 2/7/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import UIKit
import Toaster
import MBProgressHUD
import UIScrollView_InfiniteScroll

class CurrentOrdersList: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backIcon: UIBarButtonItem!
    
    var orders = [Order]()
    var isUser = true
    var currentOrdersPresenter : CurrentOrdersPresenter!
    var loadingView: MBProgressHUD!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var selectedOrder = Order()

    override func viewDidLoad() {
        super.viewDidLoad()
        initPresenter()
        setupTableView()
        setUI()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        if appDelegate.currentOrdersNeedUpdate{
            resetData()
        }
    }
    
    func resetData(){
        orders.removeAll()
        currentOrdersPresenter.resetData()
        appDelegate.currentOrdersNeedUpdate = false
        if self.isUser{
            self.currentOrdersPresenter.getUserCurrentOrders()
        }else{
            self.currentOrdersPresenter.getDelegateCurrentOrders()
        }
    }
    
    func setUI(){
        self.navigationItem.title = "current_orders".localized()
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: Utils.customBoldFont(17), NSAttributedString.Key.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.barStyle = .blackOpaque
        
        if appDelegate.isRTL{
            backIcon.image = UIImage(named: "back_ar_ic")
        }else{
            backIcon.image = UIImage(named: "back_ic")
        }
    }
    
    func setupTableView(){
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(OrderCell.self, forCellReuseIdentifier: "orderCell")
        self.tableView.register(UINib(nibName: "OrderCell", bundle: nil), forCellReuseIdentifier: "orderCell")
        self.tableView.tableFooterView = UIView()
        
        self.tableView.addInfiniteScroll { (scrollView) -> Void in
            if self.isUser{
                self.currentOrdersPresenter.getUserCurrentOrders()
            }else{
                self.currentOrdersPresenter.getDelegateCurrentOrders()
            }
        }
    }
    
    func initPresenter(){
        currentOrdersPresenter = CurrentOrdersPresenter(repository: Injection.provideDelegateRepository(), userRepository: Injection.provideUserRepository())
        currentOrdersPresenter.setView(view: self)
        currentOrdersPresenter.setData(orders : orders)
    }
    
    @IBAction func backPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "userOrderDetails"{
            let navigationVC = segue.destination as! UINavigationController
            let vc = navigationVC.topViewController as! UserOrderDetailsVC
            if selectedOrder.id != nil{
                vc.orderID = selectedOrder.id!
            }
        }else if segue.identifier == "delegateOrder"{
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

extension CurrentOrdersList :UITableViewDelegate , UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "orderCell", for: indexPath) as! OrderCell
        cell.setCell(indexPath : indexPath, showCarDetails: isUser, order: orders[indexPath.row])
        cell.separatorInset = .zero
        cell.selectionStyle = .none

        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        print("\(indexPath.row) \(indexPath.section)")
        self.selectedOrder = orders[indexPath.row]
        if isUser{

            if canPerformSegueWithIdentifier(identifier: "userOrderDetails"){
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "userOrderDetails", sender: self)
                }
            }
            //check status//            if selectedOrder.status != nil{
//                if selectedOrder.status! == "assigned" || selectedOrder.status! == "in_progress" || selectedOrder.status! == "delivery_in_progress"{
//                    self.performSegue(withIdentifier: "toChat", sender: self)
//                }else{
//                    self.performSegue(withIdentifier: "userOrderDetails", sender: self)
//                }
//            }else{
//                self.performSegue(withIdentifier: "userOrderDetails", sender: self)
//            }
        }else{

            if canPerformSegueWithIdentifier(identifier: "delegateOrder"){
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "delegateOrder", sender: self)
                }
            }
            //check status
//            if selectedOrder.status != nil{
//                if selectedOrder.status! == "assigned" || selectedOrder.status! == "in_progress" || selectedOrder.status! == "delivery_in_progress"{
//                    self.performSegue(withIdentifier: "toChat", sender: self)
//                }else{
//                    self.performSegue(withIdentifier: "delegateOrderDetails", sender: self)
//                }
//            }else{
//                self.performSegue(withIdentifier: "delegateOrderDetails", sender: self)
//            }
        }
        
    }
    
    func canPerformSegueWithIdentifier(identifier: NSString) -> Bool {
        let templates:NSArray = self.value(forKey: "storyboardSegueTemplates") as! NSArray
        let predicate:NSPredicate = NSPredicate(format: "identifier=%@", identifier)
        
        let filteredtemplates = templates.filtered(using: predicate)
        return (filteredtemplates.count>0)
    }
}

extension CurrentOrdersList : CurrentOrdersView{
    
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
        Toast.init(text: "connectionFailed".localized()).show()
    }
    
    func showGeneralError() {
        Toast.init(text: "general_error".localized()).show()
    }
    
    func showSusspendedMsg(msg : String){
        Toast.init(text:msg).show()
    }
   
    func stopInfinitScroll(){
        self.tableView.removeInfiniteScroll()
    }
    
    func setOrders(orders : [Order]){
        self.orders = orders
        self.tableView.reloadData()
    }
    
    func topMostController() -> UIViewController {
        var topController: UIViewController? = UIApplication.shared.keyWindow?.rootViewController
        while ((topController?.presentedViewController) != nil) {
            topController = topController?.presentedViewController
        }
        return topController!
    }
    
}


