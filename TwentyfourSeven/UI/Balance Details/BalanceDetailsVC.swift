//
//  BalanceDetails.swift
//  TwentyfourSeven
//
//  Created by Dina Ragab on 3/19/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import UIKit
import MBProgressHUD
import Toaster

class BalanceDetailsVC: UIViewController {
    
    @IBOutlet weak var backIcon: UIBarButtonItem!
    @IBOutlet weak var scrollView: UIScrollView!
    
    //wallet view
    @IBOutlet weak var walletAmoutLbl: UILabel!
    @IBOutlet weak var walletLbl: UILabel!
    @IBOutlet weak var walletView: UIView!
    
    //add money view
    @IBOutlet weak var addMoneyViewHeight: NSLayoutConstraint!
    @IBOutlet weak var addMoneyView: UIView!
    @IBOutlet weak var addMoneyActionLbl: UILabel!
    @IBOutlet weak var addMoneyBtnView: UIView!
    @IBOutlet weak var addMoneyLbl: UILabel!
    @IBOutlet weak var minusBalanceLbl: UILabel!
    @IBOutlet weak var addMoneyWidth: NSLayoutConstraint!
    @IBOutlet weak var minusBalanceHeight: NSLayoutConstraint!
    @IBOutlet weak var minusBalanceBottomConstraint: NSLayoutConstraint!
    
    //transactions list
    @IBOutlet weak var tableviewHeight: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var transactionHistory: UILabel!
    
    //no network
    @IBOutlet weak var noNetworkView: UIView!
    @IBOutlet weak var noNetworkTitleLbl: UILabel!
    @IBOutlet weak var noNetworkDescLbl: UILabel!
    @IBOutlet weak var noNetworkReloadLbl: UILabel!
    @IBOutlet weak var noNetworkReloadImg: UIImageView!
    
    //earnings
    @IBOutlet weak var totalEarningLbl: UILabel!
    @IBOutlet weak var earningView: UIView!
    @IBOutlet weak var earningLbl: UILabel!
    @IBOutlet weak var sarLbl: UILabel!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let userDefault = UserDefault()
    var loadingView: MBProgressHUD!

    var balanceDetailsPresenter : BalanceDetailsPresenter!
    var transactions = [Transaction]()
    var wallet = DelegateWalletInfo(){
        didSet {
            //set earnings
            if let earnings = wallet.earnings{
                self.earningLbl.text = "\(String(format: "%.2f", earnings))"
            }else{
                self.earningLbl.text = ""
            }
            
            //set user balance in user default
            if let walletAmount = wallet.balance{
                let user = self.userDefault.getUserData()
                user.balance = Double(walletAmount)
                self.userDefault.setUserData(userData: user)
                //check wallet cases
                customizeWalletView()
            }
        }
    }

