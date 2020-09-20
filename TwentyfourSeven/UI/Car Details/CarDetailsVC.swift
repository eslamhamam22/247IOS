//
//  CarDetailsVC.swift
//  TwentyfourSeven
//
//  Created by Salma  on 1/8/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import UIKit
import Toaster
import MBProgressHUD
import Kingfisher

class CarDetailsVC: UITableViewController {

    @IBOutlet weak var backImg: UIBarButtonItem!
    @IBOutlet weak var carInfoLbl: UILabel!
    @IBOutlet weak var carBrandTF: UITextField!
    @IBOutlet weak var carBrandView: UIView!
    
    @IBOutlet weak var uploadLicenseImg: UIImageView!
    @IBOutlet weak var uploadLicenseLbl: UILabel!

    @IBOutlet weak var uploadNationalImg: UIImageView!
    @IBOutlet weak var uploadNationalLbl: UILabel!

    @IBOutlet weak var carFrontImg: UIImageView!
    @IBOutlet weak var carFrontLbl: UILabel!

    @IBOutlet weak var carBackImg: UIImageView!
    @IBOutlet weak var carBackLbl: UILabel!

    
    var carDetailsPresenter : CarDetailsPresenter!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let userDefault = UserDefault()
    var loadingView: MBProgressHUD!
    
    var numberOfRows = 0
    var selectedImage = Image()
    var carData = CarDetailsData()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        carDetailsPresenter = CarDetailsPresenter(repository: Injection.provideDelegateRepository(), userRepository: Injection.provideUserRepository())
        carDetailsPresenter.setView(view: self)
        carDetailsPresenter.getCarDetails()
        setUI()
        setFonts()
        setLocalization()
        setGestures()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func setCornerRadius(selectedView : UIView){
        selectedView.layer.cornerRadius = 10
        selectedView.layer.masksToBounds = true
        selectedView.clipsToBounds = true
    }
    
    func setUI(){
        
       
        setCornerRadius(selectedView: carBrandView)
        setCornerRadius(selectedView: uploadLicenseImg)
        setCornerRadius(selectedView: uploadNationalImg)
        setCornerRadius(selectedView: carFrontImg)
        setCornerRadius(selectedView: carBackImg)
        
        self.navigationItem.title = "carDetailsTitle".localized()
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: Utils.customBoldFont(17), NSAttributedString.Key.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.barStyle = .blackOpaque
        
        if appDelegate.isRTL{
            carBrandTF.textAlignment = .right
            backImg.image = UIImage(named: "back_ar_ic")
        }else{
            carBrandTF.textAlignment = .left
            backImg.image = UIImage(named: "back_ic")
        }
        carBrandTF.isEnabled = false
    }

    func setFonts(){
        carInfoLbl.font = Utils.customBoldFont(carInfoLbl.font.pointSize)
        carBrandTF.font = Utils.customDefaultFont(carBrandTF.font!.pointSize)
        uploadLicenseLbl.font = Utils.customDefaultFont(uploadLicenseLbl.font!.pointSize)
        uploadNationalLbl.font = Utils.customDefaultFont(uploadNationalLbl.font!.pointSize)
        carFrontLbl.font = Utils.customDefaultFont(carFrontLbl.font!.pointSize)
        carBackLbl.font = Utils.customDefaultFont(carBackLbl.font!.pointSize)
    }
    
    func setLocalization(){
        carBrandTF.placeholder = "carModel".localized()
        carInfoLbl.text = "CarDetails".localized()
        uploadLicenseLbl.text = "uploadLicenseDetails".localized()
        uploadNationalLbl.text = "uploadNationalDetails".localized()
        carFrontLbl.text = "uploadCarFrontDetails".localized()
        carBackLbl.text = "uploadCarBackDetails".localized()
    }
    
