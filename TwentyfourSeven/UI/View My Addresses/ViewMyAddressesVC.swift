//
//  ViewMyAddressesVC.swift
//  TwentyfourSeven
//
//  Created by Salma  on 12/30/18.
//  Copyright © 2018 Objects. All rights reserved.
//

import UIKit
import MBProgressHUD
import Toaster

class ViewMyAddressesVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewBottom: NSLayoutConstraint!
    @IBOutlet weak var addAddressView: UIView!
    @IBOutlet weak var addAddressLbl: UILabel!
    @IBOutlet weak var backImg: UIBarButtonItem!

    @IBOutlet weak var noDataView: UIView!
    @IBOutlet weak var noDataLbl: UILabel!
    
    //no network
    @IBOutlet weak var noNetworkView: UIView!
    @IBOutlet weak var noNetworkTitleLbl: UILabel!
    @IBOutlet weak var noNetworkDescLbl: UILabel!
    @IBOutlet weak var noNetworkReloadLbl: UILabel!
    @IBOutlet weak var noNetworkReloadImg: UIImageView!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var loadingView: MBProgressHUD!
    let userDefault = UserDefault()
    var viewMyAddressesPresenter : ViewMyAddressesPresenter!
    var addresses = [Address]()
    var deletedAddressId = 0
    var isFromOrder = false
    var destinationDelegate : DestinationDelegate!
    var isFromHome = false
    var selectedAddress = Address()
//    0.. from my addresses    1.. from home with pickup    2.. from request with pickup   3.. from request with destination
    var fromType = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        viewMyAddressesPresenter = ViewMyAddressesPresenter(repository: Injection.provideAddressesRepository(), userRepository: Injection.provideUserRepository())
        viewMyAddressesPresenter.setView(view: self)
        viewMyAddressesPresenter.getAddesses()
        
        setUI()
        setGestures()
        setLocalization()
        setFonts()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    func setUI(){
        
        if isFromOrder{
            self.navigationItem.title = "add_from_addresses".localized()
        }else{
            self.navigationItem.title = "myAddresses".localized()
        }
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: Utils.customBoldFont(17), NSAttributedString.Key.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.barStyle = .blackOpaque
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        addAddressView.layer.cornerRadius = 12
        addAddressView.layer.masksToBounds = true
        addAddressView.clipsToBounds = true
        
        if appDelegate.isRTL{
            backImg.image = UIImage(named: "back_ar_ic")
        }else{
            backImg.image = UIImage(named: "back_ic")
        }
        if isFromOrder{ //hide add address button
            addAddressView.isHidden = true
            tableViewBottom.constant = 0
        }else{
            addAddressView.isHidden = false
            tableViewBottom.constant = 110

        }
        noDataView.isHidden = true
        noNetworkView.isHidden = true
    }
    
    func setGestures(){
        let addTab = UITapGestureRecognizer(target: self, action: #selector(self.addNewAddress))
        addAddressView.addGestureRecognizer(addTab)
        
        let addLblTab = UITapGestureRecognizer(target: self, action: #selector(self.addNewAddress))
        addAddressLbl.addGestureRecognizer(addLblTab)
        
        let reloadTap = UITapGestureRecognizer(target: self, action: #selector(reloadAction))
        noNetworkReloadImg.addGestureRecognizer(reloadTap)
        
        let reloadLblTap = UITapGestureRecognizer(target: self, action: #selector(reloadAction))
        noNetworkReloadLbl.addGestureRecognizer(reloadLblTap)
    }
    
    func setLocalization(){
        addAddressLbl.text = "addNewAddress".localized()
        noDataLbl.text = "no_data".localized()
        
        noNetworkTitleLbl.text = "no_network_title".localized()
        noNetworkDescLbl.text = "no_network_desc".localized()
        noNetworkReloadLbl.text = "no_network_reload".localized()
    }
    
    func setFonts(){
        addAddressLbl.font = Utils.customDefaultFont(addAddressLbl.font.pointSize)
        noDataLbl.font = Utils.customDefaultFont(noDataLbl.font.pointSize)
        
        noNetworkTitleLbl.font = Utils.customBoldFont(noNetworkTitleLbl.font.pointSize)
        noNetworkDescLbl.font = Utils.customDefaultFont(noNetworkDescLbl.font.pointSize)
        noNetworkReloadLbl.font = Utils.customDefaultFont(noNetworkReloadLbl.font.pointSize)
    }
    
    @objc func reloadAction(){
        viewMyAddressesPresenter.getAddesses()
    }
    
    @objc func addNewAddress(){
        performSegue(withIdentifier: "toAdd", sender: self)
    }
    
    @IBAction func backAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toAdd"{
            let vc = segue.destination as! AddAddressVC
            vc.addressesDelegate = self
        }else if segue.identifier == "toRequest"{
            let navVc = segue.destination as! UINavigationController
            let vc = navVc.topViewController as! RequestFromStoreVC
            vc.isFromRequestLocation = true
            if selectedAddress.lat != nil{
                vc.fromLat = self.selectedAddress.lat!
            }
            if selectedAddress.lng != nil{
                vc.fromLng = self.selectedAddress.lng!
            }
            if selectedAddress.address != nil{
                vc.fromLocationDesc = self.selectedAddress.address!
            }
            if selectedAddress.address_title != nil{
                vc.fromLocationTitle = self.selectedAddress.address_title!
            }
        }
    }
}
extension ViewMyAddressesVC : UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addresses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell  = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! MyAddressCell
        cell.setCell(address: addresses[indexPath.row], delegate: self, isFromOrder: self.isFromOrder)
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension ViewMyAddressesVC : ViewMyAddressesView{
   
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
        noNetworkView.isHidden = false
//        Toast.init(text: "connectionFailed".localized()).show()
    }
    
    func showGeneralError() {
        Toast.init(text: "general_error".localized()).show()
        noNetworkView.isHidden = true
    }
    
    func setData(data: [Address]) {
        noDataView.isHidden = true
        noNetworkView.isHidden = true
        self.addresses = data
        self.tableView.reloadData()
    }
    
    func showNoData() {
//        Toast.init(text: "no_data".localized()).show()
        noDataView.isHidden = false
        noNetworkView.isHidden = true

    }
    
    func showValidationError() {
        Toast.init(text: "general_error".localized()).show()
    }
    
    func showSusspendedMsg(msg : String){
        Toast.init(text:msg).show()
    }
    
    func successDelete() {
        var index = 0
        for address in self.addresses{
            if address.id == deletedAddressId{
                if index < self.addresses.count{
                    self.addresses.remove(at: index)
                    if self.addresses.count == 0{
                        noDataView.isHidden = false
                    }
                    tableView.reloadData()
                    return
                }
            }
            index = index + 1
        }
       
    }
}

