//
//  ResponseViewModel.swift
//  UBikeAPI_Test
//
//  Created by 沈維庭 on 2019/1/17.
//  Copyright © 2019年 沈維庭. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import Realm
import RealmSwift

protocol ResultPresentable {
    var records: [RecordViewPresentable] { get }
    var count: Int { get }
}

protocol RecordViewPresentable {
    var _id: Int { get }
    var sarea: String { get }
    var sareaen: String { get }
    var sna: String { get }
    var aren: String { get }
    var sno: String { get }
    var tot: String { get }
    var snaen: String { get }
    var bemp: String { get }
    var ar: String { get }
    var act: String { get }
    var lat: Double { get }
    var lng: Double { get }
    var sbi: String { get }
    var mday: String { get }
}

class ResultViewModel: ResultPresentable {
    var records: [RecordViewPresentable] = []
    var count: Int
    
    init(result: Result) {
        self.count = result.records.count
        result.records.forEach { (recordData) in
            self.records.append(RecordViewModel(recordData: recordData))
        }
    }
}

@objcMembers
class RecordViewModel: Object, RecordViewPresentable {
    dynamic var _id: Int = 0
    dynamic var sna: String  = ""// 站名
    dynamic var aren: String = ""// 地址
    dynamic var sno: String = ""// 代號
    dynamic var tot: String = ""// 總停車格數
    dynamic var bemp: String = ""// 目前可還數
    dynamic var act: String = ""// 營運狀態
    dynamic var lat: Double = 0.0
    dynamic var lng: Double = 0.0
    dynamic var sbi: String = ""// 目前可借數
    dynamic var mday: String = ""
    dynamic var sarea: String = ""
    dynamic var sareaen: String = ""
    dynamic var snaen: String = ""
    dynamic var ar: String = ""
    
    override static func primaryKey() -> String? {
        return "_id"
    }
    
    required init(recordData: Record) {
        self._id = recordData._id
        self.sarea = recordData.sarea
        self.sareaen = recordData.sareaen
        self.sna = recordData.sna
        self.aren = recordData.aren
        self.sno = recordData.sno
        self.tot = recordData.tot
        self.snaen = recordData.snaen
        self.bemp = recordData.bemp
        self.ar = recordData.ar
        self.act = recordData.act
        self.lat = Double(recordData.lat) ?? 0
        self.lng = Double(recordData.lng) ?? 0
        self.sbi = recordData.sbi
        self.mday = recordData.mday
        
        super.init()
    }
    
    required init() {
        super.init()
    }
    
    required init(realm: RLMRealm, schema: RLMObjectSchema) {
        super.init(realm: realm, schema: schema)
    }
    
    required init(value: Any, schema: RLMSchema) {
        super.init(value: value, schema: schema)
    }
}
