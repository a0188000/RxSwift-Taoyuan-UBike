//
//  UBikeAnnotationViewModel.swift
//  Taoyuan-UBike
//
//  Created by 沈維庭 on 2019/1/21.
//  Copyright © 2019年 沈維庭. All rights reserved.
//

import UIKit
import MapKit

class UBikeAnnotationViewModel: NSObject, MKAnnotation {
    private let name: String
    private let location: CLLocationCoordinate2D
    
    var title: String? {
        return self.name
    }
    
    var coordinate: CLLocationCoordinate2D {
        return location
    }
    
    init(_ uBikeMode: RecordViewModel) {
        self.name = uBikeMode.sna
        self.location = CLLocationCoordinate2DMake(uBikeMode.lat, uBikeMode.lng)
    }
}
