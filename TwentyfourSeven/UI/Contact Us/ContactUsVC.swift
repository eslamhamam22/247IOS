//
//  ContactUs.swift
//  TwentyfourSeven
//
//  Created by Salma  on 12/27/18.
//  Copyright © 2018 Objects. All rights reserved.
//

import UIKit
import Toaster
import MBProgressHUD
import MapKit

class ContactUsVC: UITableViewController {

    @IBOutlet weak var MapView: MKMapView!
    @IBOutlet weak var contactInfoLbl: UILabel!
    @IBOutlet weak var mobileLbl: UILabel!
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var faxLbl: UILabel!
    @IBOutlet weak var addressLbl: UILabel!
    @IBOutlet weak var linkLbl: UILabel!
    @IBOutlet weak var followUsLbl: UILabel!
    @IBOutlet weak var facebookImg: UIImageView!
    @IBOutlet weak var googleImg: UIImageView!
    @IBOutlet weak var twitterImg: UIImageView!
    @IBOutlet weak var instagramImg: UIImageView!
    @IBOutlet weak var appVersionLbl: UILabel!
    @IBOutlet weak var copyrightsLbl: UILabel!
    @IBOutlet weak var backImg: UIBarButtonItem!

    @IBOutlet weak var facebookImgWidth: NSLayoutConstraint!
    @IBOutlet weak var facebookImgTrailing: NSLayoutConstraint!

    @IBOutlet weak var twitterImgWidth: NSLayoutConstraint!
    @IBOutlet weak var twitterImgTrailing: NSLayoutConstraint!

    @IBOutlet weak var instagramImgWidth: NSLayoutConstraint!

    @IBOutlet weak var googleImgWidth: NSLayoutConstraint!
    @IBOutlet weak var googleImgTrailing: NSLayoutConstraint!

