//
//  NoNetworkVC.swift
//  TwentyfourSeven
//
//  Created by Salma  on 4/4/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import UIKit
import MBProgressHUD
import Toaster

class NoNetworkVC: UIViewController {

    @IBOutlet weak var noNetworkView: UIView!
    @IBOutlet weak var noNetworkTitleLbl: UILabel!
    @IBOutlet weak var noNetworkDescLbl: UILabel!
    @IBOutlet weak var noNetworkReloadLbl: UILabel!
    @IBOutlet weak var noNetworkReloadImg: UIImageView!
    @IBOutlet weak var backImg: UIBarButtonItem!

    var loadingView: MBProgressHUD!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var fromType = ""
    var screenTitle = ""
    var noNetworkDelegate : NoNetworkDelegate!
    var noNetworkPresenter : NoNetworkPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        noNetworkPresenter = NoNetworkPresenter(infoRepository: Injection.provideInfoRepository(), delegateRepository: Injection.provideDelegateRepository(), userRepository: Injection.provideUserRepository())
        noNetworkPresenter.setView(view: self)
        
        setUI()
        setFonts()
        setLocalization()
    }

    func setUI(){
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: Utils.customBoldFont(17), NSAttributedString.Key.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.barStyle = .blackOpaque
        self.navigationItem.title = screenTitle

        if appDelegate.isRTL{
            backImg.image = UIImage(named: "back_ar_ic")
        }else{
            backImg.image = UIImage(named: "back_ic")
        }
    }
    
    func setFonts(){
        noNetworkTitleLbl.font = Utils.customBoldFont(noNetworkTitleLbl.font.pointSize)
        noNetworkDescLbl.font = Utils.customDefaultFont(noNetworkDescLbl.font.pointSize)
        noNetworkReloadLbl.font = Utils.customDefaultFont(noNetworkReloadLbl.font.pointSize)
    }

    func setLocalization(){
        noNetworkTitleLbl.text = "no_network_title".localized()
        noNetworkDescLbl.text = "no_network_desc".localized()
        noNetworkReloadLbl.text = "no_network_reload".localized()
    }
    
    @IBAction func reloadAction(){
        if noNetworkDelegate != nil{
            if fromType == "contact_us"{
                noNetworkPresenter.getContactUs()
            }else if fromType == "about_us"{
                noNetworkPresenter.getAboutUs()
            }else if fromType == "car_details"{
                noNetworkPresenter.getCarDetails()
            }
        }
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.presentingViewController?.presentingViewController?.dismiss(animated: false, completion: nil)
    }
}
extension NoNetworkVC: NoNetworkView{
    
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
        
    }
    
    func showGeneralError() {
        Toast.init(text: "general_error".localized()).show()
    }
    
    func showSusspendedMsg(msg : String){
        Toast.init(text:msg).show()
    }
    
    func setAboutUsData(data: PagesData) {
        noNetworkDelegate.setAboutUsData(data: data)
        dismiss(animated: false, completion: nil)
    }
    
    func setContactUsData(data: ContactUsData) {
        noNetworkDelegate.setContactUsData(data: data)
        dismiss(animated: false, completion: nil)
    }
    
    func setCarDetailsData(data: CarDetailsData) {
        noNetworkDelegate.setCarDetailsData(data: data)
        dismiss(animated: false, completion: nil)
    }
    
    
}
