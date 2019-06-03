//
//  UIView+Extension.swift
//  Taoyuan-UBike
//
//  Created by 沈維庭 on 2019/1/24.
//  Copyright © 2019年 沈維庭. All rights reserved.
//

import UIKit

extension UIView {
    func setRoundCorners(conrners: UIRectCorner, withRadii radii: CGFloat) {
        let bezierPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: conrners, cornerRadii: CGSize(width: radii, height: radii))
        let shapeLayer = CAShapeLayer()
        shapeLayer.frame = self.bounds
        shapeLayer.path = bezierPath.cgPath
        self.layer.mask = shapeLayer
    }
}
