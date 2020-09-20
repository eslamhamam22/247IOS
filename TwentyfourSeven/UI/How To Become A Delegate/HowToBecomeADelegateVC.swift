//
//  HowToBecomeADriverVC.swift
//  TwentyfourSeven
//
//  Created by Salma  on 1/3/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import UIKit
//import ImageSlideshow
import MBProgressHUD
import Toaster
import Kingfisher

class HowToBecomeADelegateVC: UIViewController {

    //var kingfisherSource = [KingfisherSource]()
    
    @IBOutlet weak var contentView: UIView!
//    @IBOutlet weak var slideShow: ImageSlideshow!
//    @IBOutlet weak var titleLbl: UILabel!
//    @IBOutlet weak var descLbl: UILabel!
//    @IBOutlet weak var descTv: UITextView!
    @IBOutlet weak var submitLbl: UILabel!
    @IBOutlet weak var submitView: UIView!
    @IBOutlet weak var backImg: UIImageView!

    //no network
    @IBOutlet weak var noNetworkView: UIView!
    @IBOutlet weak var noNetworkTitleLbl: UILabel!
    @IBOutlet weak var noNetworkDescLbl: UILabel!
    @IBOutlet weak var noNetworkReloadLbl: UILabel!
    @IBOutlet weak var noNetworkReloadImg: UIImageView!
    
    var howToBecomeADelegatePresenter : HowToBecomeADelegatePresenter!
    var loadingView: MBProgressHUD!
    var howToUseData = [HowToUseData]()
    var currentPage = 0
    var isFromSetting = false
    let userDefault = UserDefault()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var scrollView: UIScrollView!{
        didSet{
            scrollView.delegate = self
        }
    }
    
    @IBOutlet weak var pageControl: UIPageControl!
    
    var slides:[Slide] = [];
    
    override func viewDidLoad() {
        super.viewDidLoad()

        howToBecomeADelegatePresenter = HowToBecomeADelegatePresenter(repository: Injection.provideInfoRepository())
        howToBecomeADelegatePresenter.setView(view: self)
        howToBecomeADelegatePresenter.getHowToBecomeDelegate()
        
        if appDelegate.isRTL{
            backImg.image = UIImage(named: "back_ar_ic-1")
        }else{
            backImg.image = UIImage(named: "back_ic-1")
        }
        submitLbl.text = "submitRequest".localized()
        
        contentView.isHidden = true
        noNetworkView.isHidden = true
        
        setFonts()
        setGestures()
        setLocalization()
    }

    func setLocalization(){
        noNetworkTitleLbl.text = "no_network_title".localized()
        noNetworkDescLbl.text = "no_network_desc".localized()
        noNetworkReloadLbl.text = "no_network_reload".localized()
    }
    
