//
//  Reachability.swift
//  Taoyuan-UBike
//
//  Created by 沈維庭 on 2019/2/13.
//  Copyright © 2019年 沈維庭. All rights reserved.
//

import Foundation
import Alamofire
import RxCocoa
import RxSwift

class Reachability {
    
    var statusChanged: PublishRelay<Bool> = PublishRelay()
    
    init(network: NetworkReachabilityManager?) {
        network?.startListening()
        network?.listener = { status in
            switch status {
            case .unknown, .notReachable:
                self.statusChanged.accept(false)
            case .reachable:
                self.statusChanged.accept(true)
            }
        }
    }
}
