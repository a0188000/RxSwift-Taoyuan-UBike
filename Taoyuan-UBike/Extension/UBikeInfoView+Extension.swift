//
//  UBikeInfoView+Extension.swift
//  Taoyuan-UBike
//
//  Created by 沈維庭 on 2019/1/25.
//  Copyright © 2019年 沈維庭. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

extension Reactive where Base: UBikeInfoView {
    var info: Binder<RecordViewModel> {
        return Binder(self.base) { view, info in
            let isConnected = GeneralHelper.sharedInstance.isConnected
            view.titleLabel.text = isConnected ? info.sna : "-"
            view.rentLabel.text = isConnected ? info.sbi : "-"
            view.returnLabel.text = isConnected ? info.bemp : "-"
            view.statusLabel.text = isConnected ? (info.act == "1" ? "正常" : "停用") : "-"
        }
    }
}
