//
//  UIViewController+Extension.swift
//  Taoyuan-UBike
//
//  Created by 沈維庭 on 2019/1/24.
//  Copyright © 2019年 沈維庭. All rights reserved.
//

import UIKit

extension UIViewController {
    var bottomHeight: CGFloat {
        if #available(iOS 11, *) {
            return UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
        } else {
            return 0
        }
    }
}