    func setGestures(){
        let backTab = UITapGestureRecognizer(target: self, action: #selector(self.backPressed))
        backImg.addGestureRecognizer(backTab)
        
        let submitTab = UITapGestureRecognizer(target: self, action: #selector(self.submitPressed))
        submitView.addGestureRecognizer(submitTab)
        
        let submitLblTab = UITapGestureRecognizer(target: self, action: #selector(self.submitPressed))
        submitLbl.addGestureRecognizer(submitLblTab)
        
        let reloadTap = UITapGestureRecognizer(target: self, action: #selector(reloadAction))
        noNetworkReloadImg.addGestureRecognizer(reloadTap)
        
        let reloadLblTap = UITapGestureRecognizer(target: self, action: #selector(reloadAction))
        noNetworkReloadLbl.addGestureRecognizer(reloadLblTap)
    }
    
    func setFonts(){
//        descTv.font = Utils.customDefaultFont(descTv.font!.pointSize)
//        titleLbl.font = Utils.customBoldFont(titleLbl.font.pointSize)
        submitLbl.font = Utils.customDefaultFont(submitLbl.font.pointSize)
//        descLbl.font = Utils.customDefaultFont(descLbl.font.pointSize)

        noNetworkTitleLbl.font = Utils.customBoldFont(noNetworkTitleLbl.font.pointSize)
        noNetworkDescLbl.font = Utils.customDefaultFont(noNetworkDescLbl.font.pointSize)
        noNetworkReloadLbl.font = Utils.customDefaultFont(noNetworkReloadLbl.font.pointSize)
    }

//    func setSlideShow(slideShow : ImageSlideshow){
//        
//        let pageIndicator = UIPageControl()
//        pageIndicator.currentPageIndicatorTintColor = Colors.hexStringToUIColor(hex: "#E84450")
//        pageIndicator.pageIndicatorTintColor = Colors.hexStringToUIColor(hex: "#E84450").withAlphaComponent(0.5)
//        slideShow.pageIndicatorPosition = PageIndicatorPosition(vertical: .under)
//        slideShow.pageIndicator = pageIndicator
//        slideShow.backgroundColor = UIColor.white
////        slideShow.pageControlPosition = PageControlPosition.underScrollView
//        slideShow.contentScaleMode = UIView.ContentMode.scaleAspectFit
//        //slideShow.clipsToBounds = true
//        kingfisherSource.removeAll()
//        if howToUseData.count != 0{
//            for data in howToUseData{
//                if data.image != nil{
//                    if data.image?.big != nil{
//                        var url = data.image?.big
//                        if !(url?.containsWhitespace)!{
//                            kingfisherSource.append(KingfisherSource(urlString: url!, placeholder: UIImage(named: "howtouse_ic"))!)
//                        }else{
//                            url = url!.trimmingCharacters(in: .whitespaces)
//                            kingfisherSource.append(KingfisherSource(urlString: url!, placeholder: UIImage(named: "howtouse_ic"))!)
//                        }
//                    }
//                }
//            }
//        }
//        
//        slideShow.currentPageChanged = { page in
//            self.currentPage = page
////            if self.howToUseData[page].title != nil{
////                self.titleLbl.text = self.howToUseData[page].title
////            }else{
////                self.titleLbl.text = ""
////            }
////            if self.howToUseData[page].desc != nil{
////                self.descTv.text = self.howToUseData[page].desc
////                self.descLbl.text = self.howToUseData[page].desc
////            }else{
////                self.descTv.text = ""
////                self.descLbl.text = ""
////            }
//        }
//        slideShow.setImageInputs(kingfisherSource)
//    }
    
    @objc func submitPressed(){
        performSegue(withIdentifier: "toRequest", sender: self)
    }
    
    @objc func backPressed(){
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func reloadAction(){
        howToBecomeADelegatePresenter.getHowToBecomeDelegate()
    }
}
extension HowToBecomeADelegateVC: HowToBecomeADelegateView{
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
        noNetworkView.isHidden = true
        Toast.init(text: "general_error".localized()).show()
    }
    
    func setData(data: [HowToUseData]) {
        contentView.isHidden = false
        noNetworkView.isHidden = true
        self.howToUseData = data
//        setSlideShow(slideShow: slideShow)
        
//        if howToUseData.count > 0 {
//            if self.howToUseData[0].title != nil{
//                self.titleLbl.text = self.howToUseData[0].title
//            }else{
//                self.titleLbl.text = ""
//            }
//            if self.howToUseData[0].desc != nil{
//                self.descTv.text = self.howToUseData[0].desc
//                self.descLbl.text = self.howToUseData[0].desc
//
//            }else{
//                self.descTv.text = ""
//                self.descLbl.text = ""
//            }
//        }else{
//            self.titleLbl.text = ""
//            self.descTv.text = ""
//            self.descLbl.text = ""
//
//        }
        
        slides = createSlides()
        setupSlideScrollView(slides: slides)
        
        pageControl.numberOfPages = slides.count
        pageControl.currentPage = 0
        view.bringSubviewToFront(pageControl)
        if appDelegate.isRTL{
            scrollView.transform = CGAffineTransform(scaleX: -1, y: 1)
        }
    }
}
extension HowToBecomeADelegateVC: UIScrollViewDelegate{
    
    func createSlides() -> [Slide] {
        
        var slides = [Slide]()
        if howToUseData.count != 0{
            for data in howToUseData{
                let slide1:Slide = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide

                if data.image != nil{
                    if data.image?.big != nil{
                        let url = data.image?.big
                        if !(url?.containsWhitespace)!{
                            let url = URL(string: (data.image?.big)!)
                            print("url \(String(describing: url))")
                            slide1.imageView.kf.setImage(with: url, placeholder: UIImage(named: "howtouse_ic"))
                        }else{
//                            url = url!.trimmingCharacters(in: .whitespaces)
//                            slide1.imageView.kf.setImage(with: url as! Resource, placeholder: UIImage(named: "howtouse_ic"))
                            slide1.imageView.image = UIImage(named: "howtouse_ic")
                        }
                    }
                }
                
                if data.title != nil{
                     slide1.labelTitle.text = data.title!
                    slide1.labelTitle.font = Utils.customBoldFont(slide1.labelTitle.font.pointSize)
                }else{
                     slide1.labelTitle.text = ""
                }
                
                if data.desc != nil{
                    slide1.labelDesc.text = data.desc!
                    slide1.labelDesc.font = Utils.customDefaultFont(slide1.labelDesc.font.pointSize)
                }else{
                    slide1.labelDesc.text = ""
                }
                
                if appDelegate.isRTL{
                    slide1.imageView.transform = CGAffineTransform(scaleX: -1, y: 1)
                    slide1.labelDesc.transform = CGAffineTransform(scaleX: -1, y: 1)
                    slide1.labelTitle.transform = CGAffineTransform(scaleX: -1, y: 1)
                }
              slides.append(slide1)
                
            }
        }
            
        return slides
    }
    
    func setupSlideScrollView(slides : [Slide]) {
        scrollView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height - 150)
        scrollView.contentSize = CGSize(width: view.frame.width * CGFloat(slides.count), height: view.frame.height - 150)
        scrollView.isPagingEnabled = true
        
        for i in 0 ..< slides.count {
            slides[i].frame = CGRect(x: view.frame.width * CGFloat(i), y: 0, width: view.frame.width, height: view.frame.height - 150)
            scrollView.addSubview(slides[i])
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x/view.frame.width)
        pageControl.currentPage = Int(pageIndex)
    }
    
    func fade(fromRed: CGFloat,
              fromGreen: CGFloat,
              fromBlue: CGFloat,
              fromAlpha: CGFloat,
              toRed: CGFloat,
              toGreen: CGFloat,
              toBlue: CGFloat,
              toAlpha: CGFloat,
              withPercentage percentage: CGFloat) -> UIColor {
        
        let red: CGFloat = (toRed - fromRed) * percentage + fromRed
        let green: CGFloat = (toGreen - fromGreen) * percentage + fromGreen
        let blue: CGFloat = (toBlue - fromBlue) * percentage + fromBlue
        let alpha: CGFloat = (toAlpha - fromAlpha) * percentage + fromAlpha
        
        // return the fade colour
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
}