    //check screen status to show/hide views
    var state: ScreenStatus = .loaded {
        didSet {
            switch state {
            case .noData:
                print("noData")
                self.scrollView.isHidden = false
                self.noNetworkView.isHidden = true
            case .loaded:
               self.scrollView.isHidden = false
               self.noNetworkView.isHidden = true
            case .noNetwork:
                self.scrollView.isHidden = true
                self.noNetworkView.isHidden = false
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        initPresenter()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        customizeWalletView()
        tableView.reloadData()
        setTableViewHeight()
    }
    
    func initPresenter(){
        balanceDetailsPresenter = BalanceDetailsPresenter(userRepository: Injection.provideUserRepository(), walletRepository: Injection.provideWalletRepository())
        balanceDetailsPresenter.setView(view: self)
    }
    
    func setUI(){
        setLocalization()
        setFonts()
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: Utils.customBoldFont(17), NSAttributedString.Key.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.barStyle = .blackOpaque
        self.navigationItem.title = "My_Balance".localized()
       
        walletView.layer.setBorder(borderColor: Colors.hexStringToUIColor(hex: "bcc5d3").cgColor, width: 0.5)
        addMoneyView.layer.setBorder(borderColor: Colors.hexStringToUIColor(hex: "bcc5d3").cgColor, width: 0.5)
        addMoneyBtnView.layer.setCornerRadious(radious: 10.0, maskToBounds: true)
        earningView.layer.setCornerRadious(radious: 20.0, maskToBounds: false)
        earningView.layer.setShadow(opacity : 0.7 , radious :5, shadowColor: UIColor.lightGray.cgColor)

        addMoneyWidth.constant = self.addMoneyActionLbl.intrinsicContentSize.width + 30
        
        if appDelegate.isRTL{
            backIcon.image = UIImage(named: "back_ar_ic")
        }else{
            backIcon.image = UIImage(named: "back_ic")
        }
        
        tableView.separatorStyle = .none
        
        self.scrollView.addInfiniteScroll { (scrollView) -> Void in
            self.balanceDetailsPresenter.getTransactionsList()
        }
    }
    
    func setTableViewHeight(){
        if state == .loaded{
            var cellHeight : CGFloat = 0.0
            for i in 0..<self.transactions.count {
                let indexPath = IndexPath(row: i, section: 0)
                let frame = tableView.rectForRow(at: indexPath)
                cellHeight = cellHeight + frame.height
            }
            
            tableviewHeight.constant = cellHeight
        }else{
            tableviewHeight.constant = 200
        }
    }
    
    @IBAction func reloadData(_ sender: Any) {
        if Utils.isConnectedToNetwork(){
            self.balanceDetailsPresenter.resetData()
            self.balanceDetailsPresenter.getWalletDetails()
        }
        
    }
    
    func resetData(){
        self.balanceDetailsPresenter.resetData()
        self.balanceDetailsPresenter.getWalletDetails()
    }
    
    
    func customizeWalletView(){
        var money = 0.0
        if let balance = userDefault.getUserData().balance {
            money = balance
        }
        
        //change background and text colors and hide add money view if amount baalnce is zero or positive
        if money < 0 {
            walletAmoutLbl.textColor = Colors.hexStringToUIColor(hex: "E84450")
            walletView.backgroundColor = Colors.hexStringToUIColor(hex: "fff3f4")
            if appDelegate.isRTL{
                addMoneyViewHeight.constant = 170
            }else{
                addMoneyViewHeight.constant = 160
            }
            addMoneyView.isHidden = false
            
            //check is delegate has exceed his maximum wallet
            if let maximumBalance = self.userDefault.getMaximumBalance(){
                if -money <= maximumBalance{
                    minusBalanceHeight.constant = 21
                    minusBalanceLbl.isHidden = false
                    minusBalanceBottomConstraint.constant = 0
                    addMoneyLbl.text = "addMoneyDesc".localized()
                }else{
                    minusBalanceLbl.isHidden = true
                    if appDelegate.isRTL{
                        addMoneyViewHeight.constant = 140
                    }else{
                        addMoneyViewHeight.constant = 130
                    }
                    minusBalanceBottomConstraint.constant = -15
                    minusBalanceHeight.constant = 0
                    addMoneyLbl.text = "maxWallet".localized()
                }
            }else{
                minusBalanceHeight.constant = 21
                minusBalanceBottomConstraint.constant = 0
                minusBalanceLbl.isHidden = false
                addMoneyLbl.text = "addMoneyDesc".localized()
            }
            
        }else{
            minusBalanceHeight.constant = 21
            minusBalanceBottomConstraint.constant = 10
            walletAmoutLbl.textColor = Colors.hexStringToUIColor(hex: "#4ebf26")
            walletView.backgroundColor = Colors.hexStringToUIColor(hex: "#f5fff1")
            addMoneyViewHeight.constant = 0
            addMoneyView.isHidden = true
        }
        
        walletAmoutLbl.text = "\(String(format: "%.2f", money)) \("sar".localized())"
    }
    
    func setLocalization(){
        walletLbl.text = "myWallet".localized()
        transactionHistory.text = "Transactions_history".localized()
        minusBalanceLbl.text = "minus_balance".localized()
        addMoneyActionLbl.text = "addMoney".localized()
        noNetworkTitleLbl.text = "no_network_title".localized()
        noNetworkDescLbl.text = "no_network_desc".localized()
        noNetworkReloadLbl.text = "no_network_reload".localized()
        totalEarningLbl.text = "totalEarning".localized()
        sarLbl.text = "sar".localized()
    }
    
    func setFonts(){
        walletLbl.font = Utils.customDefaultFont(walletLbl.font.pointSize)
        walletAmoutLbl.font = Utils.customDefaultFont(walletAmoutLbl.font.pointSize)
        minusBalanceLbl.font = Utils.customDefaultFont(minusBalanceLbl.font.pointSize)
        addMoneyLbl.font = Utils.customDefaultFont(addMoneyLbl.font.pointSize)
        addMoneyActionLbl.font = Utils.customBoldFont(addMoneyActionLbl.font.pointSize)
        transactionHistory.font = Utils.customBoldFont(transactionHistory.font.pointSize)
        noNetworkTitleLbl.font = Utils.customBoldFont(noNetworkTitleLbl.font.pointSize)
        noNetworkDescLbl.font = Utils.customDefaultFont(noNetworkDescLbl.font.pointSize)
        noNetworkReloadLbl.font = Utils.customDefaultFont(noNetworkReloadLbl.font.pointSize)
        totalEarningLbl.font = Utils.customDefaultFont(totalEarningLbl.font.pointSize)
        earningLbl.font = Utils.customBoldFont(earningLbl.font.pointSize)
        sarLbl.font = Utils.customBoldFont(sarLbl.font.pointSize)
    }
    
    @IBAction func addMoney(_ sender: Any) {
        print("addMoney")
        self.performSegue(withIdentifier: "paymentOptions", sender: self)
    }
    
    @IBAction func backPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension BalanceDetailsVC : UITableViewDelegate , UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if state == .loaded{
            return  self.transactions.count
        }else{
            return 1
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if state == .loaded{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "transactionCell", for: indexPath) as! TransactionCell
            if indexPath.row != 0 {
                cell.layer.setBorder(borderColor: Colors.hexStringToUIColor(hex: "bcc5d3").cgColor, width: 0.5)
            }else{
                cell.layer.setBorder(borderColor: UIColor.clear.cgColor, width: 0.5)
            }
            cell.setCell(transaction : self.transactions[indexPath.row])
            
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "noDataCell", for: indexPath)
            cell.separatorInset = UIEdgeInsets(top: 0, left: 10000, bottom: 0, right: 0);
            let noDataLbl = cell.contentView.viewWithTag(2) as! UILabel
            noDataLbl.font = Utils.customBoldFont(noDataLbl.font.pointSize)
            noDataLbl.text = "no_transactions".localized()
            let headerImg = cell.contentView.viewWithTag(1) as! UIImageView
            headerImg.image = UIImage(named: "no_active_orders")
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if state == .loaded{
            return UITableView.automaticDimension
        }else{
            return 200
        }
    }
    
}

extension BalanceDetailsVC : BalanceDetailsView{
    
