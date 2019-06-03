//
//  LocationFetcher.swift
//  Taoyuan-UBike
//
//  Created by 沈維庭 on 2019/1/21.
//  Copyright © 2019年 沈維庭. All rights reserved.
//

import Foundation
import CoreLocation
import RxSwift
import RxCocoa

class LocationFetcher {
    let userLocation: Observable<CLLocationCoordinate2D>
    let locationStartUpdate: PublishSubject<Void> = PublishSubject()
    
    private let disposeBag:DisposeBag = DisposeBag()
    
    init(locationManager: CLLocationManager) {
       locationManager.rx
        .didChangeAuthorizationStatus
        .filter({ $0 == .authorizedWhenInUse })
        .subscribe(onNext: { (_) in
            locationManager.startUpdatingLocation()
        })
        .disposed(by: self.disposeBag)
        
        self.userLocation = locationManager.rx
            .didUpdateLocations
            .map({
                guard let location = $0.first else {
                    return CLLocationCoordinate2D()
                }
                locationManager.stopUpdatingLocation()
                return location.coordinate
            })
        
        self.locationStartUpdate
            .subscribe(onNext: {
                locationManager.startUpdatingLocation()
            })
            .disposed(by: self.disposeBag)
    }
}
