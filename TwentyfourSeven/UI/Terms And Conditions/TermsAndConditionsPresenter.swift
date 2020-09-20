//
//  TermsAndConditionsPresenter.swift
//  TwentyfourSeven
//
//  Created by Salma  on 12/18/18.
//  Copyright © 2018 Objects. All rights reserved.
//

import Foundation
import UIKit

class TermsAndConditionsPresenter : Presenter{

    var view : TermsAndConditionsView?
    var infoRepository: InfoRepository!
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    var userDefault = UserDefault()

    init (repository: InfoRepository) {
        infoRepository = repository
    }

    func setView(view: TermsAndConditionsView) {
        weak var weakView = view
        self.view = weakView
    }

    func getTermsAndConditions(){
        self.view?.showloading()
        infoRepository.getPages(slug: "terms-and-conditions") { (result, error) in
            self.view?.hideLoading()
            if error == NetworkInfoRepository.ErrorType.none{
                if result?.data != nil{
                    self.view?.setData(data: (result?.data)!)
                }
            }else if error == NetworkInfoRepository.ErrorType.invalidValue{
                self.view?.showGeneralError()
            }else if error == NetworkInfoRepository.ErrorType.auth{
                self.userDefault.removeSession()
            }else if error == NetworkInfoRepository.ErrorType.serverError{
                self.view?.showGeneralError()
            }else if error == NetworkInfoRepository.ErrorType.generalError{
                self.view?.showGeneralError()
            }else{
                self.view?.showNetworkError()
            }
        }
    }

    func didLoad() {

    }

    func didAppear() {

    }

}

protocol TermsAndConditionsView : class {
    func showloading()
    func hideLoading()
    func showNetworkError()
    func showGeneralError()
    func setData(data: PagesData)
}