    func showloading() {
        self.scrollView.isHidden = true
        if(loadingView != nil) {
            loadingView.hide(animated: true)
            loadingView = nil
        }
        loadingView = MBProgressHUD.showAdded(to: self.view, animated: true)
        loadingView.mode = MBProgressHUDMode.indeterminate
    }
    
    func hideLoading() {
        self.scrollView.isHidden = false
        if(loadingView != nil) {
            loadingView.hide(animated: true)
            loadingView = nil
        }else{
            scrollView.finishInfiniteScroll()
        }
    }
    
    func showNetworkError() {
       self.state = .noNetwork
    }
    
    func showGeneralError() {
        Toast.init(text: "general_error".localized()).show()
    }
    
    func showSusspendedMsg(msg : String){
        Toast.init(text:msg).show()
    }
    
   
    
    func showNoData(delegateWallet : DelegateWalletInfo){
        print("no transactions")
        self.state = .noData
          self.wallet = delegateWallet
        self.tableView.reloadData()
        setTableViewHeight()
        stopInfinitScroll()
    }
    
    func stopInfinitScroll(){
        self.scrollView.removeInfiniteScroll()
        self.tableView.isScrollEnabled = false
    }
    
    func setTransactions(transactions : [Transaction], delegateWallet : DelegateWalletInfo){
        self.state = .loaded
        self.transactions = transactions
        self.wallet = delegateWallet
        self.tableView.reloadData()
        setTableViewHeight()
    }
    
}
