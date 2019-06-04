//
//  InformationViewModel.swift
//  Taoyuan-UBike
//
//  Created by 沈維庭 on 2019/1/24.
//  Copyright © 2019年 沈維庭. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

protocol InformationViewModelProtocol {
    var uBikeInfos: BehaviorSubject<[RecordViewModel]> { get }
    var ubikeInfo: PublishRelay<RecordViewModel> { get }
    var selectedAnnotationView: BehaviorSubject<Bool> { get }
    var didSelectedUBikeInfo: PublishRelay<RecordViewModel> { get }
    var routeButtonTap: PublishSubject<Void> { get }
    var navigationButtonTap: PublishSubject<Void> { get }
    
    var searchValue: BehaviorSubject<String> { get }
    var filteredUBikeInfos: BehaviorSubject<[RecordViewModel]> { get }
}

class InformationViewModel: InformationViewModelProtocol {
    var uBikeInfos: BehaviorSubject<[RecordViewModel]> = BehaviorSubject(value: [])
    var ubikeInfo: PublishRelay<RecordViewModel> = PublishRelay<RecordViewModel>()
    var selectedAnnotationView: BehaviorSubject<Bool> = BehaviorSubject(value: false)
    var didSelectedUBikeInfo: PublishRelay<RecordViewModel> = PublishRelay()
    var routeButtonTap: PublishSubject<Void> = PublishSubject()
    var navigationButtonTap: PublishSubject<Void> = PublishSubject()
    
    // Search
    var searchValue: BehaviorSubject<String> = BehaviorSubject(value: "")
    var filteredUBikeInfos: BehaviorSubject<[RecordViewModel]> = BehaviorSubject(value: [])
    
    private let disposeBag = DisposeBag()
    
    init() {
        self.searchValue.subscribe(onNext: { (value) in
            self.uBikeInfos.map({
                $0.filter({
                    if value.isEmpty { return true }
                    return $0.sna.lowercased().contains(value.lowercased())
                })
            }).bind(to: self.filteredUBikeInfos)
                .disposed(by: self.disposeBag)
        }).disposed(by: self.disposeBag)
    }
}
