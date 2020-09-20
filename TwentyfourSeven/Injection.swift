//
//  Injection.swift
//  TwentyfourSeven
//
//  Created by Dina Ragab on 11/29/18.
//  Copyright © 2018 Objects. All rights reserved.
//

import Foundation
class Injection {
    
    static func  provideUserRepository() -> UserRepository {
        return NetworkUserRepository()
    }
    
    static func  provideInfoRepository() -> InfoRepository {
        return NetworkInfoRepository()
    }
    
    static func  provideAddressesRepository() -> AddressesRepository {
        return NetworkAddressesRepository()
    }
    
    static func  provideDelegateRepository() -> DelegateRepository {
        return NetworkDelegateRepository()
    }
    
    static func  providePlacesRepository() -> PlacesRepository {
        return NetworkPlacesRepository()
    }
    
    static func  provideOrderRepository() -> OrderRepository {
        return NetworkOrderRepository()
    }
    
    static func  provideWalletRepository() -> WalletRepository {
        return NetworkWalletRepository()
    }
}
