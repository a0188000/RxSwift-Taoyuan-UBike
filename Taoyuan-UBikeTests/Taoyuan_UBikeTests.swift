//
//  Taoyuan_UBikeTests.swift
//  Taoyuan-UBikeTests
//
//  Created by 沈維庭 on 2019/2/19.
//  Copyright © 2019年 沈維庭. All rights reserved.
//

import XCTest
import RxCocoa
import RxSwift
import RxTest
import CoreLocation

@testable import Taoyuan_UBike

class Taoyuan_UBikeTests: XCTestCase {
    
    private var infoViewModel: InformationViewModelProtocol!
    private var mapViewModel: UBikeMapViewModel!
    private var locationManager: CLLocationManager!
    private var locationFetcher: LocationFetcher!
    private var disposeBag = DisposeBag()
    
    override func setUp() {
        super.setUp()
        self.infoViewModel = InformationViewModel()
        self.locationManager = CLLocationManager()
        self.locationManager.requestWhenInUseAuthorization()
        self.locationFetcher = LocationFetcher(locationManager: locationManager)
        self.mapViewModel = UBikeMapViewModel(locationFetcher: locationFetcher)
    }
    
    func testTappedLocationButton() {
        let buttonTap = PublishSubject<Void>()
        buttonTap
            .bind(to: self.mapViewModel.locationRestart)
            .disposed(by: self.disposeBag)
        self.mapViewModel.locationRestart
            .subscribe(onNext: {
                XCTAssert(true, "Location Button Pressed.")
            }).disposed(by: self.disposeBag)
        buttonTap.onNext(())
    }

    func testUpdateUserLocation() {
        let buttonTap = PublishSubject<Void>()
        buttonTap
            .bind(to: self.mapViewModel.locationRestart)
            .disposed(by: self.disposeBag)
        self.mapViewModel.locationRestart
            .bind(to: self.locationFetcher.locationStartUpdate)
            .disposed(by: self.disposeBag)
        self.locationFetcher.locationStartUpdate
            .subscribe(onNext: {
                XCTAssert(true, "Start Update.")
                self.locationManager.startUpdatingLocation()
            }).disposed(by: self.disposeBag)
        self.locationManager.rx
            .didUpdateLocations
            .subscribe(onNext: {
                guard let location = $0.first else {
                    XCTAssertNotNil($0.first)
                    return
                }
                self.locationManager.stopUpdatingLocation()
                XCTAssert(true)
            }).disposed(by: self.disposeBag)
        buttonTap.onNext(())
    }
    

    func testSelectdedAnnotationView() {
        let scheduler = TestScheduler(initialClock: 0)
        let isSelected = scheduler.createObserver(Bool.self)
        self.infoViewModel.selectedAnnotationView
            .bind(to: isSelected)
            .disposed(by: self.disposeBag)
        
        scheduler.createHotObservable([next(10, false),
                                       next(20, true)])
            .bind(to: self.infoViewModel.selectedAnnotationView)
            .disposed(by: self.disposeBag)
        scheduler.start()
        let expectedCanSendEvents = [next(0, false),
                                     next(10, false),
                                     next(20, true)]
        XCTAssertEqual(isSelected.events, expectedCanSendEvents)
    }
}
