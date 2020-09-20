//
//  BankTransferListVC.swift
//  TwentyfourSeven
//
//  Created by Dina Ragab on 3/21/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import UIKit
import MBProgressHUD
import Toaster

class BankTransferListVC: UIViewController {

    @IBOutlet weak var bankRequestLbl: UILabel!
    @IBOutlet weak var bankRequestView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bankTransferInfo: UILabel!
    @IBOutlet weak var back_icon: UIBarButtonItem!
    
    @IBOutlet weak var noDataView: UIView!
    @IBOutlet weak var noDataLbl: UILabel!
    
    //no network
    @IBOutlet weak var noNetworkView: UIView!
    @IBOutlet weak var noNetworkTitleLbl: UILabel!
    @IBOutlet weak var noNetworkDescLbl: UILabel!
    @IBOutlet weak var noNetworkReloadLbl: UILabel!
    @IBOutlet weak var noNetworkReloadImg: UIImageView!
    
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var bankTransferListPresenter : BankTransferListPresenter!
    var loadingView: MBProgressHUD!
    var accounts = [BankAccount]()
    
    //check screen status to show/hide views
    var state: ScreenStatus = .loaded {
        didSet {
            switch state {
            case .noData:
                noDataView.isHidden = false
                tableView.isHidden = true
                bankTransferInfo.isHidden = true
                bankRequestView.isHidden = true
                noNetworkView.isHidden = true
            case .loaded:
                noDataView.isHidden = true
                tableView.isHidden = false
                bankTransferInfo.isHidden = false
                bankRequestView.isHidden = false
                noNetworkView.isHidden = true
            case .noNetwork:
                noDataView.isHidden = true
                tableView.isHidden = true
                bankTransferInfo.isHidden = true
                bankRequestView.isHidden = true
                noNetworkView.isHidden = false
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad() 
        initPresenter()
        setUI()
    }
    
    func initPresenter(){
        bankTransferListPresenter = BankTransferListPresenter(userRepository: Injection.provideUserRepository(), walletRepository: Injection.provideWalletRepository())
        bankTransferListPresenter.setView(view: self)
    }
    
    func setUI(){
        setLocalization()
        setFonts()
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: Utils.customBoldFont(17), NSAttributedString.Key.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.barStyle = .blackOpaque
        self.navigationItem.title = "Bank_Transfer".localized()
        
        if appDelegate.isRTL{
            back_icon.image = UIImage(named: "back_ar_ic")
        }else{
            back_icon.image = UIImage(named: "back_ic")
        }
        
        bankRequestView.layer.setCornerRadious(radious: 10, maskToBounds: true)
        tableView.tableFooterView = UIView()
        
    }
    
   
    
    func setLocalization(){
        bankTransferInfo.text = "bankTransferInfo".localized()
        bankRequestLbl.text = "Submit_Transaction".localized()
        noDataLbl.text = "no_data".localized()
        noNetworkTitleLbl.text = "no_network_title".localized()
        noNetworkDescLbl.text = "no_network_desc".localized()
        noNetworkReloadLbl.text = "no_network_reload".localized()
    }
    
    func setFonts(){
        bankTransferInfo.font = Utils.customDefaultFont(bankTransferInfo.font.pointSize)
        bankRequestLbl.font = Utils.customBoldFont(bankRequestLbl.font.pointSize)
        noDataLbl.font = Utils.customDefaultFont(noDataLbl.font.pointSize)
        noNetworkTitleLbl.font = Utils.customBoldFont(noNetworkTitleLbl.font.pointSize)
        noNetworkDescLbl.font = Utils.customDefaultFont(noNetworkDescLbl.font.pointSize)
        noNetworkReloadLbl.font = Utils.customDefaultFont(noNetworkReloadLbl.font.pointSize)
    }
    
    @IBAction func backPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func requestBankTransfer(_ sender: Any) {
        print("requestBankTransfer")
        self.performSegue(withIdentifier: "bankRequest", sender: self)
    }
    
    @IBAction func reloadData(_ sender: Any) {
        if Utils.isConnectedToNetwork(){
            self.bankTransferListPresenter.getBankAccounts()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "bankRequest"{
            let destinationController = segue.destination as! UINavigationController
            let vc = destinationController.topViewController as! BankTransferRequestVC
            vc.accounts = self.accounts
        }
    }
}

extension BankTransferListVC : UITableViewDelegate , UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  accounts.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "bankCell", for: indexPath) 
        let bankName = cell.contentView.viewWithTag(1) as! UILabel
        bankName.font = Utils.customDefaultFont(bankName.font.pointSize)
        let bankAccountNo = cell.contentView.viewWithTag(2) as! UILabel
        bankAccountNo.font = Utils.customDefaultFont(bankAccountNo.font.pointSize)
        
        bankName.text = accounts[indexPath.row].bank_name ?? ""
        bankAccountNo.text = "\("account_no".localized()) \(accounts[indexPath.row].account_number ?? "")"
        
        cell.separatorInset = .zero
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}

extension BankTransferListVC:  BankTransferListView{
    
    func gotData(accounts : [BankAccount]){
        if accounts.count > 0 {
            self.accounts = accounts
            self.tableView.reloadData()
            self.state = .loaded
        }else{
            self.showNoData()
        }
    }
    
    func showNoData(){
        print("showNoData")
        self.state = .noData
    }

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
        self.state = .noNetwork
    }
    
    func showGeneralError() {
        Toast.init(text: "general_error".localized()).show()
    }
    
    func showSusspendedMsg(msg: String) {
        Toast.init(text:msg).show()
    }
    
    
}
