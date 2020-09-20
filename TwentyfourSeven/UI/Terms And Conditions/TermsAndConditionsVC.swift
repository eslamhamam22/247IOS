//
//  TermsAndConditionsVC.swift
//  TwentyfourSeven
//
//  Created by Salma  on 12/6/18.
//  Copyright © 2018 Objects. All rights reserved.
//

import UIKit
import Toaster
import MBProgressHUD

class TermsAndConditionsVC: UIViewController {

    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var backImg: UIImageView!
    @IBOutlet weak var tableView: UITableView!

    //no network
    @IBOutlet weak var noNetworkView: UIView!
    @IBOutlet weak var noNetworkTitleLbl: UILabel!
    @IBOutlet weak var noNetworkDescLbl: UILabel!
    @IBOutlet weak var noNetworkReloadLbl: UILabel!
    @IBOutlet weak var noNetworkReloadImg: UIImageView!
    
    var termsAndConditionsPresenter : TermsAndConditionsPresenter!
    var loadingView: MBProgressHUD!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var termsConditionsData = PagesData()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        termsAndConditionsPresenter = TermsAndConditionsPresenter(repository: Injection.provideInfoRepository())
        termsAndConditionsPresenter.setView(view: self)
        termsAndConditionsPresenter.getTermsAndConditions()
        
        setUI()
        setGestures()
        setFonts()
    }
    
//    override var preferredStatusBarStyle: UIStatusBarStyle {
//        return .lightContent
//    }
    
    func setUI(){
        tableView.delegate = self
        tableView.dataSource = self
        titleLbl.text = ""
        
        noNetworkTitleLbl.text = "no_network_title".localized()
        noNetworkDescLbl.text = "no_network_desc".localized()
        noNetworkReloadLbl.text = "no_network_reload".localized()
        
        if appDelegate.isRTL{
            backImg.image = UIImage(named: "back_ar_ic-1")
        }else{
            backImg.image = UIImage(named: "back_ic-1")
        }
        noNetworkView.isHidden = true
    }
    
    func setGestures(){
        let backTab = UITapGestureRecognizer(target: self, action: #selector(self.backPressed))
        backImg.addGestureRecognizer(backTab)
        
        let reloadTap = UITapGestureRecognizer(target: self, action: #selector(reloadAction))
        noNetworkReloadImg.addGestureRecognizer(reloadTap)
        
        let reloadLblTap = UITapGestureRecognizer(target: self, action: #selector(reloadAction))
        noNetworkReloadLbl.addGestureRecognizer(reloadLblTap)
    }
    
    func setFonts(){
       titleLbl.font = Utils.customBoldFont(titleLbl.font.pointSize)
        
        noNetworkTitleLbl.font = Utils.customBoldFont(noNetworkTitleLbl.font.pointSize)
        noNetworkDescLbl.font = Utils.customDefaultFont(noNetworkDescLbl.font.pointSize)
        noNetworkReloadLbl.font = Utils.customDefaultFont(noNetworkReloadLbl.font.pointSize)
    }
    
    @objc func reloadAction(){
        termsAndConditionsPresenter.getTermsAndConditions()
    }
    
    @objc func backPressed(){
        self.dismiss(animated: true, completion: nil)
    }
}

extension TermsAndConditionsVC : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let descLbl = cell.contentView.viewWithTag(1) as! UILabel
        descLbl.font = Utils.customDefaultFont(descLbl.font.pointSize)
        if termsConditionsData.content != nil{
//            descLbl.text = termsConditionsData.content
            let htmlString = termsConditionsData.content
            var fontName = ""
            if appDelegate.isRTL{
                fontName = "BahijTheSansArabic-Plain"
            }else{
                fontName = "Montserrat-Regular"
            }
//            let modifiedFont = NSString(format:"<span style=\"color: #6C727B; font-size: \(descLbl.font.pointSize)\">%@</span>" as NSString, htmlString!)
            
            var modifiedFont = NSString(format:"<span style=\"font-family: \(fontName);color: #6C727B; font-size: \(descLbl.font.pointSize)\">%@</span>" as NSString, htmlString!)

            if(appDelegate.isRTL){
                modifiedFont = "<body ><div style='text-align: right'> \(modifiedFont)</div></body>" as NSString
            }else{
                modifiedFont = "<body><div style='text-align: left'> \(modifiedFont)</div></body>" as NSString
            }
            
            // works even without <html><body> </body></html> tags, BTW
            print(modifiedFont)
            let data = modifiedFont.data(using: String.Encoding(rawValue: String.Encoding.unicode.rawValue).rawValue) // mind "!"
            if data != nil{
                let attrStr = try? NSAttributedString( // do catch
                    data: data!,
                    options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html],
                    documentAttributes: nil)
                // suppose we have an UILabel, but any element with NSAttributedString will do
                descLbl.attributedText = attrStr
            }else{
                descLbl.text = ""
            }
        }else{
            descLbl.text = ""
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension TermsAndConditionsVC : TermsAndConditionsView{

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
//        Toast.init(text: "connectionFailed".localized()).show()
        noNetworkView.isHidden = false
    }
    
    func showGeneralError() {
        Toast.init(text: "general_error".localized()).show()
        noNetworkView.isHidden = true
    }
    
    func setData(data: PagesData) {
        noNetworkView.isHidden = true
        self.termsConditionsData = data
        if termsConditionsData.name != nil{
            titleLbl.text = termsConditionsData.name
        }
        self.tableView.reloadData()
    }
    
}
