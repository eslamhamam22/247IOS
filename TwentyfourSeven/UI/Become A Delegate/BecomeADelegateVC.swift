//
//  BecomeADelegateVC.swift
//  TwentyfourSeven
//
//  Created by Salma  on 12/25/18.
//  Copyright © 2018 Objects. All rights reserved.
//

import UIKit
import Toaster
import MBProgressHUD
import Kingfisher

class BecomeADelegateVC: UITableViewController {

    @IBOutlet weak var backImg: UIBarButtonItem!
    @IBOutlet weak var personalInfoLbl: UILabel!
    @IBOutlet weak var fullNameTF: UITextField!
    @IBOutlet weak var fullNameView: UIView!
    @IBOutlet weak var phoneNoTF: UITextField!
    @IBOutlet weak var phoneNoView: UIView!
    @IBOutlet weak var cityTF: UITextField!
    @IBOutlet weak var cityView: UIView!
    @IBOutlet weak var carInfoLbl: UILabel!
    @IBOutlet weak var carBrandTF: UITextField!
    @IBOutlet weak var carBrandView: UIView!
    
    @IBOutlet weak var uploadLicenseLogo: UIImageView!
    @IBOutlet weak var uploadLicenseImg: UIImageView!
    @IBOutlet weak var uploadLicenseClose: UIImageView!
    @IBOutlet weak var uploadLicenseLbl: UILabel!
    @IBOutlet weak var uploadLicenseCover: UIView!

    @IBOutlet weak var uploadNationalLogo: UIImageView!
    @IBOutlet weak var uploadNationalImg: UIImageView!
    @IBOutlet weak var uploadNationalClose: UIImageView!
    @IBOutlet weak var uploadNationalLbl: UILabel!
    @IBOutlet weak var uploadNationalCover: UIView!

    @IBOutlet weak var carFrontLogo: UIImageView!
    @IBOutlet weak var carFrontImg: UIImageView!
    @IBOutlet weak var carFrontClose: UIImageView!
    @IBOutlet weak var carFrontLbl: UILabel!
    @IBOutlet weak var carFrontCover: UIView!

    @IBOutlet weak var carBackLogo: UIImageView!
    @IBOutlet weak var carBackImg: UIImageView!
    @IBOutlet weak var carBackClose: UIImageView!
    @IBOutlet weak var carBackLbl: UILabel!
    @IBOutlet weak var carBackCover: UIView!

    @IBOutlet weak var submitLbl: UILabel!
    @IBOutlet weak var submitView: UIImageView!
    
    @IBOutlet weak var coveredView: UIView!

    var becomeADelegatePresenter : BecomeADelegatePresenter!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let userDefault = UserDefault()
    var photosManager = PhotosManager()
    var loadingView: MBProgressHUD!
    var imageFile: UIImage!
    var mimeType = ""
    // 1 for license .. 2 for National ID .. 3 for car front .. 4 car back
    var selectedImageIndex = 0
    
    // 1 for license .. 2 for National ID .. 3 for car front .. 4 car back
    var deletedImageIndex = 0
    
    var licenseImage = DelegateImageData()
    var licenseLoadingView: MBProgressHUD!

    var nationalIDImage = DelegateImageData()
    var nationalLoadingView: MBProgressHUD!

    var frontCarImage = DelegateImageData()
    var frontCarLoadingView: MBProgressHUD!

    var backCarImage = DelegateImageData()
    var backCarLoadingView: MBProgressHUD!