    func setGestures(){
        
        let licenseTab = UITapGestureRecognizer(target: self, action: #selector(self.uploadLicensePressed))
        uploadLicenseImg.addGestureRecognizer(licenseTab)
        
        let nationalTab = UITapGestureRecognizer(target: self, action: #selector(self.uploadNationalIDPressed))
        uploadNationalImg.addGestureRecognizer(nationalTab)
        
        let carFrontTab = UITapGestureRecognizer(target: self, action: #selector(self.uploadCarFrontPressed))
        carFrontImg.addGestureRecognizer(carFrontTab)
        
     
        let carBackTab = UITapGestureRecognizer(target: self, action: #selector(self.uploadCarBackPressed))
        carBackImg.addGestureRecognizer(carBackTab)
   
    }
    
    @objc func uploadLicensePressed(){
        if carData.driver_license_image != nil{
            selectedImage = carData.driver_license_image!
            performSegue(withIdentifier: "toFullImage", sender: self)
        }
    }
    
    @objc func uploadNationalIDPressed(){
        if carData.national_id_image != nil{
            selectedImage = carData.national_id_image!
            performSegue(withIdentifier: "toFullImage", sender: self)
        }
    }
    
    @objc func uploadCarFrontPressed(){
        if carData.car_front_image != nil{
            selectedImage = carData.car_front_image!
            performSegue(withIdentifier: "toFullImage", sender: self)
        }
    }
    
    @objc func uploadCarBackPressed(){
        if carData.car_back_image != nil{
            selectedImage = carData.car_back_image!
            performSegue(withIdentifier: "toFullImage", sender: self)
        }
    }
    
    @IBAction func backAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfRows
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 0
        }else  if indexPath.row == 1{
            return 120
        }else if indexPath.row == 2{
            return  self.tableView.frame.width + 50
        }else  if indexPath.row == 3{
            return 20
        }
        return 80
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toFullImage"{
            let vc = segue.destination as! ViewFullImageVC
            vc.image = selectedImage
        }else if segue.identifier == "toNoNetwork"{
            let nav = segue.destination as! UINavigationController
            let vc = nav.topViewController as! NoNetworkVC
            vc.noNetworkDelegate = self
            vc.fromType = "car_details"
            vc.screenTitle = "carDetailsTitle".localized()
        }
    }
}

extension CarDetailsVC: NoNetworkDelegate{
    
    func setAboutUsData(data: PagesData) {
    }
    
    func setContactUsData(data: ContactUsData) {
    }
    
    func setCarDetailsData(data: CarDetailsData) {
        setData(data: data)
    }
}

extension CarDetailsVC: CarDetailsView{
 
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
    
    func showSusspendedMsg(msg : String){
        Toast.init(text:msg).show()
    }
    
    func setData(data: CarDetailsData) {
        self.carData = data
        if data.car_details != nil{
            carBrandTF.text = data.car_details
        }else{
            carBrandTF.text = ""
        }
        if data.driver_license_image != nil{
            if data.driver_license_image?.small != nil{
                let url = URL(string: (data.driver_license_image?.small)!)
                print("url \(String(describing: url))")
                uploadLicenseImg.kf.setImage(with: url, placeholder: UIImage(named: "grayscale"))
            }
        }
        if data.national_id_image != nil{
            if data.national_id_image?.small != nil{
                let url = URL(string: (data.national_id_image?.small)!)
                print("url \(String(describing: url))")
                uploadNationalImg.kf.setImage(with: url, placeholder: UIImage(named: "grayscale"))
            }
        }
        if data.car_front_image != nil{
            if data.car_front_image?.small != nil{
                let url = URL(string: (data.car_front_image?.small)!)
                print("url \(String(describing: url))")
                carFrontImg.kf.setImage(with: url, placeholder: UIImage(named: "grayscale"))
            }
        }
        
        if data.car_back_image != nil{
            if data.car_back_image?.small != nil{
                let url = URL(string: (data.car_back_image?.small)!)
                print("url \(String(describing: url))")
                carBackImg.kf.setImage(with: url, placeholder: UIImage(named: "grayscale"))
            }
        }
        numberOfRows = 4
        self.tableView.reloadData()
    }
    
}
