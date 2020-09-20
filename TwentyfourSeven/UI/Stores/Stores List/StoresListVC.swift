//
//  StoresListVC.swift
//  TwentyfourSeven
//
//  Created by Salma  on 1/15/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import UIKit
import MBProgressHUD
import Toaster
import CoreLocation

class StoresListVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backImg: UIBarButtonItem!
    
    //no network
    @IBOutlet weak var noNetworkView: UIView!
    @IBOutlet weak var noNetworkTitleLbl: UILabel!
    @IBOutlet weak var noNetworkDescLbl: UILabel!
    @IBOutlet weak var noNetworkReloadLbl: UILabel!
    @IBOutlet weak var noNetworkReloadImg: UIImageView!
    
    //no active Stores
    @IBOutlet weak var noActiveStoresView: UIView!
    @IBOutlet weak var noActiveStoresLogoImg: UIImageView!
    @IBOutlet weak var noActiveStoresitleLbl: UILabel!
    
    var stores = [Place]()
    var loadingView: MBProgressHUD!
    var isFromNearBy = false
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var storesListPresenter : StoresListPresenter!
    var locationManager = LocationManager()
    var currentLocation = CLLocation()
    var countryCode = ""
    var next_page_token = ""
    var category = ""
    var categoryImg = ""
    var selectedStore = Place()

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        storesListPresenter = StoresListPresenter(repository: Injection.providePlacesRepository())
        storesListPresenter.setView(view: self)
        
        if isFromNearBy{
            storesListPresenter.page = 2
            storesListPresenter.stores = self.stores
            self.navigationItem.title = "allNearbyStores".localized()
        }else{
            self.navigationItem.title = "allStores".localized()
            storesListPresenter.getAllStores(category: self.category, latitude: self.currentLocation.coordinate.latitude, longitude: self.currentLocation.coordinate.longitude, next_page_token: self.next_page_token)
        }
        
        self.tableView.addInfiniteScroll { (scrollView) -> Void in
            if self.isFromNearBy{
                self.storesListPresenter.getNearbyStores(category: self.category, latitude: self.currentLocation.coordinate.latitude, longitude: self.currentLocation.coordinate.longitude, next_page_token: self.next_page_token)
            }else{
                self.storesListPresenter.getAllStores(category: self.category, latitude: self.currentLocation.coordinate.latitude, longitude: self.currentLocation.coordinate.longitude, next_page_token: self.next_page_token)
            }
        }
        setUI()
        setGestures()
        setFonts()
        setLocalization()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func setUI(){
        
        if appDelegate.isRTL{
            backImg.image = UIImage(named: "back_ar_ic")
        }else{
            backImg.image = UIImage(named: "back_ic")
        }
        
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: Utils.customBoldFont(17), NSAttributedString.Key.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.barStyle = .blackOpaque
        
        noNetworkView.isHidden = true
        noActiveStoresView.isHidden = true
    }
    
    func setLocalization(){
        noNetworkTitleLbl.text = "no_network_title".localized()
        noNetworkDescLbl.text = "no_network_desc".localized()
        noNetworkReloadLbl.text = "no_network_reload".localized()
        noActiveStoresitleLbl.text = "noAllStores".localized()
    }
    
    func setFonts(){
        noNetworkTitleLbl.font = Utils.customBoldFont(noNetworkTitleLbl.font.pointSize)
        noNetworkDescLbl.font = Utils.customDefaultFont(noNetworkDescLbl.font.pointSize)
        noNetworkReloadLbl.font = Utils.customDefaultFont(noNetworkReloadLbl.font.pointSize)
        noActiveStoresitleLbl.font = Utils.customDefaultFont(noActiveStoresitleLbl.font.pointSize)

    }
    
    func setGestures(){
        
        let reloadTap = UITapGestureRecognizer(target: self, action: #selector(reloadAction))
        noNetworkReloadImg.addGestureRecognizer(reloadTap)
        
        let reloadLblTap = UITapGestureRecognizer(target: self, action: #selector(reloadAction))
        noNetworkReloadLbl.addGestureRecognizer(reloadLblTap)
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.view.endEditing(true)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func searchAction(){
        performSegue(withIdentifier: "toSearch", sender: self)
    }
    
    @objc func reloadAction(){
        if self.isFromNearBy{
            self.storesListPresenter.getNearbyStores(category: self.category, latitude: self.currentLocation.coordinate.latitude, longitude: self.currentLocation.coordinate.longitude, next_page_token: self.next_page_token)
        }else{
            self.storesListPresenter.getAllStores(category: self.category, latitude: self.currentLocation.coordinate.latitude, longitude: self.currentLocation.coordinate.longitude, next_page_token: self.next_page_token)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetails"{
            let nav = segue.destination as! UINavigationController
            let vc = nav.topViewController as! StoreDetailsVC
            self.selectedStore.icon = self.categoryImg
            vc.store = self.selectedStore
            vc.currentLocation = self.currentLocation
            vc.countryCode = countryCode
        }else if segue.identifier == "toSearch"{
            let nav = segue.destination as! UINavigationController
            let vc = nav.topViewController as! SearchStoreVC
            vc.longitude = self.currentLocation.coordinate.latitude
            vc.longitude = self.currentLocation.coordinate.longitude
            vc.countryCode = self.countryCode
        }
    }
}

extension StoresListVC : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stores.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "storeCell", for: indexPath) as! StoresCell
        cell.setCell(store: stores[indexPath.row], categoryImg: self.categoryImg, delegate: self, latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude, index: indexPath.row, isNearby: false)
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
extension StoresListVC: StoresDelegate{
    func updateStore(store: Place, index: Int, isNearby: Bool) {
        stores[index] = store
    }
    
    func selectedHeader(isNearBy: Bool) {
        
    }
    
    func selectedStore(store: Place) {
        self.selectedStore = store
        performSegue(withIdentifier: "toDetails", sender: self)
    }
    
}

extension StoresListVC : StoresListView{
    
    func showloading() {
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
        noNetworkView.isHidden = false
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
    
    func setStores(data: [Place], nextToken: String) {
        noNetworkView.isHidden = true
        self.next_page_token = nextToken
        self.stores.removeAll()
        self.stores = data
        tableView.reloadData()
    }
    
    func setNoData(){
        noActiveStoresView.isHidden = false
    }
}