    override func viewDidLoad() {
        super.viewDidLoad()
        print("width \( self.tableView.frame.width)")
        becomeADelegatePresenter = BecomeADelegatePresenter(repository: Injection.provideDelegateRepository(), userRepository: Injection.provideUserRepository())
        becomeADelegatePresenter.setView(view: self)
        setUI()
        setFonts()
        setGestures()
        setLocalization()
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
        
        setCornerRadius(selectedView: fullNameView)
        setCornerRadius(selectedView: phoneNoView)
        setCornerRadius(selectedView: cityView)
        setCornerRadius(selectedView: carBrandView)
        setCornerRadius(selectedView: uploadLicenseImg)
        setCornerRadius(selectedView: uploadNationalImg)
        setCornerRadius(selectedView: carFrontImg)
        setCornerRadius(selectedView: carBackImg)
        setCornerRadius(selectedView: coveredView)
        
        self.navigationItem.title = "becomeDelegateTitle".localized()
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: Utils.customBoldFont(17), NSAttributedString.Key.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.barStyle = .blackOpaque
        
        if appDelegate.isRTL{
            cityTF.textAlignment = .right
            phoneNoTF.textAlignment = .right
            fullNameTF.textAlignment = .right
            carBrandTF.textAlignment = .right
            backImg.image = UIImage(named: "back_ar_ic")
        }else{
            cityTF.textAlignment = .left
            phoneNoTF.textAlignment = .left
            fullNameTF.textAlignment = .left
            carBrandTF.textAlignment = .left
            backImg.image = UIImage(named: "back_ic")
        }
        
        phoneNoTF.isEnabled = false
        fullNameTF.isEnabled = false
        if userDefault.getUserData().city != nil{
            cityTF.isEnabled = false
        }else{
            cityTF.isEnabled = true
        }
        uploadLicenseClose.isHidden = true
        uploadNationalClose.isHidden = true
        carFrontClose.isHidden = true
        carBackClose.isHidden = true

        coveredView.isHidden = false
        uploadLicenseCover.isHidden = true
        uploadNationalCover.isHidden = true
        carFrontCover.isHidden = true
        carBackCover.isHidden = true

        setUserData()
        
    }
    
    
    func setFonts(){
        personalInfoLbl.font = Utils.customBoldFont(personalInfoLbl.font.pointSize)
        carInfoLbl.font = Utils.customBoldFont(carInfoLbl.font.pointSize)

        phoneNoTF.font = Utils.customDefaultFont(phoneNoTF.font!.pointSize)
        fullNameTF.font = Utils.customDefaultFont(fullNameTF.font!.pointSize)
        cityTF.font = Utils.customDefaultFont(cityTF.font!.pointSize)
        carBrandTF.font = Utils.customDefaultFont(carBrandTF.font!.pointSize)
        
        uploadLicenseLbl.font = Utils.customDefaultFont(uploadLicenseLbl.font!.pointSize)
        uploadNationalLbl.font = Utils.customDefaultFont(uploadNationalLbl.font!.pointSize)
        carFrontLbl.font = Utils.customDefaultFont(carFrontLbl.font!.pointSize)
        carBackLbl.font = Utils.customDefaultFont(carBackLbl.font!.pointSize)

        submitLbl.font = Utils.customBoldFont(submitLbl.font.pointSize)
    }
    
