//
//  GeneralHelper.swift
//  Taoyuan-UBike
//
//  Created by 沈維庭 on 2019/2/13.
//  Copyright © 2019年 沈維庭. All rights reserved.
//

import UIKit
import Alamofire

final class GeneralHelper {
    static var sharedInstance = GeneralHelper()
    
    var isConnected: Bool
    
    private init() {
        self.isConnected = NetworkReachabilityManager(host: GoogleURLString)!.isReachable
    }
    
    public func showAlert(title: String?, messgae: String?,
                          confirmActionTitle: String?,
                          confirmActionHandler: ((UIAlertAction) -> Void)? = nil,
                          cancelActionTitle: String? = nil,
                          cancelActionHandler: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: messgae, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: confirmActionTitle, style: .default, handler: confirmActionHandler)
        if let _ = cancelActionTitle {
            let cancelAction = UIAlertAction(title: cancelActionTitle, style: .cancel, handler: cancelActionHandler)
            alert.addAction(cancelAction)
        }
        alert.addAction(confirmAction)
        
        guard let topViewController = UIApplication.shared.keyWindow?.rootViewController else { return }
        topViewController.present(alert, animated: true, completion: nil)
    }
}
