//
//  ProfileVC.swift
//  TwentyfourSeven
//
//  Created by Salma  on 3/26/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import UIKit
import MBProgressHUD
import Toaster
import Cosmos

class ProfileVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backIcon: UIBarButtonItem!
    
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var userNameLbl: UILabel!
    
    //rate view
    @IBOutlet weak var rateView: UIView!
    @IBOutlet weak var rateStarsView: CosmosView!
    @IBOutlet weak var ordersNoTitleLbl: UILabel!
    @IBOutlet weak var ordersNoLbl: UILabel!
    
    //no network
    @IBOutlet weak var noNetworkView: UIView!
    @IBOutlet weak var noNetworkTitleLbl: UILabel!
    @IBOutlet weak var noNetworkDescLbl: UILabel!
    @IBOutlet weak var noNetworkReloadLbl: UILabel!
    @IBOutlet weak var noNetworkReloadImg: UIImageView!

    //no data
    @IBOutlet weak var noDataView: UIView!
    @IBOutlet weak var noDataLbl: UILabel!
    
    var reviews = [Review]()
    
    var isUser = true
    var userId = 0
    var profilePresenter : ProfilePresenter!
    var loadingView: MBProgressHUD!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()

        profilePresenter = ProfilePresenter(userRepository: Injection.provideUserRepository(), delegateRepository: Injection.provideDelegateRepository())
        profilePresenter.setView(view: self)

        setUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func setUI(){
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: Utils.customBoldFont(17), NSAttributedString.Key.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.barStyle = .blackOpaque
        
        setCornerRadius(selectedView: profileImg, radius: 10)
        
        if isUser{
            profilePresenter.getUserProfile(id: userId)
            self.navigationItem.title = "Customer_Profile".localized()

        }else{
            profilePresenter.getDelegateProfile(id: userId)
            self.navigationItem.title = "Delegate_Profile".localized()
        }
        
        self.tableView.addInfiniteScroll { (scrollView) -> Void in
            if self.isUser{
                self.profilePresenter.getUserProfile(id: self.userId)
            }else{
                self.profilePresenter.getDelegateProfile(id: self.userId)
            }
        }
        
        if appDelegate.isRTL{
            backIcon.image = UIImage(named: "back_ar_ic")
        }else{
            backIcon.image = UIImage(named: "back_ic")
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        
        noNetworkView.isHidden = true
        noDataView.isHidden = true
        rateView.isHidden = true

        setFonts()
        setLocalization()
    }
    
    func setFonts(){
        ordersNoLbl.font = Utils.customDefaultFont(ordersNoLbl.font.pointSize)
        ordersNoTitleLbl.font = Utils.customDefaultFont(ordersNoTitleLbl.font.pointSize)
        userNameLbl.font = Utils.customDefaultFont(userNameLbl.font.pointSize)

        noNetworkTitleLbl.font = Utils.customBoldFont(noNetworkTitleLbl.font.pointSize)
        noNetworkDescLbl.font = Utils.customDefaultFont(noNetworkDescLbl.font.pointSize)
        noNetworkReloadLbl.font = Utils.customDefaultFont(noNetworkReloadLbl.font.pointSize)
        noDataLbl.font = Utils.customDefaultFont(noDataLbl.font.pointSize)
    }
    
    func setLocalization(){
        noNetworkTitleLbl.text = "no_network_title".localized()
        noNetworkDescLbl.text = "no_network_desc".localized()
        noNetworkReloadLbl.text = "no_network_reload".localized()
        noDataLbl.text = "no_reviews".localized()
        if isUser{
            ordersNoTitleLbl.text = "orders_no".localized()
        }else{
            ordersNoTitleLbl.text = "deliveries_no".localized()
        }
    }
    
    func setCornerRadius(selectedView : UIView, radius: CGFloat){
        selectedView.layer.cornerRadius = radius
        selectedView.layer.masksToBounds = true
        selectedView.clipsToBounds = true
    }
    
    func setShadow(selectedView : UIView){
        selectedView.layer.borderColor = UIColor.lightGray.cgColor
        selectedView.layer.borderWidth = 0
        selectedView.layer.masksToBounds = false
        selectedView.layer.shadowOffset = CGSize(width: 2, height: 2)
        selectedView.layer.shadowRadius = 3
        selectedView.layer.shadowOpacity = 0.1
    }
    
    func setUserRate(userData: UserData){
        if isUser{
            if userData.orders_count != nil{
                ordersNoLbl.text = "\(userData.orders_count!)"
            }else{
                ordersNoLbl.text = "0"
            }
            if userData.rating != nil{
                rateStarsView.rating = userData.rating!
            }else{
                rateStarsView.rating = 5
            }
        }else{
            if userData.delegate_orders_count != nil{
                ordersNoLbl.text = "\(userData.delegate_orders_count!)"
            }else{
                ordersNoLbl.text = "0"
            }
            if userData.delegate_rating != nil{
                rateStarsView.rating = userData.delegate_rating!
            }else{
                rateStarsView.rating = 5
            }
        }
    }
    
    @IBAction func reloadAction(){
        if isUser{
            profilePresenter.getUserProfile(id: userId)
        }else{
            profilePresenter.getDelegateProfile(id: userId)
        }
    }
    
    @IBAction func backAction(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
    }
}
extension ProfileVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reviews.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MyReviewsCell
        cell.setCell(review: reviews[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

extension ProfileVC: ProfileView{
    
    func showloading() {
        loadingView = MBProgressHUD.showAdded(to: self.view, animated: true)
        loadingView.mode = MBProgressHUDMode.indeterminate
    }
    
    func hideLoading() {
        if(loadingView != nil) {
            loadingView.hide(animated: true)
            loadingView = nil
        }else{
            tableView.finishInfiniteScroll()
        }
    }
    
    func showNetworkError() {
        self.noNetworkView.isHidden = false
        self.noDataView.isHidden = true
    }
    
    func showGeneralError() {
        Toast.init(text: "general_error".localized()).show()
    }
    
    func showSusspendedMsg(msg: String) {
        Toast.init(text:msg).show()
    }
    
    func stopInfinitScroll() {
        self.noNetworkView.isHidden = true
        self.tableView.isHidden = false
        self.tableView.removeInfiniteScroll()
    }
    
    func showNoData(){
        self.noDataView.isHidden = false
        self.noNetworkView.isHidden = true
    }
    
    func setData(reviews: [Review]){
        self.noDataView.isHidden = true
        self.noNetworkView.isHidden = true
        self.tableView.isHidden = false
        
        self.reviews = reviews
        
        tableView.reloadData()
    }
    
    func setUserData(userData: UserData){
        rateView.isHidden = false
        
        if userData.name != nil{
            userNameLbl.text = userData.name!
        }else{
            userNameLbl.text = ""
        }
        
        if userData.image != nil{
            if userData.image?.medium != nil{
                let url = URL(string: (userData.image?.medium)!)
                print("url \(String(describing: url))")
                self.profileImg.kf.setImage(with: url, placeholder: UIImage(named: "avatar"))
            }
        }
        
        setUserRate(userData: userData)
    }
}
