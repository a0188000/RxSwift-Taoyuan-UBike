//
//  UBikeMapViewModel.swift
//  Taoyuan-UBike
//
//  Created by 沈維庭 on 2019/1/21.
//  Copyright © 2019年 沈維庭. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit
import RxSwift
import RxCocoa

protocol UBikeMapViewModelProtocol {
    var userLocation: Observable<CLLocationCoordinate2D> { get }
    var uBikeInfos: Driver<[RecordViewModel]> { get }
    var uBikeAnns: Observable<[UBikeAnnotationViewModel]> { get }
    var uBikeInfo: Observable<RecordViewModel> { get }
    var uBikeDidSelect: PublishSubject<UBikeAnnotationViewModel> { get }
    
    var locationRestart: PublishSubject<Void> { get }
    var routeButtonTap: PublishSubject<Void> { get }
    var routes: Observable<MKRoute> { get }
    
    func fetch()
}


class UBikeMapViewModel: UBikeMapViewModelProtocol {
    var userLocation: Observable<CLLocationCoordinate2D>
    var uBikeInfos: Driver<[RecordViewModel]>
    var uBikeAnns: Observable<[UBikeAnnotationViewModel]>
    var uBikeInfo: Observable<RecordViewModel>
    var uBikeDidSelect: PublishSubject<UBikeAnnotationViewModel> =  PublishSubject<UBikeAnnotationViewModel>()
    var locationRestart: PublishSubject<Void> = PublishSubject()
    
    var routeButtonTap: PublishSubject<Void> = PublishSubject()
    var routes: Observable<MKRoute>
    
    private var _uBikeInfos: BehaviorRelay<[RecordViewModel]> = BehaviorRelay(value: [])
    private var disposeBag: DisposeBag = DisposeBag()
    
    private var rlmManager: RLMManagerProtocol = RLMManager.sharedInstance
    
    init(locationFetcher: LocationFetcher) {
        self.userLocation = locationFetcher.userLocation.share(replay: 1)
        self.uBikeInfos = self._uBikeInfos.asDriver()
        self.uBikeAnns = self._uBikeInfos.map({
            $0.compactMap(UBikeAnnotationViewModel.init)
        })
        
        self.uBikeInfo = self.uBikeDidSelect
            .withLatestFrom(self.uBikeInfos) { (annViewModel, infos) -> RecordViewModel in
                let result = infos.filter({annViewModel.title == $0.sna})
                return result.first!
        }.map({$0})

        self.routes = self.routeButtonTap
            .withLatestFrom(self.uBikeInfo)
            .map({ CLLocationCoordinate2DMake($0.lat, $0.lng)})
            .withLatestFrom(self.userLocation) { (point, userLocation) -> Observable<MKRoute> in
                let directions = MKDirections(request: MKDirections.Request{
                    $0.transportType = .walking
                    $0.source = MKMapItem(placemark: MKPlacemark(coordinate: userLocation, addressDictionary: nil))
                    $0.destination = MKMapItem(placemark: MKPlacemark(coordinate: point, addressDictionary: nil))
                })
                return Observable.create({ (observable) -> Disposable in
                    directions.calculate(completionHandler: { (response, error) -> Void in
                        if let route = response?.routes.first {
                            observable.onNext(route)
                        }
                    })
                    return Disposables.create()
                })
            }.flatMap({$0})

        self.locationRestart
            .bind(to: locationFetcher.locationStartUpdate)
            .disposed(by: self.disposeBag)
        self.fetch()
    }
    
    func fetch() {
        API.shared.getUBikeModelLists().share(replay: 1)
            .map({ [weak self] (modelLists) -> [RecordViewModel] in
                self?.rlmManager.add(objcs: modelLists, failHandler: self?.handlerRealmError)
                return modelLists
            })
            .subscribe(onNext: self._uBikeInfos.accept,
                       onError: {
                        self.downloadFailed()
                        print("download fail: \($0.localizedDescription)")
            }).disposed(by: self.disposeBag)
    }
    
    private func downloadFailed() {
        let rlmResult: [RecordViewModel] = self.rlmManager.fetch(type: RecordViewModel.self)
        if rlmResult.isEmpty {
            GeneralHelper.sharedInstance.showAlert(
                title: "Woops", messgae: "請開啟網路或重新開啟APP.",
                confirmActionTitle: "確定",
                cancelActionTitle: "離開", cancelActionHandler: { (_) in
                    exit(0)
            })
        } else {
            self._uBikeInfos.accept(rlmResult)
        }
    }
    
    private func handlerRealmError(_ error: Error) {
        print("Realm Error: \(error.localizedDescription)")
    }
}

