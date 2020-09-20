//
//  SettingVC.swift
//  TwentyfourSeven
//
//  Created by Salma  on 12/4/18.
//  Copyright © 2018 Objects. All rights reserved.
//

import UIKit

class SettingVC: UITableViewController, Dimmable {

    @IBOutlet weak var languageTitleLbl: UILabel!
    @IBOutlet weak var languageLbl: UILabel!
    @IBOutlet weak var howToUseLbl: UILabel!
    @IBOutlet weak var contactUsLbl: UILabel!
    @IBOutlet weak var aboutUsLbl: UILabel!
    @IBOutlet weak var returnPolicyLbl: UILabel!
    @IBOutlet weak var rateAppLbl: UILabel!
    @IBOutlet weak var shareAppLbl: UILabel!
    @IBOutlet weak var termsConditionsLbl: UILabel!
    
    let dimLevel: CGFloat = 0.5
    let dimSpeed: Double = 0.5
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var userDefault = UserDefault()
    var appUrl = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setLocalization()
        setUI()
        setFonts()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func setUI(){
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: Utils.customBoldFont(17), NSAttributedString.Key.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.barStyle = .blackOpaque
        
        if appDelegate.isRTL{
            languageLbl.text = "arabic".localized()
        }else{
            languageLbl.text = "english".localized()
        }
        
        if userDefault.getAppUrl() != nil{
            self.appUrl = userDefault.getAppUrl()!
        }
    }
    
    func setLocalization(){
        self.navigationItem.title = "settings".localized()
        languageTitleLbl.text = "language".localized()
        termsConditionsLbl.text = "termsAndConditions".localized()
        howToUseLbl.text = "howToUse".localized()
        contactUsLbl.text = "contactUs".localized()
        aboutUsLbl.text = "aboutUs".localized()
        rateAppLbl.text = "rateApp".localized()
        shareAppLbl.text = "shareApp".localized()
        returnPolicyLbl.text = "PrivacyPolicy".localized()
    }
    
    func setFonts(){
        languageTitleLbl.font = Utils.customDefaultFont(languageTitleLbl.font.pointSize)
        languageLbl.font = Utils.customBoldFont(languageLbl.font.pointSize)
        howToUseLbl.font = Utils.customDefaultFont(howToUseLbl.font.pointSize)
        contactUsLbl.font = Utils.customDefaultFont(contactUsLbl.font.pointSize)
        aboutUsLbl.font = Utils.customDefaultFont(aboutUsLbl.font.pointSize)
        rateAppLbl.font = Utils.customDefaultFont(rateAppLbl.font.pointSize)
        shareAppLbl.font = Utils.customDefaultFont(shareAppLbl.font.pointSize)
        returnPolicyLbl.font = Utils.customDefaultFont(returnPolicyLbl.font.pointSize)
        termsConditionsLbl.font = Utils.customDefaultFont(termsConditionsLbl.font.pointSize)

    }
    
    @IBAction func unwindFromChangeLanguage(_ segue: UIStoryboardSegue) {

        dimFullScreen(.out, speed: dimSpeed)
    }
    
    func rateAppOnStore(){
        let appId = "id1448155013"
        openUrl("itms-apps://itunes.apple.com/app/" + appId)
//        openUrl(appUrl)
    }
    
    func shareApp() {
        
        var text = "shareAppURL".localized()
        text = ""
        let URL = NSURL(string: appUrl)!
        
        let actionSheet = UIAlertController(title: "", message: text, preferredStyle: UIAlertController.Style.actionSheet)
        let activityViewController = UIActivityViewController(activityItems: [text , URL], applicationActivities: nil)
        self.present(activityViewController, animated: true, completion: nil)
        let excludeActivities = [
            UIActivity.ActivityType.print,
            UIActivity.ActivityType.assignToContact,
            UIActivity.ActivityType.saveToCameraRoll,
            UIActivity.ActivityType.postToFlickr,
            UIActivity.ActivityType.airDrop]
        activityViewController.excludedActivityTypes = excludeActivities;
        let dismissAction = UIAlertAction(title: "cancel".localized(), style: UIAlertAction.Style.cancel) { (action) -> Void in
        }
        actionSheet.addAction(dismissAction)
        present(actionSheet, animated: true, completion: nil)
    }
    
    fileprivate func openUrl(_ urlString:String) {
        let url = URL(string: urlString)!
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toChangeLanguage" {
            dimFullScreen(.in, alpha: dimLevel, speed: dimSpeed)
        }else if segue.identifier == "toHowToUse" {
            let vc = segue.destination as! HowToUseVC
            vc.isFromSetting = true
        }
    }
}

extension SettingVC{
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0{
            performSegue(withIdentifier: "toChangeLanguage", sender: self)
        }else if indexPath.row == 1{
            performSegue(withIdentifier: "toHowToUse", sender: self)
        }else if indexPath.row == 2{
            performSegue(withIdentifier: "toContactUs", sender: self)
        }else if indexPath.row == 3{
            performSegue(withIdentifier: "toAboutUs", sender: self)
        }else if indexPath.row == 4{
            performSegue(withIdentifier: "toTerms", sender: self)
        }else if indexPath.row == 5{
            performSegue(withIdentifier: "toPolicy", sender: self)
        }else if indexPath.row == 6{
            rateAppOnStore()
        }else if indexPath.row == 7{
            if appUrl != ""{
                shareApp()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 70
        }else if indexPath.row == 1{
            return 70
        }else if indexPath.row == 2{
            return 70
        }else if indexPath.row == 3{
            return 70
        }else if indexPath.row == 4{
            return 70
        }else if indexPath.row == 5{
            return 70
        }else if indexPath.row == 6{
            return 70
        }else if indexPath.row == 7{
            return 70
        }
        return 0
    }
}
