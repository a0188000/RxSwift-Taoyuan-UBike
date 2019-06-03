//
//  NSObject+Extension.swift
//  Taoyuan-UBike
//
//  Created by 沈維庭 on 2019/1/22.
//  Copyright © 2019年 沈維庭. All rights reserved.
//

import Foundation

protocol Declarative { }

extension NSObject: Declarative { }
extension Declarative where Self: NSObject {
    init(_ configureHandler: (Self) -> Void) {
        self.init()
        configureHandler(self)
    }
}
