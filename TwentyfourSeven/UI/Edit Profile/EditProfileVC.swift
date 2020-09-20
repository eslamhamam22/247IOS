//
//  EditProfileVC.swift
//  TwentyfourSeven
//
//  Created by Salma  on 12/6/18.
//  Copyright © 2018 Objects. All rights reserved.
//

import UIKit
import DatePickerDialog
import Toaster
import MBProgressHUD
import Kingfisher

class EditProfileVC: UITableViewController {

    @IBOutlet weak var backImg: UIBarButtonItem!
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var loadImageLbl: UILabel!
    @IBOutlet weak var fullNameTF: UITextField!
    @IBOutlet weak var fullNameView: UIView!
    @IBOutlet weak var phoneNoTF: UITextField!
    @IBOutlet weak var phoneNoView: UIView!
    @IBOutlet weak var yearOfBirthTF: UITextField!
    @IBOutlet weak var yearOfBirthIcon: UIImageView!
    @IBOutlet weak var yearOfBirthView: UIView!
    @IBOutlet weak var genderLbl: UILabel!
    @IBOutlet weak var cityLbl: UITextField!
    @IBOutlet weak var cityView: UIView!
    @IBOutlet weak var genderSwitchImg: UIImageView!
    @IBOutlet weak var manImg: UIImageView!
    @IBOutlet weak var womanImg: UIImageView!
    @IBOutlet weak var updateBgImg: UIImageView!
    @IBOutlet weak var updateLbl: UILabel!
    @IBOutlet weak var phoneNoIcon: UIImageView!
    
    // 0 for male 1 for female
    var selectedGender = 0
    
    var photosManager = PhotosManager()
    var editProfilePresenter : EditProfilePresenter!
    var imageFile: UIImage!
    var mimeType = ""
    var date_picker : DatePickerDialog?
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var isFromMyAccount = false
    var loadingView: MBProgressHUD!
    let userDefault = UserDefault()
    var isProfilePicChanged = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        editProfilePresenter = EditProfilePresenter(repository: Injection.provideUserRepository())
        editProfilePresenter.setView(view: self)
        