    var contactUsPresenter : ContactUsPresenter!
    var loadingView: MBProgressHUD!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var contactUsData = ContactUsData()
    var numberOfCells = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        contactUsPresenter = ContactUsPresenter(repository: Injection.provideInfoRepository())
        contactUsPresenter.setView(view: self)
        contactUsPresenter.getContactUs()
        if MapView != nil{
            MapView.delegate = self
        }
        setFonts()
        setUI()
        setGestures()
    }

    func setUI(){

        self.navigationItem.title = "contactUs".localized()
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: Utils.customBoldFont(17), NSAttributedString.Key.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.barStyle = .blackOpaque
        
        if appDelegate.isRTL{
            addressLbl.textAlignment = .right
            mobileLbl.textAlignment = .right
            emailLbl.textAlignment = .right
            faxLbl.textAlignment = .right
            linkLbl.textAlignment = .right
            backImg.image = UIImage(named: "back_ar_ic")
        }else{
            addressLbl.textAlignment = .left
            mobileLbl.textAlignment = .left
            emailLbl.textAlignment = .left
            faxLbl.textAlignment = .left
            linkLbl.textAlignment = .left
            backImg.image = UIImage(named: "back_ic")
        }
    }

    func setFonts(){
        contactInfoLbl.font = Utils.customDefaultFont(contactInfoLbl.font.pointSize)
        mobileLbl.font = Utils.customDefaultFont(mobileLbl.font.pointSize)
        emailLbl.font = Utils.customDefaultFont(emailLbl.font.pointSize)
        faxLbl.font = Utils.customDefaultFont(faxLbl.font.pointSize)
        addressLbl.font = Utils.customDefaultFont(addressLbl.font.pointSize)
        linkLbl.font = Utils.customDefaultFont(linkLbl.font.pointSize)
        followUsLbl.font = Utils.customDefaultFont(followUsLbl.font.pointSize)
        appVersionLbl.font = Utils.customDefaultFont(appVersionLbl.font.pointSize)
        copyrightsLbl.font = Utils.customDefaultFont(copyrightsLbl.font.pointSize)
    }
    
    func setGestures(){

        let mobileTab = UITapGestureRecognizer(target: self, action: #selector(self.mobileAction))
        mobileLbl.addGestureRecognizer(mobileTab)
        
        let emailTab = UITapGestureRecognizer(target: self, action: #selector(self.emailAction))
        emailLbl.addGestureRecognizer(emailTab)
        
        let faxTab = UITapGestureRecognizer(target: self, action: #selector(self.faxAction))
        faxLbl.addGestureRecognizer(faxTab)
        
        let siteTab = UITapGestureRecognizer(target: self, action: #selector(self.siteAction))
        linkLbl.addGestureRecognizer(siteTab)
        
        let fbTab = UITapGestureRecognizer(target: self, action: #selector(self.facebookAction))
        facebookImg.addGestureRecognizer(fbTab)
        
        let googleTab = UITapGestureRecognizer(target: self, action: #selector(self.googleAction))
        googleImg.addGestureRecognizer(googleTab)
        
        let instagramTab = UITapGestureRecognizer(target: self, action: #selector(self.instagramAction))
        instagramImg.addGestureRecognizer(instagramTab)
        
        let twitterTab = UITapGestureRecognizer(target: self, action: #selector(self.twitterAction))
        twitterImg.addGestureRecognizer(twitterTab)
    }
    
    @IBAction func backAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func mobileAction(){
        if contactUsData.mobile != nil{
            UIApplication.tryURL(urls: [
                "tel://\(contactUsData.mobile!)" ])
        }
    }
    
    @objc func emailAction(){
        
    }
    
    @objc func faxAction(){
        
    }
    
    @objc func siteAction(){
        if contactUsData.site_url != nil{
            UIApplication.tryURL(urls: [
              contactUsData.site_url! ])
        }
    }
    
    @objc func facebookAction(){
        if contactUsData.facebook_url != nil{
            if contactUsData.facebook_url != ""{
                let screenName =  contactUsData.facebook_url!
                UIApplication.tryURL(urls: [
                    "fb://profile/\(screenName)", // App
                    "http://www.facebook.com/\(screenName)" // Website if app fails
                    ])
            }
        }
    }
    
    @objc func instagramAction(){

        if contactUsData.instagram_url != nil{
            if contactUsData.instagram_url != ""{
                let screenName =  contactUsData.instagram_url!
                UIApplication.tryURL(urls: [
                    "instagram://user?username=\(screenName)", // App
                    "http://instagram.com/\(screenName)" // Website if app fails
                    ])
            }
        }
    }
    
    @objc func googleAction(){
        if contactUsData.google_url != nil{
            if contactUsData.google_url != ""{
                let screenName =  contactUsData.google_url!
                UIApplication.tryURL(urls: [
                    "gplus://plus.google.com/\(screenName)", // App
                    "http://plus.google.com/\(screenName)" // Website if app fails
                    ])
            }
        }
    }
    
    @objc func twitterAction(){
        if contactUsData.twitter_url != nil{
            if contactUsData.twitter_url != ""{
                let screenName =  contactUsData.twitter_url!
//                UIApplication.tryURL(urls: [
//                    "twitter://user?screen_name=\(screenName)", // App
//                    "https://twitter.com/\(screenName)" // Website if app fails
//                    ])
                UIApplication.tryURL(urls: [
                    "twitter://intent/user?user_id=\(screenName)", // App
                    "https://twitter.com/intent/user?user_id=\(screenName)" // Website if app fails
                    ])

            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfCells
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 200
        }else if indexPath.row == 1 {
            return 55
        }else if indexPath.row == 5 {
            return UITableView.automaticDimension
        }else if indexPath.row == 7 {
            return 100
        }else if indexPath.row == 8 {
            return 60
        }else if indexPath.row == 9 {
//            let cellHeight =  addressLbl.intrinsicContentSize.height + 7.5 +  9.5
//            let calculatedHeight = 625 + cellHeight
//            print("contentLbl: \(addressLbl.intrinsicContentSize.height) calculatedHeight: \(calculatedHeight)")
//            if tableView.bounds.size.height - calculatedHeight > 0{
//                return tableView.bounds.size.height - calculatedHeight
//            }else{
//                return 15
//            }
            return 0
        }else if indexPath.row == 10 {
            return 0
        }
        return 35
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toNoNetwork"{
            let nav = segue.destination as! UINavigationController
            let vc = nav.topViewController as! NoNetworkVC
            vc.noNetworkDelegate = self
            vc.fromType = "contact_us"
            vc.screenTitle = "contactUs".localized()
        }
    }
}

extension ContactUsVC: NoNetworkDelegate{
    func setAboutUsData(data: PagesData) {
        
    }
    
    func setContactUsData(data: ContactUsData) {
        setData(data: data)
    }
    
    func setCarDetailsData(data: CarDetailsData) {
        
    }
}

extension ContactUsVC : ContactUsView{
    
    func showloading() {
        loadingView = MBProgressHUD.showAdded(to: self.tableView, animated: true)
        loadingView.mode = MBProgressHUDMode.indeterminate
    }
    
    func hideLoading() {
        if(loadingView != nil) {
            loadingView.hide(animated: true)
            loadingView = nil
        }
    }
    
    func showNetworkError() {
//        Toast.init(text: "connectionFailed".localized()).show()
        performSegue(withIdentifier: "toNoNetwork", sender: self)
    }
    
    func showGeneralError() {
        Toast.init(text: "general_error".localized()).show()
        
    }
    
    func setData(data: ContactUsData) {
        self.contactUsData = data
        self.numberOfCells = 11
        
        if contactUsData.mobile != nil{
            mobileLbl.text = contactUsData.mobile
        }else{
            mobileLbl.text = ""
        }
        
        if contactUsData.email != nil{
            emailLbl.text = contactUsData.email
        }else{
            emailLbl.text = ""
        }
        
        if contactUsData.fax_number != nil{
            faxLbl.text = contactUsData.fax_number
        }else{
            faxLbl.text = ""
        }
        
        if appDelegate.isRTL{
            if contactUsData.address_ar != nil{
                addressLbl.text = contactUsData.address_ar
            }else{
                addressLbl.text = ""
            }
        }else{
            if contactUsData.address_en != nil{
                addressLbl.text = contactUsData.address_en
            }else{
                addressLbl.text = ""
            }
        }
        
        if contactUsData.site_url != nil{
            linkLbl.text = contactUsData.site_url
        }else{
            linkLbl.text = ""
        }
        
        contactInfoLbl.text = "contactUsInfo".localized()
        followUsLbl.text = "contactUsFollow".localized()
        
        setSocialIconsVisibility()
        
        setMap()
        self.tableView.reloadData()
    }
    
    func setSocialIconsVisibility(){
        if contactUsData.facebook_url != nil{
            if contactUsData.facebook_url != ""{
                facebookImg.isHidden = false
            }else{
                facebookImg.isHidden = true
                facebookImgWidth.constant = 0
                facebookImgTrailing.constant = 0
            }
        }else{
            facebookImg.isHidden = true
            facebookImgWidth.constant = 0
            facebookImgTrailing.constant = 0
        }
        
        if contactUsData.google_url != nil{
            if contactUsData.google_url != ""{
                googleImg.isHidden = false
            }else{
                googleImg.isHidden = true
                googleImgWidth.constant = 0
                googleImgTrailing.constant = 0
            }
        }else{
            googleImg.isHidden = true
            googleImgWidth.constant = 0
            googleImgTrailing.constant = 0
        }
        
        if contactUsData.twitter_url != nil{
            if contactUsData.twitter_url != ""{
                twitterImg.isHidden = false
            }else{
                twitterImg.isHidden = true
                twitterImgWidth.constant = 0
                twitterImgTrailing.constant = 0
            }
        }else{
            twitterImg.isHidden = true
            twitterImgWidth.constant = 0
            twitterImgTrailing.constant = 0
        }
        
        if contactUsData.instagram_url != nil{
            if contactUsData.instagram_url != ""{
                instagramImg.isHidden = false
            }else{
                instagramImg.isHidden = true
                instagramImgWidth.constant = 0
            }
        }else{
            instagramImg.isHidden = true
            instagramImgWidth.constant = 0
        }
    }
}

extension ContactUsVC : MKMapViewDelegate{
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else {
            return nil
        }
        
        let annotationIdentifier = "Identifier"
        var annotationView: MKAnnotationView?
        if let dequeuedAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) {
            annotationView = dequeuedAnnotationView
            annotationView?.annotation = annotation
        }
        else {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        
        if let annotationView = annotationView {
            
            annotationView.canShowCallout = true
            annotationView.image = UIImage(named:"247_pin_map")
        }
        return annotationView
    }
    
    func setMap(){
        if(contactUsData.lat != nil && contactUsData.lng != nil) {
            if(contactUsData.lat != "" && contactUsData.lng != "") {
            let latitude = Double(contactUsData.lat!)
            let longitude = Double(contactUsData.lng!)
            
            let location=CLLocationCoordinate2DMake(latitude!, longitude!)
                if MapView != nil{
                    MapView.mapType = MKMapType.standard
                    MapView.setRegion(MKCoordinateRegion(center: location, latitudinalMeters: 800, longitudinalMeters: 800), animated: true)
                    
                    //annotation
                    let pin=PinAnnotation(title: "", subtitle: "", coordinate: location)
                    MapView.addAnnotation(pin)
                }
            }
        }
    }
    
}


