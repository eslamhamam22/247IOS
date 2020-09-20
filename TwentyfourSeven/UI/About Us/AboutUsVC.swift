//
//  AboutUsVC.swift
//  TwentyfourSeven
//
//  Created by Salma  on 12/24/18.
//  Copyright © 2018 Objects. All rights reserved.
//

import UIKit
import Toaster
import MBProgressHUD
import Kingfisher

class AboutUsVC: UITableViewController {

    //@IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var contentLbl: UILabel!
    @IBOutlet weak var contentImg: UIImageView!
    @IBOutlet weak var appVersionLbl: UILabel!
    @IBOutlet weak var copyrightsLbl: UILabel!
    @IBOutlet weak var backImg: UIBarButtonItem!

    var aboutUsPresenter : AboutUsPresenter!
    var loadingView: MBProgressHUD!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var aboutUsData = PagesData()
    
    var imageCellHeight : CGFloat = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        aboutUsPresenter = AboutUsPresenter(repository: Injection.provideInfoRepository())
        aboutUsPresenter.setView(view: self)
        aboutUsPresenter.getAboutUs()
        
        setUI()
        setFonts()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func setUI(){
        
        //self.navigationItem.title = "aboutUs".localized()
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: Utils.customBoldFont(17), NSAttributedString.Key.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.barStyle = .blackOpaque

        if appDelegate.isRTL{
            backImg.image = UIImage(named: "back_ar_ic")
            contentLbl.textAlignment = .right
        }else{
            backImg.image = UIImage(named: "back_ic")
            contentLbl.textAlignment = .left
        }
        //titleLbl.text = ""
        contentLbl.text = ""
        appVersionLbl.text = ""
        copyrightsLbl.text = ""
    }
    
    func setFonts(){
        //titleLbl.font = Utils.customDefaultFont(titleLbl.font.pointSize)
        contentLbl.font = Utils.customDefaultFont(contentLbl.font.pointSize)
        appVersionLbl.font = Utils.customDefaultFont(appVersionLbl.font.pointSize)
        copyrightsLbl.font = Utils.customDefaultFont(copyrightsLbl.font.pointSize)

    }
    
    @IBAction func backAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat{
        return 50
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0{
            return imageCellHeight
        }else if indexPath.row == 1{
            return UITableView.automaticDimension
        }else if indexPath.row == 2{
//            let cellHeight =  20 + titleLbl.intrinsicContentSize.height + 20 + contentLbl.intrinsicContentSize.height + 14
//            let calculatedHeight = imageCellHeight + 90 + cellHeight
//            print("contentLbl: \(contentLbl.intrinsicContentSize.height) calculatedHeight: \(calculatedHeight)")
//            if tableView.bounds.size.height - calculatedHeight > 0{
//                return tableView.bounds.size.height - calculatedHeight
//            }else{
//                return 0
//            }
            return 0
        }else if indexPath.row == 3{
            return 0
        }else{
            return 50
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toNoNetwork"{
            let nav = segue.destination as! UINavigationController
            let vc = nav.topViewController as! NoNetworkVC
            vc.noNetworkDelegate = self
            vc.fromType = "about_us"
            vc.screenTitle = ""
        }
    }
}

extension AboutUsVC: NoNetworkDelegate{
    
    func setAboutUsData(data: PagesData) {
        setData(data: data)
    }
    
    func setContactUsData(data: ContactUsData) {
    }
    
    func setCarDetailsData(data: CarDetailsData) {
    }
}

extension AboutUsVC : AboutUsView{
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
    
    func setData(data: PagesData) {
        self.aboutUsData = data
        if aboutUsData.name != nil{
            self.navigationItem.title = aboutUsData.name
        }else{
            self.navigationItem.title = "aboutUs".localized()
        }
        
        if aboutUsData.image != nil{
            if aboutUsData.image?.banner != nil && aboutUsData.image?.banner != ""{
                let url = URL(string: (aboutUsData.image?.banner)!)
                print("url \(String(describing: url))")
//                contentImg.kf.setImage(with: url, placeholder: UIImage(named: "avatar"))
                contentImg.kf.setImage(with: url)
                imageCellHeight = 200
            }else{
                imageCellHeight = 0.0
            }
        }else{
            imageCellHeight = 0.0
        }

        if aboutUsData.content != nil{
//            contentLbl.text = aboutUsData.content
            let htmlString = aboutUsData.content
            var fontName = ""
            if appDelegate.isRTL{
                fontName = "BahijTheSansArabic-Plain"
            }else{
                fontName = "Montserrat-Regular"
            }
            var modifiedFont = NSString(format:"<span style=\"font-family: \(fontName);color: #6C727B; font-size: \(contentLbl.font.pointSize)\">%@</span>" as NSString, htmlString!)
            if(appDelegate.isRTL){
                modifiedFont = "<body><div style='text-align: right'> \(modifiedFont)</div></body>" as NSString
            }else{
                modifiedFont = "<body><div style='text-align: left'> \(modifiedFont)</div></body>" as NSString
            }
            
//             let modifiedFont = NSString(format:"<span style=\"color: #6C727B; font-size: \(contentLbl.font.pointSize)\">%@</span>" as NSString, htmlString!)
            print(modifiedFont)

            // works even without <html><body> </body></html> tags, BTW
            let data = modifiedFont.data(using: String.Encoding.unicode.rawValue) // mind "!"
            if data != nil{
                
                let attrStr = try? NSAttributedString( // do catch
                    data: data!,
                    options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html],
                    documentAttributes: nil)
                // suppose we have an UILabel, but any element with NSAttributedString will do
                contentLbl.attributedText = attrStr
            }else{
                contentLbl.text = ""
            }
        }else{
            contentLbl.text = ""
        }
        
        
        let appVersionString: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        appVersionLbl.text = "\("version".localized()) \(appVersionString)"
        copyrightsLbl.text = "All Copyrights reserved@24.7".localized()
        self.tableView.reloadData()
    }
    
}