    func setGestures(){
        
        let keyboardTap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        keyboardTap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(keyboardTap)
        
        let licenseTab = UITapGestureRecognizer(target: self, action: #selector(self.uploadLicensePressed))
        uploadLicenseImg.addGestureRecognizer(licenseTab)
        
        let licenseIconTab = UITapGestureRecognizer(target: self, action: #selector(self.uploadLicensePressed))
        uploadLicenseLogo.addGestureRecognizer(licenseIconTab)
        
        let deleteLicenseTab = UITapGestureRecognizer(target: self, action: #selector(self.deleteLicensePressed))
        uploadLicenseClose.addGestureRecognizer(deleteLicenseTab)
        
        
        let nationalTab = UITapGestureRecognizer(target: self, action: #selector(self.uploadNationalIDPressed))
        uploadNationalImg.addGestureRecognizer(nationalTab)
        
        let nationalIconTab = UITapGestureRecognizer(target: self, action: #selector(self.uploadNationalIDPressed))
        uploadNationalLogo.addGestureRecognizer(nationalIconTab)
        
        let deleteNationalTab = UITapGestureRecognizer(target: self, action: #selector(self.deleteNationalIDPressed))
        uploadNationalClose.addGestureRecognizer(deleteNationalTab)
        
        
        let carFrontTab = UITapGestureRecognizer(target: self, action: #selector(self.uploadCarFrontPressed))
        carFrontImg.addGestureRecognizer(carFrontTab)
        
        let carFrontIconTab = UITapGestureRecognizer(target: self, action: #selector(self.uploadCarFrontPressed))
        carFrontLogo.addGestureRecognizer(carFrontIconTab)
        
        let deleteCarFrontTab = UITapGestureRecognizer(target: self, action: #selector(self.deleteCarFrontPressed))
        carFrontClose.addGestureRecognizer(deleteCarFrontTab)
        
        
        let carBackTab = UITapGestureRecognizer(target: self, action: #selector(self.uploadCarBackPressed))
        carBackImg.addGestureRecognizer(carBackTab)
        
        let carBackIconTab = UITapGestureRecognizer(target: self, action: #selector(self.uploadCarBackPressed))
        carBackLogo.addGestureRecognizer(carBackIconTab)
        
        let deleteCarBackTab = UITapGestureRecognizer(target: self, action: #selector(self.deleteCarBackPressed))
        carBackClose.addGestureRecognizer(deleteCarBackTab)
        
        let submitTab = UITapGestureRecognizer(target: self, action: #selector(self.submitPressed))
        submitView.addGestureRecognizer(submitTab)
        
        let submitLblTab = UITapGestureRecognizer(target: self, action: #selector(self.submitPressed))
        submitLbl.addGestureRecognizer(submitLblTab)
        
        cityTF.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        carBrandTF.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)

    }
    
    func setLocalization(){
        carInfoLbl.text = "CarDetails".localized()
        phoneNoTF.placeholder = "phoneNoEdit".localized()
        fullNameTF.placeholder = "fullName".localized()
        carBrandTF.placeholder = "carModel".localized()
        cityTF.placeholder = "city".localized()
        personalInfoLbl.text = "".localized()
        uploadLicenseLbl.text = "uploadLicense".localized()
        uploadNationalLbl.text = "uploadNational".localized()
        carFrontLbl.text = "uploadCarFront".localized()
        carBackLbl.text = "uploadCarBack".localized()
        submitLbl.text = "submitRequest".localized()
    }
    
    func setUserData(){
        if userDefault.getUserData().mobile != nil {
            phoneNoTF.text = userDefault.getUserData().mobile
        }
        
        if userDefault.getUserData().city != nil {
            cityTF.text = userDefault.getUserData().city
        }
        
        if userDefault.getUserData().name != nil {
            fullNameTF.text = userDefault.getUserData().name
        }
    }
    
    func resultOfCapturingImages(result : String , imageFile : UIImage, mimeType : String){
        if result == "imageTypeError"{
            Toast.init(text: "imageTypeError".localized()).show()
        }else if result == "imageSizeError"{
            Toast.init(text: "imageSizeError".localized()).show()
        }else if result == "noError"{
            self.imageFile = imageFile
            self.mimeType = mimeType
        
            switch selectedImageIndex {
            case 1:
                becomeADelegatePresenter.uploadImage(imageFile: imageFile, type: "delegate_license")
            case 2:
                becomeADelegatePresenter.uploadImage(imageFile: imageFile, type: "delegate_national_id")
            case 3:
                becomeADelegatePresenter.uploadImage(imageFile: imageFile, type: "car_front")
            case 4:
                becomeADelegatePresenter.uploadImage(imageFile: imageFile, type: "car_back")
            default:
                print("default")
            }
        }
    }
    
    @objc func hideKeyboard(){
        self.view.endEditing(true)
    }
    
    @objc func uploadLicensePressed(){
        self.view.endEditing(true)
        selectedImageIndex = 1
        photosManager.loadPrescriptionPic(tabBarBtnAction: false)
    }
    
    @objc func uploadNationalIDPressed(){
        self.view.endEditing(true)
        selectedImageIndex = 2
        photosManager.loadPrescriptionPic(tabBarBtnAction: false)
    }
    
    @objc func uploadCarFrontPressed(){
        self.view.endEditing(true)
        selectedImageIndex = 3
        photosManager.loadPrescriptionPic(tabBarBtnAction: false)
    }
    
    @objc func uploadCarBackPressed(){
        self.view.endEditing(true)
        selectedImageIndex = 4
        photosManager.loadPrescriptionPic(tabBarBtnAction: false)
    }
    
    @objc func deleteLicensePressed(){
        self.view.endEditing(true)
        if licenseImage.id != nil{
            deletedImageIndex = 1
            coveredView.isHidden = false
            becomeADelegatePresenter.deleteImage(id: licenseImage.id!, type: "delegate_license")
        }
    }
    
    @objc func deleteNationalIDPressed(){
        self.view.endEditing(true)
        if nationalIDImage.id != nil{
            deletedImageIndex = 2
            coveredView.isHidden = false
            becomeADelegatePresenter.deleteImage(id: nationalIDImage.id!, type: "delegate_national_id")
        }
    }
    
    @objc func deleteCarFrontPressed(){
        self.view.endEditing(true)
        if frontCarImage.id != nil{
            deletedImageIndex = 3
            coveredView.isHidden = false
            becomeADelegatePresenter.deleteImage(id: frontCarImage.id!, type: "car_front")
        }
    }
    
    @objc func deleteCarBackPressed(){
        self.view.endEditing(true)
        if backCarImage.id != nil{
            deletedImageIndex = 4
            coveredView.isHidden = false
            becomeADelegatePresenter.deleteImage(id: backCarImage.id!, type: "car_back")
        }
    }
    
    @objc func submitPressed(){
//        if carBrandTF.text != ""{
//            if nationalIDImage.id != nil &&  licenseImage.id != nil &&  frontCarImage.id != nil &&  backCarImage.id != nil {
//                if nationalIDImage.id != 0 && licenseImage.id != 0 && frontCarImage.id != 0 && backCarImage.id != 0{
//
//                }else{
//                    Toast.init(text: "general_error".localized()).show()
//                }
//            }else{
//                Toast.init(text: "general_error".localized()).show()
//            }
//        }else{
//            Toast.init(text: "general_error".localized()).show()
//        }
       
        if coveredView.isHidden{
            self.view.endEditing(true)
            var ids = "["
            if nationalIDImage.id != nil && nationalIDImage.id != 0{
                ids += "\(String(describing: nationalIDImage.id!)),"
            }
            
            if licenseImage.id != nil && licenseImage.id != 0{
                ids += "\(String(describing: licenseImage.id!)),"
            }
            
            if frontCarImage.id != nil && frontCarImage.id != 0{
                ids += "\(String(describing: frontCarImage.id!)),"
            }
            
            if backCarImage.id != nil && backCarImage.id != 0{
                ids += "\(String(describing: backCarImage.id!))"
            }
            ids += "]"
            becomeADelegatePresenter.requestDelegate(carDetails: carBrandTF.text!, images: ids)
        }
    }
    
    func checkValidation(){
        if uploadNationalLogo.isHidden && uploadLicenseLogo.isHidden && carBackLogo.isHidden && carFrontLogo.isHidden && carBrandTF.text != ""{
            coveredView.isHidden = true
        }else{
            coveredView.isHidden = false
        }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        checkValidation()
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.view.endEditing(true)
        dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 || indexPath.row == 1 || indexPath.row == 2 || indexPath.row == 3 {
            return 0
        }else if indexPath.row == 4{
            return 60
        }else if indexPath.row == 6{
            return  self.tableView.frame.width
        }else  if indexPath.row == 7{
            return 100
        }
        return 80
    }
 
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toMyAccount"{
            let vc = segue.destination as! UserTabBar
            vc.selectedIndex = 3
        }
    }

}
extension BecomeADelegateVC: BecomeADelegateView{
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
    
    func showImageLoading(type: String) {
        switch type {
        case "delegate_license":
            uploadLicenseCover.isHidden = false
            licenseLoadingView = MBProgressHUD.showAdded(to: self.uploadLicenseCover, animated: true)
            licenseLoadingView.mode = MBProgressHUDMode.indeterminate
        case "delegate_national_id":
            uploadNationalCover.isHidden = false
            nationalLoadingView = MBProgressHUD.showAdded(to: self.uploadNationalCover, animated: true)
            nationalLoadingView.mode = MBProgressHUDMode.indeterminate
        case "car_front":
            carFrontCover.isHidden = false
            frontCarLoadingView = MBProgressHUD.showAdded(to: self.carFrontCover, animated: true)
            frontCarLoadingView.mode = MBProgressHUDMode.indeterminate
        case "car_back":
            carBackCover.isHidden = false
            backCarLoadingView = MBProgressHUD.showAdded(to: self.carBackCover, animated: true)
            backCarLoadingView.mode = MBProgressHUDMode.indeterminate
        default:
            print("default")
        }
    }
    
    func hideImageLoading(type: String) {
        switch type {
        case "delegate_license":
            if(licenseLoadingView != nil) {
                licenseLoadingView.hide(animated: true)
                licenseLoadingView = nil
                uploadLicenseCover.isHidden = true
            }
        case "delegate_national_id":
            if(nationalLoadingView != nil) {
                nationalLoadingView.hide(animated: true)
                nationalLoadingView = nil
                uploadNationalCover.isHidden = true
            }
        case "car_front":
            if(frontCarLoadingView != nil) {
                frontCarLoadingView.hide(animated: true)
                frontCarLoadingView = nil
                carFrontCover.isHidden = true
            }
        case "car_back":
            if(backCarLoadingView != nil) {
                backCarLoadingView.hide(animated: true)
                backCarLoadingView = nil
                carBackCover.isHidden = true
            }
        default:
            print("default")
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
    
    func setImage(data: DelegateImageData, type: String) {
        
        switch type {
        case "delegate_license":
            if data.image?.small != nil && data.image?.small != ""{
                let url = URL(string: (data.image?.small)!)
                print("url \(String(describing: url))")
                uploadLicenseImg.kf.setImage(with: url, placeholder: UIImage(named: "louding_img_2"))
            }
            uploadLicenseLbl.isHidden = true
            uploadLicenseLogo.isHidden = true
            uploadLicenseClose.isHidden = false
            licenseImage = data
        case "delegate_national_id":
            if data.image?.small != nil && data.image?.small != ""{
                let url = URL(string: (data.image?.small)!)
                print("url \(String(describing: url))")
                uploadNationalImg.kf.setImage(with: url, placeholder: UIImage(named: "louding_img_2"))
            }
            uploadNationalLogo.isHidden = true
            uploadNationalLbl.isHidden = true
            uploadNationalClose.isHidden = false
            self.nationalIDImage = data
        case "car_front":
            if data.image?.small != nil && data.image?.small != ""{
                let url = URL(string: (data.image?.small)!)
                print("url \(String(describing: url))")
                carFrontImg.kf.setImage(with: url, placeholder: UIImage(named: "louding_img_2"))
            }
            carFrontLbl.isHidden = true
            carFrontLogo.isHidden = true
            carFrontClose.isHidden = false
            self.frontCarImage = data
        case "car_back":
            if data.image?.small != nil && data.image?.small != ""{
                let url = URL(string: (data.image?.small)!)
                print("url \(String(describing: url))")
                carBackImg.kf.setImage(with: url, placeholder: UIImage(named: "louding_img_2"))
            }
            carBackLogo.isHidden = true
            carBackLbl.isHidden = true
            carBackClose.isHidden = false
            self.backCarImage = data
        default:
            print("default")
        }
       
        checkValidation()
    }
    
    func successDelete(type: String){
        
        switch type {
        case "delegate_license":
            uploadLicenseImg.image = UIImage(named: "empty_image_border")
            uploadLicenseLbl.isHidden = false
            uploadLicenseLogo.isHidden = false
            uploadLicenseClose.isHidden = true
            self.licenseImage = DelegateImageData()
        case "delegate_national_id":
            uploadNationalImg.image = UIImage(named: "empty_image_border")
            uploadNationalLogo.isHidden = false
            uploadNationalLbl.isHidden = false
            uploadNationalClose.isHidden = true
            self.nationalIDImage = DelegateImageData()
        case "car_front":
            carFrontImg.image = UIImage(named: "empty_image_border")
            carFrontLbl.isHidden = false
            carFrontLogo.isHidden = false
            carFrontClose.isHidden = true
            self.frontCarImage = DelegateImageData()
        case "car_back":
            carBackImg.image = UIImage(named: "empty_image_border")
            carBackLogo.isHidden = false
            carBackLbl.isHidden = false
            carBackClose.isHidden = true
            self.backCarImage = DelegateImageData()
        default:
            print("default")
        }
        deletedImageIndex = 0
        checkValidation()
    }
    
    func successDelegateRequest(){
        let userData = userDefault.getUserData()
        userData.has_delegate_request = true
        userDefault.setUserData(userData: userData)
        Toast.init(text: "delegateRequestSentSuccess".localized()).show()
        performSegue(withIdentifier: "toMyAccount", sender: self)
    }
    
    func ShowAlreadyHaveRequest(){
        let userData = userDefault.getUserData()
        userData.has_delegate_request = true
        userDefault.setUserData(userData: userData)
        Toast.init(text: "requestAlreadySent".localized()).show()
        performSegue(withIdentifier: "toMyAccount", sender: self)
    }
}
