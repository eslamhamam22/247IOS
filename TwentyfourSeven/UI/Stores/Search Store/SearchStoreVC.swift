//
//  SearchStoreVC.swift
//  TwentyfourSeven
//
//  Created by Salma  on 1/28/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import UIKit
import GooglePlaces
import CoreLocation
import Toaster

class SearchStoreVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var backBtn: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addressSearchBar: UISearchBar!
    @IBOutlet weak var nearByImg: UIImageView!

    @IBOutlet weak var noDataView: UIView!
    @IBOutlet weak var noDataLbl: UILabel!
    
    @IBOutlet weak var noNetworkView: UIView!
    @IBOutlet weak var noNetworkTitleLbl: UILabel!
    @IBOutlet weak var noNetworkDescLbl: UILabel!
    @IBOutlet weak var noNetworkReloadLbl: UILabel!
    @IBOutlet weak var noNetworkReloadImg: UIImageView!
    
    let searchBar = UISearchBar()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var userDefault = UserDefault()
    let operationQueue = OperationQueue()
    var addressArray = [GMSAutocompletePrediction]()
    var locationSearchDelegate : LocationSearchDelegate!
    var countryCode = ""
    var latitude = 0.0
    var longitude = 0.0
    var locationManager = LocationManager()
    var selectedPlaceID = ""
    var langStr = ""
    var selectedAddressLatitude = 0.0
    var selectedAddressLongitude = 0.0
    var isFromAddresses = false
    
    var token: GMSAutocompleteSessionToken = GMSAutocompleteSessionToken.init()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barStyle = .blackOpaque
        //        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        //        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        if latitude == 0.0 && longitude == 0.0{
            if userDefault.getLastKnownLocation().lat != 0.0 && userDefault.getLastKnownLocation().lng != 0.0{
                self.latitude = userDefault.getLastKnownLocation().lat!
                self.longitude = userDefault.getLastKnownLocation().lng!
                if userDefault.getCountryCode() != nil{
                    self.countryCode = userDefault.getCountryCode()!
                    print("saved countryCode: \(countryCode)")
                }
            }
        }
        
        // get user location to get current location
        locationManager.determineMyCurrentLocation(isNeedCountryCode: true)
        
        createSearchBar()
        createAddressSearchBar()
        setLocalization()
        setFonts()
        setGestures()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        if(appDelegate.isRTL)
        {
            backBtn.image = UIImage(named: "back_ar_ic")
        }else{
            backBtn.image = UIImage(named: "back_ic")
        }
        noDataLbl.text = "no_data".localized()
        noDataView.isHidden = true
        noNetworkView.isHidden = true
        
        langStr = Locale.current.languageCode ?? ""        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.getUserLocation), name: NSNotification.Name(rawValue: "gotLocation"), object: nil)
        
//        if appDelegate.isRTL{
//            UserDefaults.standard.set(["ar"], forKey: "AppleLanguages")
//            UserDefaults.standard.synchronize()
//        }else{
//            UserDefaults.standard.set(["en"], forKey: "AppleLanguages")
//            UserDefaults.standard.synchronize()
//        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "gotLocation"), object: nil)
        
