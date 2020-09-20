//
//  StoresListByNearestVC.swift
//  TwentyfourSeven
//
//  Created by Salma  on 1/14/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import UIKit
import MBProgressHUD
import Toaster
import CoreLocation

class StoresListByNearestVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backImg: UIBarButtonItem!

    //no network
    @IBOutlet weak var noNetworkView: UIView!
    @IBOutlet weak var noNetworkTitleLbl: UILabel!
    @IBOutlet weak var noNetworkDescLbl: UILabel!
    @IBOutlet weak var noNetworkReloadLbl: UILabel!
    @IBOutlet weak var noNetworkReloadImg: UIImageView!
    
    //no location
    @IBOutlet weak var noLocationView: UIView!
    @IBOutlet weak var noLocationLogoImg: UIImageView!
    @IBOutlet weak var noLocationTitleLbl: UILabel!
    @IBOutlet weak var noLocationDescLbl: UILabel!
    @IBOutlet weak var noLocationActivateLbl: UILabel!
    @IBOutlet weak var noLocationActivateImg: UIImageView!

    //no active Stores
    @IBOutlet weak var noActiveStoresView: UIView!
    @IBOutlet weak var noActiveStoresLogoImg: UIImageView!
    @IBOutlet weak var noActiveStoresitleLbl: UILabel!
    @IBOutlet weak var noActiveStoreTop: NSLayoutConstraint!

    var nearestStores = [Place]()
    var allNearestStores = [Place]()
    var nearby_next_page_token = ""
    var activeStores = [Place]()
    var storesListByNearestPresenter : StoresListByNearestPresenter!
    var loadingView: MBProgressHUD!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var userDefault = UserDefault()
    var locationManager = LocationManager()
    var currentLocation = CLLocation()
    var countryCode = ""
    var isSelectedNearBy = false
    var category = ""
    var categoryTitle = ""
    var categoryImg = ""
    var next_page_token = ""
    var selectedStore = Place()
    var isLoaded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        storesListByNearestPresenter = StoresListByNearestPresenter(repository: Injection.providePlacesRepository())
        storesListByNearestPresenter.setView(view: self)
        
        // get user location to get current location
        locationManager.determineMyCurrentLocation(isNeedCountryCode: true)
        
    //    self.tableView.addInfiniteScroll { (scrollView) -> Void in
     //       self.storesListByNearestPresenter.getActiveStores(category: self.category, latitude: self.currentLocation.coordinate.latitude, longitude: self.currentLocation.coordinate.longitude, nextToken: self.next_page_token)
      //  }
        
        noLocationView.isHidden = true
        noNetworkView.isHidden = true
        noActiveStoresView.isHidden = true
        
        setUI()
        setFonts()
        setGestures()        
        self.showloading()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.getUserLocation), name: NSNotification.Name(rawValue: "gotLocation"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "gotLocation"), object: nil)
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
        
