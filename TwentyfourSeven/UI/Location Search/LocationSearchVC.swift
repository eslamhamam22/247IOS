//
//  LocationSearchVC.swift
//  TwentyfourSeven
//
//  Created by Salma  on 1/2/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import UIKit
import GooglePlaces
import CoreLocation
import Toaster

class LocationSearchVC: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var backBtn: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
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
    var locationManager = LocationManager()

    var token: GMSAutocompleteSessionToken = GMSAutocompleteSessionToken.init()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barStyle = .blackOpaque
//        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
//        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        createSearchBar()
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
        
  
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.getUserLocation), name: NSNotification.Name(rawValue: "gotLocation"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "gotLocation"), object: nil)
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
    }
    
    func setGestures(){
        
        let keyboardTap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        keyboardTap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(keyboardTap)
        
        let reloadTap = UITapGestureRecognizer(target: self, action: #selector(reloadAction))
        noNetworkReloadImg.addGestureRecognizer(reloadTap)
        
        let reloadLblTap = UITapGestureRecognizer(target: self, action: #selector(reloadAction))
        noNetworkReloadLbl.addGestureRecognizer(reloadLblTap)
    }
    
    func createSearchBar(){
        self.searchBar.showsCancelButton = false
        searchBar.placeholder = "searchLoaction_placeholder".localized()
        searchBar.becomeFirstResponder()
        searchBar.delegate = self
        self.searchBar.tintColor = UIColor.darkGray
    
        self.navigationItem.titleView = searchBar
    }
    
    @objc func hideKeyboard(){
        print("hideKeyboard")
        searchBar.resignFirstResponder()
        self.view.endEditing(true)
    }
    
    @objc func reloadAction(){
        placeAutocomplete(text: searchBar.text!)
    }
    
    @objc func getUserLocation()
    {
        if locationManager.countryCode != "Error" && locationManager.countryCode != ""{
            self.countryCode = locationManager.countryCode
            self.userDefault.setCountryCode(locationManager.countryCode)
        }
    }
    
    func placeAutocomplete(text:String)  {
        
//        let token: GMSAutocompleteSessionToken = GMSAutocompleteSessionToken.init()
        let placesClient = GMSPlacesClient()
        let filter = GMSAutocompleteFilter()
        //        filter.type = .address
        if self.countryCode != ""{
            filter.country = self.countryCode
        }else{
            filter.country = "SA"
        }
        
        placesClient.findAutocompletePredictions(fromQuery: text, bounds: nil, boundsMode: GMSAutocompleteBoundsMode.bias, filter: filter, sessionToken: token) { (results, error) in
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
//                print(result.attributedSecondaryText!.string)
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
//        placesClient.autocompleteQuery(text, bounds: nil, filter: filter) { (results, error) in
//        }
    }
    
    func getlocationParms(placeID:String, addressName : String) {
        
//        let token: GMSAutocompleteSessionToken = GMSAutocompleteSessionToken.init()
        let placesClient = GMSPlacesClient()
        let fields: GMSPlaceField = GMSPlaceField(rawValue:
            UInt(GMSPlaceField.name.rawValue) | UInt(GMSPlaceField.placeID.rawValue) | UInt(GMSPlaceField.coordinate.rawValue) | UInt(GMSPlaceField.formattedAddress.rawValue))!
        
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
            //            self.latitude = place.coordinate.latitude
            //            self.longitude = place.coordinate.longitude
            if self.locationSearchDelegate != nil {
                self.locationSearchDelegate.addSearchAddress(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude, address: addressName)
            }
        }
        
        //deprecated function
//        placesClient.lookUpPlaceID(placeID, callback: { (place, error) -> Void in
//        })
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("textDidChange")
        //        if searchText != "" {
        //            self.searchBar.tintColor = UIColor.black
        //        }else{
        //            self.searchBar.tintColor = UIColor.clear
        //        }
        placeAutocomplete(text: searchText)
    }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        print("searchBarTextDidEndEditing")
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("searchBarSearchButtonClicked")
        self.searchBar.endEditing(true)
        placeAutocomplete(text: searchBar.text!)
    }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        print("searchBarTextDidBeginEditing")
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell  = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath) as! LocationSearchCell
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
        if addressArray.count >= indexPath.row + 1{
            self.getlocationParms(placeID: addressArray[indexPath.row].placeID, addressName: addressArray[indexPath.row].attributedFullText.string)
        }
        
        view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
        
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
    
    
}