//        if appDelegate.isRTL && langStr != ""{
//            UserDefaults.standard.set(["en"], forKey: "AppleLanguages")
//            UserDefaults.standard.synchronize()
//        }
    }
    
    func setLocalization(){
        noNetworkTitleLbl.text = "no_network_title".localized()
        noNetworkDescLbl.text = "no_network_desc".localized()
        noNetworkReloadLbl.text = "no_network_reload".localized()
    }
    
    func setFonts(){
        noNetworkTitleLbl.font = Utils.customBoldFont(noNetworkTitleLbl.font.pointSize)
        noNetworkDescLbl.font = Utils.customDefaultFont(noNetworkDescLbl.font.pointSize)
        noNetworkReloadLbl.font = Utils.customDefaultFont(noNetworkReloadLbl.font.pointSize)
        
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).font = Utils.customDefaultFont(15)

    }
    
    func setGestures(){
        
        let keyboardTap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        keyboardTap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(keyboardTap)
        
        let reloadTap = UITapGestureRecognizer(target: self, action: #selector(reloadAction))
        noNetworkReloadImg.addGestureRecognizer(reloadTap)
        
        let reloadLblTap = UITapGestureRecognizer(target: self, action: #selector(reloadAction))
        noNetworkReloadLbl.addGestureRecognizer(reloadLblTap)
        
        let nearbyTap = UITapGestureRecognizer(target: self, action: #selector(nearbyAction))
        nearByImg.addGestureRecognizer(nearbyTap)
    }
    
    func createSearchBar(){
        self.searchBar.showsCancelButton = false
        searchBar.placeholder = "searchByName_placeholder".localized()
        searchBar.becomeFirstResponder()
        searchBar.delegate = self
        self.searchBar.tintColor = UIColor.white
        
        self.navigationItem.titleView = searchBar
        
        searchBar.backgroundImage = UIImage()
        if let textfield = searchBar.value(forKey: "searchField") as? UITextField {
            textfield.textColor = UIColor.white
            textfield.backgroundColor = Colors.hexStringToUIColor(hex: "E84450")
            textfield.leftViewMode = .never

            let glassIconView = textfield.leftView as! UIImageView
            glassIconView.image = glassIconView.image?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
            glassIconView.tintColor = UIColor.white


            if let clearButton = textfield.value(forKey: "clearButton") as? UIButton {
                update(button: clearButton, image: UIImage(named: "delete_input_ic"), color: UIColor.white)

            }

            if textfield.responds(to: #selector(getter: UITextField.attributedPlaceholder)) {
                let attributeDict = [NSAttributedString.Key.foregroundColor: Colors.hexStringToUIColor(hex: "EA9CA2")]
                textfield.attributedPlaceholder = NSAttributedString(string: "searchByName_placeholder".localized(), attributes: attributeDict)
            }
        }
    }
    
    private func update(button: UIButton, image: UIImage?, color: UIColor?) {
        let image = (image ?? button.currentImage)?.withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.setImage(image, for: .highlighted)
        if let color = color {
            button.tintColor = color
        }
    }
    
    func createAddressSearchBar(){
        addressSearchBar.delegate = self
        addressSearchBar.showsCancelButton = false
        addressSearchBar.placeholder = "searchByAddress_placeholder".localized()
        addressSearchBar.tintColor = UIColor.darkGray
        addressSearchBar.backgroundImage = UIImage()
        setAddressSearchbarColors(isActive: false)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
    }
    
    func setAddressSearchbarColors(isActive: Bool){
        if isActive{
            if let textfield = addressSearchBar.value(forKey: "searchField") as? UITextField {
                textfield.textColor = UIColor.black
                textfield.backgroundColor = UIColor.white
                textfield.leftViewMode = .never
                
                let glassIconView = textfield.leftView as! UIImageView
                glassIconView.image = glassIconView.image?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
                glassIconView.tintColor = UIColor.lightGray
                
                let clearButton = textfield.value(forKey: "clearButton") as! UIButton
                clearButton.setImage(clearButton.imageView?.image?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate), for: .normal)
                clearButton.tintColor = UIColor.lightGray
                
            }
        }else{
            if let textfield = addressSearchBar.value(forKey: "searchField") as? UITextField {
                textfield.textColor = UIColor.black
                textfield.backgroundColor = Colors.hexStringToUIColor(hex: "d43844")
                textfield.leftViewMode = .never
                
                let glassIconView = textfield.leftView as! UIImageView
                glassIconView.image = glassIconView.image?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
                glassIconView.tintColor = UIColor.white
                
                let clearButton = textfield.value(forKey: "clearButton") as! UIButton
                clearButton.setImage(clearButton.imageView?.image?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate), for: .normal)
                clearButton.tintColor = UIColor.white
                
                if textfield.responds(to: #selector(getter: UITextField.attributedPlaceholder)) {
                    let attributeDict = [NSAttributedString.Key.foregroundColor: Colors.hexStringToUIColor(hex: "EA9CA2"),NSAttributedString.Key.font: Utils.customDefaultFont((textfield.font?.pointSize)!)]
                    textfield.attributedPlaceholder = NSAttributedString(string: "searchByAddress_placeholder".localized(), attributes: attributeDict)
                
                }
            }
        }
    }
    
    @objc func hideKeyboard(){
        print("hideKeyboard")
        searchBar.resignFirstResponder()
        self.view.endEditing(true)
    }
    
    @objc func nearbyAction(){
        self.view.endEditing(true)
        addressSearchBar.text = ""
        setAddressSearchbarColors(isActive: false)
        placeAutocomplete(text: searchBar.text!, isFromAddresses: false)
    }
    
    @objc func getUserLocation(){
        
        if locationManager.locationStatus == "denied"{
            
        }else{
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "gotLocation"), object: nil)
            self.latitude = locationManager.location.coordinate.latitude
            self.longitude = locationManager.location.coordinate.longitude
            self.countryCode = locationManager.countryCode
            self.userDefault.setCountryCode(locationManager.countryCode)
        }
    }
    
    @objc func reloadAction(){
        
        placeAutocomplete(text: searchBar.text!, isFromAddresses: false)
    }
    
    func placeAutocomplete(text:String, isFromAddresses: Bool)  {
        
        let placesClient = GMSPlacesClient()
        let filter = GMSAutocompleteFilter()
        if self.countryCode != ""{
            filter.country = self.countryCode
        }else{
            filter.country = "SA"
        }
        var bounds : GMSCoordinateBounds!
        if isFromAddresses{
            filter.type = .address
        }else{
            filter.type = .establishment
            if addressSearchBar.text == ""{ // no selected address
                if latitude != 0.0 && longitude != 0.0{
                    let userLocation = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                    bounds = GMSCoordinateBounds(coordinate: userLocation, coordinate: userLocation)
                }
            }else{ // bounds with the selected address coordinates
                if selectedAddressLatitude != 0.0 && selectedAddressLongitude != 0.0{
                    let userLocation = CLLocationCoordinate2D(latitude: selectedAddressLatitude, longitude: selectedAddressLongitude)
                    bounds = GMSCoordinateBounds(coordinate: userLocation, coordinate: userLocation)
                }
            }
        }
        
        placesClient.findAutocompletePredictions(fromQuery: text, bounds: bounds, boundsMode: GMSAutocompleteBoundsMode.bias, filter: filter, sessionToken: token) { (results, error) in
            self.isFromAddresses = isFromAddresses
            if results != nil{
                if (results?.count)! == 0{
                    self.noDataView.isHidden = false
                }else{
                    self.noDataView.isHidden = true
                }
            }
            guard error == nil else {
                print("Autocomplete error")
                self.addressArray.removeAll()
                self.tableView.reloadData()
                self.noDataView.isHidden = true
                if !Utils.isConnectedToNetwork(){
                    print("Network error")
                    self.searchBar.endEditing(true)
                    //                    Toast(text: "connectionFailed".localized(), duration: Delay.short).show()
                    self.noNetworkView.isHidden = false
                }else{
                    self.noNetworkView.isHidden = true
                }
                return
            }
            
            self.addressArray.removeAll()
            for result in results! {
                self.addressArray.append(result)
                print(result.attributedFullText.string)
                //                self.addressArray.append(result.attributedFullText.string)
                //                self.getlocationParms(placeID: result.placeID!)
                //                self.placeId.append(result.placeID!)
                //                self.searchedView = "Location"
                //                self.tableview.register(UINib(nibName: "LocationCell", bundle: nil), forCellReuseIdentifier: "LocationCell")
                //                self.tableview.separatorStyle = .none
                
                //                self.viewFiltered.isHidden = true
                //                self.constrainFilterViewHeight.constant = 0
            }
            self.noNetworkView.isHidden = true
            self.tableView.reloadData()
        }
        
        //deprecated function
//        placesClient.autocompleteQuery(text, bounds: bounds, filter: filter) { (results, error) in
//        }
    }
    
    func getlocationParms(placeID:String, addressName : String, isFromAddresses: Bool) {
        
//        let token: GMSAutocompleteSessionToken = GMSAutocompleteSessionToken.init()
        let placesClient = GMSPlacesClient()
        let fields: GMSPlaceField = GMSPlaceField(rawValue:
            UInt(GMSPlaceField.name.rawValue) | UInt(GMSPlaceField.placeID.rawValue) | UInt(GMSPlaceField.coordinate.rawValue) | UInt(GMSPlaceField.formattedAddress.rawValue) | UInt(GMSPlaceField.photos.rawValue))!
        placesClient.fetchPlace(fromPlaceID: placeID, placeFields: fields, sessionToken: token) { (place, error) in
            
            //refresh token after selection
            self.token = GMSAutocompleteSessionToken.init()
            
            if let error = error {
                print("lookup place id query error: \(error.localizedDescription)")
                return
            }
            
            guard let place = place else {
                print("No place details for \(placeID)")
                return
            }
            
            print("Place name \(String(describing: place.name))")
            print("Place address \(String(describing: place.formattedAddress))")
            print("Place placeID \(String(describing: place.placeID))")
            print("Place attributions \(place.coordinate.latitude)")
            print("Place attributions \(place.coordinate.longitude)")
            if isFromAddresses{
                self.selectedAddressLatitude = place.coordinate.latitude
                self.selectedAddressLongitude = place.coordinate.longitude
                self.addressSearchBar.text = addressName
                // reload data with selected address
                self.placeAutocomplete(text: self.searchBar.text!, isFromAddresses: false)
            }
            if self.locationSearchDelegate != nil {
                self.locationSearchDelegate.addSearchAddress(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude, address: addressName)
            }
        }
        
        //deprecated function
//        placesClient.lookUpPlaceID(placeID, callback: { (place, error) -> Void in
//        })
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell  = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath) as! SearchStoreCell
        if addressArray.count >= indexPath.row + 1{
            cell.setCell(address: addressArray[indexPath.row].attributedFullText.string, title: addressArray[indexPath.row].attributedPrimaryText.string)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addressArray.count
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        view.endEditing(true)
        if addressArray.count >= indexPath.row + 1{
            self.getlocationParms(placeID: addressArray[indexPath.row].placeID, addressName: addressArray[indexPath.row].attributedFullText.string, isFromAddresses: isFromAddresses)
            if isFromAddresses{
                
            }else{
                self.selectedPlaceID = addressArray[indexPath.row].placeID
                performSegue(withIdentifier: "toDetails", sender: self)
            }
           
        }
        
    }
    
    @IBAction func backPressed(_ sender: Any) {
        view.endEditing(true)
        self.searchBar.endEditing(true)
        //        if let navController = self.navigationController {
        //            navController.popViewController(animated: true)
        //        }
        self.dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetails"{
            let nav = segue.destination as! UINavigationController
            let vc = nav.topViewController as! StoreDetailsVC
            vc.placeID = self.selectedPlaceID
            let currentLocation = CLLocation(latitude: latitude, longitude: longitude)
            vc.currentLocation = currentLocation
            vc.countryCode = countryCode
            vc.isStoreLoaded = false
        }
    }
}