        setUI()
        setGestures()
        setLocalization()
        setFonts()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUserData()
    }
    
    func setUI(){
        
        self.navigationItem.title = "accountDetails".localized()
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: Utils.customBoldFont(17), NSAttributedString.Key.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.barStyle = .blackOpaque

        setCornerRadius(selectedView: profileImg)
        setCornerRadius(selectedView: fullNameView)
        setCornerRadius(selectedView: phoneNoView)
        setCornerRadius(selectedView: cityView)
        setCornerRadius(selectedView: yearOfBirthView)
        
        if appDelegate.isRTL{
            yearOfBirthTF.textAlignment = .right
            phoneNoTF.textAlignment = .right
            fullNameTF.textAlignment = .right
            cityLbl.textAlignment = .right
            backImg.image = UIImage(named: "back_ar_ic")
        }else{
            yearOfBirthTF.textAlignment = .left
            phoneNoTF.textAlignment = .left
            fullNameTF.textAlignment = .left
            cityLbl.textAlignment = .left
            backImg.image = UIImage(named: "back_ic")
        }
        
        if !isFromMyAccount {
            self.navigationItem.leftBarButtonItem = nil
        }
        
        
        phoneNoTF.isEnabled = false
        yearOfBirthTF.isEnabled = false

        fullNameTF.delegate = self
        cityLbl.delegate = self

    }
    
    func setGestures(){
        let keyboardTap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        keyboardTap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(keyboardTap)

        let genderTab = UITapGestureRecognizer(target: self, action: #selector(self.selectGender))
        genderSwitchImg.addGestureRecognizer(genderTab)
        
        let maleTab = UITapGestureRecognizer(target: self, action: #selector(self.selectGender))
        manImg.addGestureRecognizer(maleTab)
        
        let femaleTab = UITapGestureRecognizer(target: self, action: #selector(self.selectGender))
        womanImg.addGestureRecognizer(femaleTab)
        
        let updateTab = UITapGestureRecognizer(target: self, action: #selector(self.updateAction))
        updateBgImg.addGestureRecognizer(updateTab)
        
        let updateLblTab = UITapGestureRecognizer(target: self, action: #selector(self.updateAction))
        updateLbl.addGestureRecognizer(updateLblTab)
        
        let profileTab = UITapGestureRecognizer(target: self, action: #selector(self.captureImage))
        profileImg.addGestureRecognizer(profileTab)
        
        let profileLblTab = UITapGestureRecognizer(target: self, action: #selector(self.captureImage))
        loadImageLbl.addGestureRecognizer(profileLblTab)
        
        let calenderTab = UITapGestureRecognizer(target: self, action: #selector(self.selectDate))
        yearOfBirthIcon.addGestureRecognizer(calenderTab)
        
        let calenderTxtTab = UITapGestureRecognizer(target: self, action: #selector(self.selectDate))
        yearOfBirthTF.addGestureRecognizer(calenderTxtTab)
        
        let calenderViewTab = UITapGestureRecognizer(target: self, action: #selector(self.selectDate))
        yearOfBirthView.addGestureRecognizer(calenderViewTab)
        
        let phoneIconTab = UITapGestureRecognizer(target: self, action: #selector(self.changePhoneNoAction))
        phoneNoIcon.addGestureRecognizer(phoneIconTab)
        
        let phoneTxtTab = UITapGestureRecognizer(target: self, action: #selector(self.changePhoneNoAction))
        phoneNoView.addGestureRecognizer(phoneTxtTab)
    }
    
    func setLocalization(){
        loadImageLbl.text = "loadImage".localized()
        phoneNoTF.placeholder = "phoneNoEdit".localized()
        yearOfBirthTF.placeholder = "yearOfBirth".localized()
        fullNameTF.placeholder = "fullName".localized()
        genderLbl.text = "gender".localized()
        cityLbl.placeholder = "city".localized()
        if isFromMyAccount{
            updateLbl.text = "update".localized()
        }else{
            updateLbl.text = "registerSubmit".localized()
        }
    }
    
    func setFonts(){
        loadImageLbl.font = Utils.customDefaultFont(loadImageLbl.font.pointSize)
        phoneNoTF.font = Utils.customDefaultFont(phoneNoTF.font!.pointSize)
        yearOfBirthTF.font = Utils.customDefaultFont(yearOfBirthTF.font!.pointSize)
        genderLbl.font = Utils.customDefaultFont(genderLbl.font.pointSize)
        cityLbl.font = Utils.customDefaultFont(cityLbl.font!.pointSize)
        updateLbl.font = Utils.customBoldFont(updateLbl.font.pointSize)
        fullNameTF.font = Utils.customDefaultFont(fullNameTF.font!.pointSize)
    }
    
    func setCornerRadius(selectedView : UIView){
        selectedView.layer.cornerRadius = 12
        selectedView.layer.masksToBounds = true
        selectedView.clipsToBounds = true
    }
    
    func setUserData(){
        
        let userData = userDefault.getUserData()
        if userData.name != nil {
            fullNameTF.text = userData.name
        }
        
        if userData.mobile != nil{
            phoneNoTF.text = userData.mobile
        }
        
        if userData.birthdate != nil{
            if userData.birthdate != ""{
                setDateFormat()
            }
        }
        
        if userData.image != nil{
            if userData.image?.medium != nil{
                let url = URL(string: (userData.image?.medium)!)
                print("url \(String(describing: url))")
//                self.profileImg.kf.setImage(with: url, placeholder: UIImage(named: "avatar"), options: [.forceRefresh])
                self.profileImg.kf.setImage(with: url, placeholder: UIImage(named: "avatar"))
            }
        }
        
        if userData.gender != "undefined"{
            if userData.gender == "male"{
                self.selectedGender = 1
                selectGender()
            }else if userData.gender == "female"{
                self.selectedGender = 0
                selectGender()
            }else{
                //set male by default
                self.selectedGender = 1
                selectGender()
            }
        }else{
            //set male by default
            self.selectedGender = 1
            selectGender()
        }
        
        if userData.city != "" || userData.city != "Error"{
            cityLbl.text = userData.city
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
            self.isProfilePicChanged = true
            profileImg.image = imageFile
            print("done")
        }
    }
    
    func datePickerTapped() {
        var locale = ""
        if appDelegate.isRTL{
            locale = "ar"
        }else{
            locale = "en_US_POSIX"
        }
        date_picker = DatePickerDialog.init(textColor: UIColor.black, buttonColor: Colors.hexStringToUIColor(hex: "#e84450"),
//                                            font: Utils.customAvenirBoldFont((dateLbl.font?.pointSize)!),
                                            locale: Locale(identifier: locale), showCancelButton: true)
        
        // set default date with selected before
        var defaultDate = Date()
        let dateStr = yearOfBirthTF.text
        if dateStr != nil && dateStr != ""{
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            defaultDate = dateFormatter.date(from: dateStr!)!
        }
        
        let currentDate = Date()
        var dateComponents = DateComponents()
        let calendar = Calendar.current
        dateComponents.year = 1
        
        let maxDate = calendar.date(byAdding: dateComponents, to: currentDate)
        
        let viewTab = UITapGestureRecognizer(target: self, action: #selector(self.hideKeyboard))
        date_picker?.addGestureRecognizer(viewTab)
        date_picker?.datePicker.maximumDate = maxDate
        date_picker?.show("editChooseDate".localized(), doneButtonTitle: "editDone".localized(), cancelButtonTitle: "editCancel".localized(), defaultDate: defaultDate, minimumDate: nil, maximumDate: Date(), datePickerMode: .date) { (date) in
            if let dt = date {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                print("formatter \(dt)")
                self.yearOfBirthTF.text = formatter.string(from: dt)
//                self.selectedDate = formatter.string(from: dt)
//                print("self.diaryDate \(self.selectedDate)")
//                self.collectionView.setContentOffset(CGPoint.zero, animated: true)
//                self.diaryPhotosPresenter.resetData()
//                self.diaryPhotosPresenter.getDiaryPhotos(date: self.selectedDate)
//
//                formatter.dateFormat = "MMMM d, yyyy"
//                let DateTxt = formatter.string(from: dt)
//                self.dateLbl.text = DateTxt
                
            }
        }
    }
    
    
    @objc func hideKeyboard(){
        self.view.endEditing(true)
    }
    
    func setDateFormat(){
        
        let formatter = DateFormatter()
        formatter.calendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.ISO8601)! as Calendar
        formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale?
        formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0) as TimeZone?
        formatter.dateFormat = "yyyy-MM-dd"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ" //Your date format
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT+0:00") //Current time zone
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale?
        let date = dateFormatter.date(from: userDefault.getUserData().birthdate!)
        if date != nil{
            let dateString = formatter.string(from: date!)
            yearOfBirthTF.text = dateString
        }
    }
    
    @objc func updateAction(){
        self.view.endEditing(true)
        
        if fullNameTF.text != ""{
//            if ValidateUtil.isValidName(fullNameTF.text!){
                // get user filled data
                var image : UIImage!
                if(profileImg.image != UIImage(named: "avatar")) {
                    if isProfilePicChanged{
                        image = profileImg.image!
                    }
                }
                
                var gender = ""
                if selectedGender == 0{
                    gender = "male"
                }else if selectedGender == 1{
                    gender = "female"
                }
                
                var date = ""
                if yearOfBirthTF.text != nil{
                    date = yearOfBirthTF.text!
                }
                
                var city = ""
                if cityLbl.text != nil{
                    city = cityLbl.text!
                }
                
                var mobile = ""
                if userDefault.getUserData().mobile != nil{
                    mobile = userDefault.getUserData().mobile!
                }
                
                editProfilePresenter.updateProfile(mobileNumber: mobile, name: fullNameTF.text!, birthdate: date, city: city, gender: gender, language: "", imageFile: image)
//            }else{
//                Toast.init(text: "fullnameValidation".localized()).show()
//            }
        }else{
            Toast.init(text: "fullnameError".localized()).show()
        }
    }
    
    @objc func captureImage(){
        photosManager.loadPrescriptionPic(tabBarBtnAction: false)
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.view.endEditing(true)
        dismiss(animated: true, completion: nil)
    }
    
    @objc func changePhoneNoAction(){
        performSegue(withIdentifier: "toRegisterMobile", sender: self)
    }
    
    @objc func selectGender(){
        
        if appDelegate.isRTL{
            if self.selectedGender == 0{   //male and select female
                selectedGender = 1
                genderSwitchImg.image = UIImage(named: "swith_left")
                manImg.image = UIImage(named: "man_nr_ic")
                womanImg.image = UIImage(named: "women_ac_ic-1")
                
            }else{ //female and select male
                selectedGender = 0
                genderSwitchImg.image = UIImage(named: "swith_right")
                manImg.image = UIImage(named: "man_ac_ic")
                womanImg.image = UIImage(named: "women_ac_ic")
            }
        }else{
            if self.selectedGender == 0{   //male and select female
                selectedGender = 1
                genderSwitchImg.image = UIImage(named: "swith_right")
                manImg.image = UIImage(named: "man_nr_ic")
                womanImg.image = UIImage(named: "women_ac_ic-1")
                
            }else{ //female and select male
                selectedGender = 0
                genderSwitchImg.image = UIImage(named: "swith_left")
                manImg.image = UIImage(named: "man_ac_ic")
                womanImg.image = UIImage(named: "women_ac_ic")
            }
        }
    }
    
    @objc func selectDate(){
        self.datePickerTapped()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0{
            return 200
        }else if indexPath.row == 2{
            if isFromMyAccount{
                return 80
            }else{
                return 0
            }
        }else if indexPath.row == 4{
            return 70
        }else if indexPath.row == 6{
            return 100
        }else{
            return 80
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toUserTabs"{
            let vc = segue.destination as! UserTabBar
            vc.selectedIndex = 2
        }
    }
}
extension EditProfileVC : UITextFieldDelegate{
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else {
            return true }
        let newLength = text.count + string.count - range.length
        if(textField == fullNameTF){
            return newLength <= 32
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        if textField == cityLbl{
            textField.resignFirstResponder()
            return false
        }
        return true
    }
}

extension EditProfileVC : EditProfileView{
  
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
        Toast.init(text: "connectionFailed".localized()).show()
    }
    
    func showGeneralError() {
        Toast.init(text: "general_error".localized()).show()
    }
  
    func showSuccess(userData: UserData) {
        userDefault.setUserData(userData: userData)
//        Toast.init(text: "profileUpdatedSuccess".localized()).show()
        if isFromMyAccount{
            self.dismiss(animated: true, completion: nil)
        }else{
            performSegue(withIdentifier: "toUserTabs", sender: self)
        }

    }
    
    func showValidationError() {
        Toast.init(text: "general_error".localized()).show()
    }
    
    func showSusspendedMsg(msg : String){
        Toast.init(text:msg).show()
    }
}
