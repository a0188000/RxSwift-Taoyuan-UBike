//
//  API.swift
//  Taoyuan-UBike
//
//  Created by 沈維庭 on 2019/1/21.
//  Copyright © 2019年 沈維庭. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxAlamofire

class API {
    
    public static let shared = API()
    
    init() { }
    
    func getUBikeModelLists() -> Observable<[RecordViewModel]> {
        do {
            return try self.getResponseData()
                .map({ (response: ResponseData) -> [RecordViewModel] in
                    var models: [RecordViewModel] = []
                    models = response.result.records.map(RecordViewModel.init)
                    return models
                }).asObservable()
        } catch let error {
            return .error(error)
        }
    }
    
    private func getResponseData<T: Decodable>() throws -> Single<T> {
        return request(.get, URL(string: OpenDataURLString)!)
            .data()
            .map({ try JSONDecoder().decode(T.self, from: $0) })
            .asSingle()
    }
}
