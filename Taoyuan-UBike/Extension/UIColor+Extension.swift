//
//  UIColor+Extension.swift
//  Taoyuan-UBike
//
//  Created by 沈維庭 on 2019/1/23.
//  Copyright © 2019年 沈維庭. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init(r: CGFloat, g:CGFloat, b: CGFloat, alpha: CGFloat) {
        self.init(red: r / 255, green: g / 255, blue: b / 255, alpha: alpha)
    }
}
