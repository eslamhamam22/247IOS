//
//  StoresCategoryVC.swift
//  TwentyfourSeven
//
//  Created by Salma  on 1/13/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import UIKit
import MBProgressHUD
import Toaster
import Kingfisher

class StoresCategoryVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var headerTop: NSLayoutConstraint!
    
    
    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var noNetworkView: UIView!
    @IBOutlet weak var noNetworkTitleLbl: UILabel!
    @IBOutlet weak var noNetworkDescLbl: UILabel!
    @IBOutlet weak var noNetworkReloadLbl: UILabel!
    @IBOutlet weak var noNetworkReloadImg: UIImageView!

    
    var collectionView: UICollectionView!
    var bannerBgImg: UIImageView!
    var searchBgImg: UIImageView!
    var searchLbl: UILabel!
    var requestLocationBgImg: UIImageView!
    var requestLocationLbl: UILabel!

    var collectionBgView: UIView!

    var storesCategoryPresenter : StoresCategoryPresenter!
    var loadingView: MBProgressHUD!
    var categories = [Category]()
    var selectedCategory = Category()
    var userDefault = UserDefault()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let databaseManager = DatabaseManager()
    var isCalledCategories = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
       
        storesCategoryPresenter = StoresCategoryPresenter(repository: Injection.providePlacesRepository(), userRepoistory: Injection.provideUserRepository())
        storesCategoryPresenter.setView(view: self)
        storesCategoryPresenter.getStoresCategory()
        setUI()
        setFonts()
        setGestures()
        setLocalization()
        databaseManager.checkDelagateLocation()
        
        if hasTopNotch{
            if #available(iOS 11.0, *) {
                headerTop.constant =  UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 0
            }
        }else{
            headerTop.constant =  20
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.categories.count == 0 && isCalledCategories{
            storesCategoryPresenter.getStoresCategory()
        }
    }
    
    var hasTopNotch: Bool {
        if #available(iOS 11.0,  *) {
            return UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 0 > 20
        }
        
        return false
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func setUI(){
        self.navigationItem.title = "storesTab".localized()

        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: Utils.customBoldFont(17), NSAttributedString.Key.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.barStyle = .blackOpaque
        
        noNetworkView.isHidden = true
        tableView.isHidden = false
        
    }
    
    func setFonts(){
        noNetworkTitleLbl.font = Utils.customBoldFont(noNetworkTitleLbl.font.pointSize)
        noNetworkDescLbl.font = Utils.customDefaultFont(noNetworkDescLbl.font.pointSize)
        noNetworkReloadLbl.font = Utils.customDefaultFont(noNetworkReloadLbl.font.pointSize)
    }
    
    func setGestures(){
       
        let reloadTap = UITapGestureRecognizer(target: self, action: #selector(reloadAction))
        noNetworkReloadImg.addGestureRecognizer(reloadTap)
        
        let reloadLblTap = UITapGestureRecognizer(target: self, action: #selector(reloadAction))
        noNetworkReloadLbl.addGestureRecognizer(reloadLblTap)
    }
    
    func setLocalization(){
        noNetworkTitleLbl.text = "no_network_title".localized()
        noNetworkDescLbl.text = "no_network_desc".localized()
        noNetworkReloadLbl.text = "no_network_reload".localized()
    }
    
    
    @objc func searchAction(){
        performSegue(withIdentifier: "toSearch", sender: self)
    }
    
    @objc func requestLocationAction(){
        if userDefault.getToken() != nil{
            performSegue(withIdentifier: "toMap", sender: self)
        }else{
            appDelegate.isFromNotifications = false
            appDelegate.loadAndSetRootWindow()
        }
    }
    
    @objc func reloadAction(){
        storesCategoryPresenter.getStoresCategory()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toStoresList"{
            let nav = segue.destination as! UINavigationController
            let vc = nav.topViewController as! StoresListByNearestVC
            if selectedCategory.related_categories != nil{
                if selectedCategory.related_categories != nil{
                    vc.category = selectedCategory.related_categories!
                }
            }
            if selectedCategory.image != nil{
                if selectedCategory.image?.small != nil{
                    vc.categoryImg = (selectedCategory.image?.small)!
                }
            }
            if selectedCategory.name != nil{
                vc.categoryTitle = selectedCategory.name!
            }
        }else if segue.identifier == "toMap"{
            let navVC = segue.destination as! UINavigationController
            let vc = navVC.topViewController as! SelectFromMapVC
            vc.isFromHome = true
            vc.fromType = 1
        }
    }
    
     func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

     func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0{
            // with request location

//            return tableView.frame.height / 2 - 33
//            if screenHeight <= 568.0{ // iphone 5
//                return tableView.frame.height - 300
//            }
            if hasTopNotch{
                if #available(iOS 11.0, *) {
                    return tableView.frame.height / 2 - (UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 0) + 100
                } else {
                    return tableView.frame.height / 2 + 100
                }
            }else{
                return tableView.frame.height / 2 - 20 + 100
            }
        }else{
            if categories.count == 0{
                return 0
            }else{
                 // with request location
                print("heiht screen : \(screenHeight)")
                print("section height : \(tableView.frame.height / 2 - 28)")
                if screenHeight <= 568.0{ // iphone 5
//                    return 270
                    return tableView.frame.height / 2 - 100

                }
                return tableView.frame.height / 2 - 100
            }
        }
    }
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "headerCell", for: indexPath)
            bannerBgImg = cell.contentView.viewWithTag(1) as? UIImageView
            searchBgImg = cell.contentView.viewWithTag(2) as? UIImageView
            searchLbl = cell.contentView.viewWithTag(3) as? UILabel
            requestLocationBgImg = cell.contentView.viewWithTag(4) as? UIImageView
            requestLocationLbl = cell.contentView.viewWithTag(5) as? UILabel
            
            searchLbl.font = Utils.customDefaultFont(searchLbl.font.pointSize)
            searchLbl.text = "search".localized()
            requestLocationLbl.font = Utils.customDefaultFont(requestLocationLbl.font.pointSize)
            requestLocationLbl.text = "request_from_location".localized()

            let searchTap = UITapGestureRecognizer(target: self, action: #selector(searchAction))
            searchBgImg.addGestureRecognizer(searchTap)
            
            let searchLblTap = UITapGestureRecognizer(target: self, action: #selector(searchAction))
            searchLbl.addGestureRecognizer(searchLblTap)
            
            let requestTap = UITapGestureRecognizer(target: self, action: #selector(requestLocationAction))
            requestLocationBgImg.addGestureRecognizer(requestTap)
            
            let requestLblTap = UITapGestureRecognizer(target: self, action: #selector(requestLocationAction))
            requestLocationLbl.addGestureRecognizer(requestLblTap)
            
            return cell
        }else if indexPath.row == 1{
            let cell = tableView.dequeueReusableCell(withIdentifier: "collectionCell", for: indexPath)
            collectionBgView = cell.contentView.viewWithTag(1)
            collectionView = cell.contentView.viewWithTag(2) as? UICollectionView
            
            var height = (tableView.frame.height / 2) - 30 - 40
            if screenHeight <= 568.0{ // iphone 5
                height = 270 - 30 - 40
            }else if screenHeight >= 890{ // iphone xs max
                height -= 45
            }else if screenHeight >= 800{ // iphone x
                height -= 25
            }
            
            let filteredConstraints = collectionView.constraints.filter { $0.identifier == "height" }
            if let collectionViewHeight = filteredConstraints.first {
                collectionViewHeight.constant = height
            }
            collectionView.delegate = self
            collectionView.dataSource = self
            
            collectionBgView.layer.cornerRadius = 10
            collectionBgView.layer.masksToBounds = true
            collectionBgView.clipsToBounds = true
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "headerCell", for: indexPath) as! StoresCell
        return cell
    }
    
    // Screen height.
    public var screenHeight: CGFloat {
        return UIScreen.main.bounds.height
    }
    
}

extension StoresCategoryVC : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! StoresCategoryCollectionCell
        cell.setCell(category: categories[indexPath.row], index: indexPath.row + 1)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let width = collectionView.frame.width
        let height = (tableView.frame.height / 2) - 20 - 100
//        if screenHeight <= 568.0{ // iphone 5
//             height = 270 - 30 - 40
//        }else if screenHeight >= 890{ // iphone xs max
//            height -= 45
//        }else if screenHeight >= 800{ // iphone x
//            height -= 25
//        }
        return CGSize(width: width / 3, height: height / 2)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedCategory = categories[indexPath.row]
        performSegue(withIdentifier: "toStoresList", sender: self)
    }
}