extension SearchStoreVC : UISearchBarDelegate{
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("textDidChange")
        if searchBar == self.addressSearchBar{
            
            // customize address searchbar background
            if searchBar.text == ""{
                self.selectedAddressLatitude = 0.0
                self.selectedAddressLongitude = 0.0
                setAddressSearchbarColors(isActive: false)
                placeAutocomplete(text: self.searchBar.text!, isFromAddresses: false)

            }else{
                setAddressSearchbarColors(isActive: true)
                placeAutocomplete(text: addressSearchBar.text!, isFromAddresses: true)
            }
        }else{
            if selectedAddressLatitude == 0.0 && selectedAddressLongitude == 0.0{
                addressSearchBar.text = ""
                setAddressSearchbarColors(isActive: false)
            }
            placeAutocomplete(text: searchText, isFromAddresses: false)
        }
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        print("searchBarTextDidEndEditing")
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("searchBarSearchButtonClicked")
        self.searchBar.endEditing(true)
        if searchBar == self.addressSearchBar{
            placeAutocomplete(text: searchBar.text!, isFromAddresses: true)
        }else{
            placeAutocomplete(text: searchBar.text!, isFromAddresses: false)
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        if searchBar == self.addressSearchBar{
            self.selectedAddressLatitude = 0.0
            self.selectedAddressLongitude = 0.0
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        print("searchBarTextDidBeginEditing")
        if searchBar == addressSearchBar{
            
        }
    }
}
