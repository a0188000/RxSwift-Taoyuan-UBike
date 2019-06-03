//
//  UBikeInfoView.swift
//  Taoyuan-UBike
//
//  Created by 沈維庭 on 2019/1/22.
//  Copyright © 2019年 沈維庭. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class UBikeInfoView: UIView {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var rentLabel: UILabel! {
        didSet {
            rentLabel.adjustsFontSizeToFitWidth = true
        }
    }
    @IBOutlet weak var returnLabel: UILabel! {
        didSet {
            returnLabel.adjustsFontSizeToFitWidth = true
        }
    }
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var navigationButton: UIButton! {
        didSet {
            self.navigationButton.layer.borderWidth = 1
            self.navigationButton.layer.borderColor = UIColor(r: 18, g: 106, b: 255, alpha: 1).cgColor
            self.navigationButton.layer.cornerRadius = 15
        }
    }
    @IBOutlet weak var routeButton: UIButton! {
        didSet {
            self.routeButton.layer.cornerRadius = 15
        }
    }
}