extension ViewMyAddressesVC : AddressesDelegate{
 
    func deleteAddress(id: Int) {
        
        var alert : UIAlertController!
        deletedAddressId = id
        
        alert = UIAlertController(title: "", message: "deleteAddressMsg".localized(), preferredStyle: UIAlertController.Style.alert)
        
        // add an action (button)
        alert.addAction(UIAlertAction(title: "yes".localized(), style: UIAlertAction.Style.default, handler: { (action) in
            self.viewMyAddressesPresenter.deleteAddess(id: id)
        }))
        alert.addAction(UIAlertAction(title: "no".localized(), style: UIAlertAction.Style.cancel, handler: nil))
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    func addAddressSuccessfully(){
        self.viewMyAddressesPresenter.getAddesses()
    }
    
    func selectAddress(address: Address) {
        self.selectedAddress = address
        if fromType == 1{
            performSegue(withIdentifier: "toRequest", sender: self)
        }else if fromType == 2{
            self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
            destinationDelegate.selectAddress(latitude: address.lat!, longitude: address.lng!, address: address.address!, title: address.address_title!)
        }else if fromType == 3{
            self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
            destinationDelegate.selectAddress(latitude: address.lat!, longitude: address.lng!, address: address.address!, title: address.address_title!)
        }
//        if isFromHome{
//            self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
//        }else{
//            performSegue(withIdentifier: "toRequest", sender: self)
////            self.dismiss(animated: true, completion: nil)
//        }
//        destinationDelegate.selectAddress(latitude: address.lat!, longitude: address.lng!, address: address.address!, title: address.address_title!)
    }
    
}
