//
//  AppCoordinator.swift
//  Taoyuan-UBike
//
//  Created by 沈維庭 on 2019/1/21.
//  Copyright © 2019年 沈維庭. All rights reserved.
//

import UIKit
import CoreLocation
import RxCocoa
import RxSwift
import Alamofire

class AppCoordinator: Coordinator {
    private var window: UIWindow
    private var location: LocationFetcher
    private var reachability: Reachability
    private var disposeBag = DisposeBag()
    
    private var locationManager: CLLocationManager = {
        let locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()
        return locationManager
    }()
    
    private var network = NetworkReachabilityManager(host: GoogleURLString)
    
    init(_ window: UIWindow) {
        self.window = window
        self.location = LocationFetcher(locationManager: self.locationManager)
        self.reachability = Reachability(network: self.network)
    }
    
    func start() {
        let uBikeViewModel = UBikeMapViewModel(locationFetcher: self.location)
        window.rootViewController = UBikeMapViewController(viewModel: uBikeViewModel)
        
        self.reachability.statusChanged
            .subscribe(onNext: { (conntected) in
                GeneralHelper.sharedInstance.isConnected = conntected
                if conntected { uBikeViewModel.fetch() }
        }).disposed(by: disposeBag)
    }

    deinit {
        print("i dead")
    }
}