extension StoresCategoryVC : StoresCategoryView{

    func showloading() {
        loadingView = MBProgressHUD.showAdded(to: self.view, animated: true)
        loadingView.mode = MBProgressHUDMode.indeterminate
    }
    
    func hideLoading() {
        if(loadingView != nil) {
            loadingView.hide(animated: true)
            loadingView = nil
        }
        isCalledCategories = true
    }
    
    func showNetworkError() {
//        Toast.init(text: "connectionFailed".localized()).show()
        noNetworkView.isHidden = false
        tableView.isHidden = true
    }
    
    func showGeneralError() {
        Toast.init(text: "general_error".localized()).show()
    }
    
    func showSusspendedMsg(msg : String){
        Toast.init(text:msg).show()
    }
    
    func setData(data: [Category], banner: Image?, defaultCategory: Category?) {
        noNetworkView.isHidden = true
        tableView.isHidden = false
        self.categories = data
        
        //save categories in user defaults
        userDefault.setCategories(data)
        
        if defaultCategory != nil{
            userDefault.setDefaultCategory(defaultCategory)
        }
        
        if screenHeight >= 800{ // iphone x
            if banner?.big != nil {
                let url = URL(string: ((banner?.big)!))
                print("url \(String(describing: url))")
                //                self.profileImg.kf.setImage(with: url, placeholder: UIImage(named: "avatar"), options: [.forceRefresh])
                self.bannerBgImg.kf.setImage(with: url, placeholder: UIImage(named: "louding_img"))
            }
        }else{
            if banner?.banner != nil {
                let url = URL(string: ((banner?.banner)!))
                print("url \(String(describing: url))")
                //                self.profileImg.kf.setImage(with: url, placeholder: UIImage(named: "avatar"), options: [.forceRefresh])
                self.bannerBgImg.kf.setImage(with: url, placeholder: UIImage(named: "louding_img"))
            }
        }
        
        collectionView.reloadData()
        tableView.reloadData()
    }
    
}
