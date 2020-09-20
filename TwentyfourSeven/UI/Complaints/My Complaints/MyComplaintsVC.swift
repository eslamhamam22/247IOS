//
//  MyComplaintsVC.swift
//  TwentyfourSeven
//
//  Created by Salma  on 3/25/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import UIKit
import Toaster
import MBProgressHUD

class MyComplaintsVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backIcon: UIBarButtonItem!
    
    //no network
    @IBOutlet weak var noNetworkView: UIView!
    @IBOutlet weak var noNetworkTitleLbl: UILabel!
    @IBOutlet weak var noNetworkDescLbl: UILabel!
    @IBOutlet weak var noNetworkReloadLbl: UILabel!
    @IBOutlet weak var noNetworkReloadImg: UIImageView!
    
    //no data
    @IBOutlet weak var noDataView: UIView!
    @IBOutlet weak var noDataLbl: UILabel!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var loadingView: MBProgressHUD!
    var myComplaintsPresenter : MyComplaintsPresenter!
    var complaints = [Complaint]()
    var isFromSubmit = false
    var complaintDelegate: ComplaintDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()

        myComplaintsPresenter = MyComplaintsPresenter(userRepository: Injection.provideUserRepository())
        myComplaintsPresenter.setView(view: self)
        myComplaintsPresenter.getMyComplaints()
        setUI()
    }
    
    func setUI(){
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: Utils.customBoldFont(17), NSAttributedString.Key.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.barStyle = .blackOpaque
        self.navigationItem.title = "myComplaints".localized()
        
        self.tableView.addInfiniteScroll { (scrollView) -> Void in
            self.myComplaintsPresenter.getMyComplaints()
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
        
        setFonts()
        setLocalization()
    }
    
    func setFonts(){
        noNetworkTitleLbl.font = Utils.customBoldFont(noNetworkTitleLbl.font.pointSize)
        noNetworkDescLbl.font = Utils.customDefaultFont(noNetworkDescLbl.font.pointSize)
        noNetworkReloadLbl.font = Utils.customDefaultFont(noNetworkReloadLbl.font.pointSize)
        noDataLbl.font = Utils.customDefaultFont(noDataLbl.font.pointSize)
    }
    
    func setLocalization(){
        noNetworkTitleLbl.text = "no_network_title".localized()
        noNetworkDescLbl.text = "no_network_desc".localized()
        noNetworkReloadLbl.text = "no_network_reload".localized()
        noDataLbl.text = "no_data".localized()
    }
    
    @IBAction func reloadAction(){
        myComplaintsPresenter.getMyComplaints()
    }
    
    @IBAction func backAction(_ sender: Any) {
        if isFromSubmit{
            complaintDelegate.backComplaintsPressed()
        }else{
            dismiss(animated: true, completion: nil)
        }
    }
}

extension MyComplaintsVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return complaints.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MyComplaintsCell
        cell.setCell(complaint: complaints[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

extension MyComplaintsVC: MyComplaintsView{
    
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
    
    func setData(complaints: [Complaint]){
        self.noDataView.isHidden = true
        self.noNetworkView.isHidden = true
        self.tableView.isHidden = false
        
        self.complaints = complaints
        
        tableView.reloadData()
    }
}