//        self.navigationItem.title = "allStores".localized()
        
        self.navigationItem.title = categoryTitle
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: Utils.customBoldFont(17), NSAttributedString.Key.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.barStyle = .blackOpaque
    }
    
    func setFonts(){
        noLocationTitleLbl.font = Utils.customBoldFont(noLocationTitleLbl.font.pointSize)
        noLocationDescLbl.font = Utils.customDefaultFont(noLocationDescLbl.font.pointSize)
        noLocationActivateLbl.font = Utils.customDefaultFont(noLocationActivateLbl.font.pointSize)
        noActiveStoresitleLbl.font = Utils.customDefaultFont(noActiveStoresitleLbl.font.pointSize)
        
        noNetworkTitleLbl.font = Utils.customBoldFont(noNetworkTitleLbl.font.pointSize)
        noNetworkDescLbl.font = Utils.customDefaultFont(noNetworkDescLbl.font.pointSize)
        noNetworkReloadLbl.font = Utils.customDefaultFont(noNetworkReloadLbl.font.pointSize)

    }
    
    func setGestures(){

        let activatetap = UITapGestureRecognizer(target: self, action: #selector(activateAction))
        noLocationActivateImg.addGestureRecognizer(activatetap)
        
        let activateLblTap = UITapGestureRecognizer(target: self, action: #selector(activateAction))
        noLocationActivateLbl.addGestureRecognizer(activateLblTap)
        
        let reloadTap = UITapGestureRecognizer(target: self, action: #selector(reloadAction))
        noNetworkReloadImg.addGestureRecognizer(reloadTap)
        
        let reloadLblTap = UITapGestureRecognizer(target: self, action: #selector(reloadAction))
        noNetworkReloadLbl.addGestureRecognizer(reloadLblTap)
    }
    
    
    func setLocationView(){
        noLocationTitleLbl.text = "no_location_title".localized()
        noLocationDescLbl.text = "no_location_desc".localized()
        noLocationActivateLbl.text = "no_location_activate".localized()
        noLocationLogoImg.image = UIImage(named: "gps_ic")
    }
    
    func setNetworkView(){
        noNetworkTitleLbl.text = "no_network_title".localized()
        noNetworkDescLbl.text = "no_network_desc".localized()
        noNetworkReloadLbl.text = "no_network_reload".localized()
    }
    
    @objc func activateAction(){
        if noLocationLogoImg.image == UIImage(named: "gps_ic"){
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    // Checking for setting is opened or not
                    print("Setting is opened: \(success)")
                })
            }
        }else{
            storesListByNearestPresenter.resetData()
            storesListByNearestPresenter.getNearByStores(category: category, latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
        }
    }
    
    @objc func reloadAction(){
        storesListByNearestPresenter.resetData()
        storesListByNearestPresenter.getNearByStores(category: category, latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
    }
    
    @objc func getUserLocation(){
        self.hideLoading()

        if locationManager.locationStatus == "denied"{
            setLocationView()
            noLocationView.isHidden = false
        }else{
            noLocationView.isHidden = true
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "gotLocation"), object: nil)
            currentLocation = locationManager.location
            countryCode = locationManager.countryCode
            self.userDefault.setCountryCode(locationManager.countryCode)
            storesListByNearestPresenter.getNearByStores(category: category, latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
        }
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.view.endEditing(true)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func searchAction(){
        performSegue(withIdentifier: "toSearch", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toList"{
            let nav = segue.destination as! UINavigationController
            let vc = nav.topViewController as! StoresListVC
            vc.isFromNearBy = self.isSelectedNearBy
            vc.currentLocation = currentLocation
            vc.countryCode = self.countryCode
            vc.category = self.category
            vc.categoryImg = self.categoryImg
            if isSelectedNearBy{
                vc.stores = allNearestStores
                vc.next_page_token = self.nearby_next_page_token
            }
        }else if segue.identifier == "toDetails"{
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

extension StoresListByNearestVC : StoresDelegate{
    func updateStore(store: Place, index: Int, isNearby: Bool) {
        if isNearby{
            nearestStores[index] = store
        }else{
            activeStores[index] = store
        }
    }
    
    
    func selectedStore(store : Place) {
        self.selectedStore = store
        performSegue(withIdentifier: "toDetails", sender: self)
    }
    
    
    func selectedHeader(isNearBy: Bool) {
        self.isSelectedNearBy = isNearBy
        performSegue(withIdentifier: "toList", sender: self)
    }
}

extension StoresListByNearestVC : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var cellsNo = 0
        if nearestStores.count > 0{
            cellsNo = nearestStores.count + 1
        }
        if activeStores.count > 0 {
            cellsNo = cellsNo + activeStores.count + 1
        }else if activeStores.count == 0 && isLoaded{
             cellsNo = cellsNo + 1
        }
        return cellsNo
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var haveNearByStores = false
        var haveAllStores = false
        var haveAllStoresHeader = false
        
        var allStoresIndex = 0 // index of all stores array
        
        if nearestStores.count > 0{ // have near by stores
            haveNearByStores = true
            allStoresIndex = nearestStores.count
        }
        
        if activeStores.count > 0{
            haveAllStores = true
            allStoresIndex += 1
            if haveNearByStores{
                allStoresIndex += 1
            }
        }else if activeStores.count == 0{
            haveAllStoresHeader = true
        }
        
        if indexPath.row == 0{ // header cell
            if haveNearByStores { // header cell of near by
                let cell = tableView.dequeueReusableCell(withIdentifier: "headerCell", for: indexPath) as! StoresHeaderCell
                cell.setCell(isNearBy: true, delegate: self)
                return cell
            }else if haveAllStores{ // header cell of stores
                let cell = tableView.dequeueReusableCell(withIdentifier: "headerCell", for: indexPath) as! StoresHeaderCell
                cell.setCell(isNearBy: false, delegate: self)
                return cell
            }else if haveAllStoresHeader{ // header cell of stores
                let cell = tableView.dequeueReusableCell(withIdentifier: "headerCell", for: indexPath) as! StoresHeaderCell
                cell.setCell(isNearBy: false, delegate: self)
                return cell
            }
        }else if haveNearByStores && indexPath.row <= nearestStores.count{
            // near by store cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "storeCell", for: indexPath) as! StoresCell
            cell.setCell(store: nearestStores[indexPath.row - 1], categoryImg: self.categoryImg, delegate: self, latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude, index: indexPath.row - 1, isNearby: true)
            return cell
        }else if haveAllStores && haveNearByStores && indexPath.row == nearestStores.count + 1{
            // header cell of stores
            let cell = tableView.dequeueReusableCell(withIdentifier: "headerCell", for: indexPath) as! StoresHeaderCell
            cell.setCell(isNearBy: false, delegate: self)
            return cell
        }else if haveAllStoresHeader && indexPath.row == nearestStores.count + 1{
            // header cell of stores
            let cell = tableView.dequeueReusableCell(withIdentifier: "headerCell", for: indexPath) as! StoresHeaderCell
            cell.setCell(isNearBy: false, delegate: self)
            return cell
        }else if haveAllStores && indexPath.row >= allStoresIndex{
            // general store cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "storeCell", for: indexPath) as! StoresCell
            cell.setCell(store: activeStores[indexPath.row - allStoresIndex], categoryImg: self.categoryImg, delegate: self, latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude, index: indexPath.row - allStoresIndex, isNearby: false)
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "headerCell", for: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}


extension StoresListByNearestVC : StoresListByNearestView{
   
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
        setNetworkView()
        noNetworkView.isHidden = false
//        Toast.init(text: "connectionFailed".localized()).show()
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
    
    func setStores(nearestStores: [Place], activeStores: [Place], nextToken: String, nearby_next_page_token: String) {
        self.isLoaded = true
        self.next_page_token = nextToken
        self.nearby_next_page_token = nearby_next_page_token
        self.activeStores = activeStores
        self.allNearestStores = nearestStores
        if self.nearestStores.count != 2{
            self.setNearetStores(date: nearestStores)
        }
        noLocationView.isHidden = true
        noNetworkView.isHidden = true
        tableView.reloadData()
        if activeStores.count == 0{
            setNoActiveStores()
        }
    }
    
    func setNearetStores(date: [Place]){
        self.nearestStores.removeAll()
        // set first 2 stores
        for place in date{
            self.nearestStores.append(place)
            if nearestStores.count == 2{
                return
            }
        }
    }
    
    func setNoActiveStores(){
        noLocationView.isHidden = true
        noActiveStoresView.isHidden = false
        
        noActiveStoresitleLbl.text = "noActiveStores".localized()
        
        var cellHeight : CGFloat = 0.0
//        tableView.numberOfRows(inSection: 0)
        for i in 0..<4 {
            let indexPath = IndexPath(row: i, section: 0)
            let frame = tableView.rectForRow(at: indexPath)
            cellHeight = cellHeight + frame.height
        }
        noActiveStoreTop.constant = cellHeight
    }
}
