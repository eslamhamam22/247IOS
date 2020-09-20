//
//  ChangeLanguageVC.swift
//  TwentyfourSeven
//
//  Created by Salma  on 12/11/18.
//  Copyright © 2018 Objects. All rights reserved.
//

import UIKit
import Toaster

class ChangeLanguageVC: UIViewController {

    @IBOutlet weak var englishLbl: UILabel!
    @IBOutlet weak var englishIcon: UIImageView!
    @IBOutlet weak var arabicLbl: UILabel!
    @IBOutlet weak var arabicIcon: UIImageView!
    @IBOutlet weak var englishView: UIView!
    @IBOutlet weak var arabicView: UIView!
    @IBOutlet weak var backgroundView: UIView!
    
    let useDefault = UserDefault()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var changeLanguagePresenter : ChangeLanguagePresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        changeLanguagePresenter = ChangeLanguagePresenter(repository: Injection.provideUserRepository())
        changeLanguagePresenter.setView(view: self)
        setLocalization()
        setFonts()
        setUI()
        setGestures()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func setUI(){
        backgroundView.layer.cornerRadius = 12
        backgroundView.layer.masksToBounds = true
        backgroundView.clipsToBounds = true
        
        if appDelegate.isRTL{
            arabicIcon.isHidden = false
            arabicLbl.textColor = Colors.hexStringToUIColor(hex: "366DB3")
            englishIcon.isHidden = true
            englishLbl.textColor = Colors.hexStringToUIColor(hex: "212121")
        }else{
            englishIcon.isHidden = false
            englishLbl.textColor = Colors.hexStringToUIColor(hex: "366DB3")
            arabicIcon.isHidden = true
            arabicLbl.textColor = Colors.hexStringToUIColor(hex: "212121")
        }
    }
    
    func setLocalization(){
        arabicLbl.text = "arabic".localized()
        englishLbl.text = "english".localized()
    }
    
    func setGestures(){
        let englishTab = UITapGestureRecognizer(target: self, action: #selector(self.englishAction(_:)))
        englishView.addGestureRecognizer(englishTab)
        
        let arabicTab = UITapGestureRecognizer(target: self, action: #selector(self.arabicAction(_:)))
        arabicView.addGestureRecognizer(arabicTab)
        
        let viewTab = UITapGestureRecognizer(target: self, action: #selector(self.cancelAction(_:)))
        viewTab.cancelsTouchesInView = false
        view.addGestureRecognizer(viewTab)
    }
    
    func setFonts(){
        arabicLbl.font = Utils.customDefaultFont(arabicLbl.font.pointSize)
        englishLbl.font = Utils.customDefaultFont(englishLbl.font.pointSize)
    }
    
    @IBAction func englishAction(_ sender: Any) {
        self.useDefault.setLanguage("en")
        if useDefault.getToken() != nil{
            self.changeLanguagePresenter.changeLanguage(language: "en")
        }
        self.appDelegate.initLanguage()
        self.appDelegate.isFromNotifications = false
        self.appDelegate.loadAndSetRootWindow()
    }
    
    @IBAction func arabicAction(_ sender: Any) {
        self.useDefault.setLanguage("ar")
        if useDefault.getToken() != nil{
            self.changeLanguagePresenter.changeLanguage(language: "ar")
        }
        self.appDelegate.initLanguage()
        self.appDelegate.isFromNotifications = false
        self.appDelegate.loadAndSetRootWindow()
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        performSegue(withIdentifier: "exit", sender: self)
    }
}

extension ChangeLanguageVC : ChangeLanguageView{
    
    func showNetworkError() {
        Toast.init(text: "connectionFailed".localized()).show()
    }
    
    func showGeneralError() {
        Toast.init(text: "general_error".localized()).show()
    }
    
    func showValidationError() {
        Toast.init(text: "general_error".localized()).show()
    }
    
    func showSusspendedMsg(msg : String){
        Toast.init(text:msg).show()
    }
}
