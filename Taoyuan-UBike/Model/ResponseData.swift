//
//  ResponseData.swift
//  UBikeAPI_Test
//
//  Created by 沈維庭 on 2019/1/17.
//  Copyright © 2019年 沈維庭. All rights reserved.
//

import UIKit

struct ResponseData: Decodable {
    var result: Result
}

struct Result: Decodable {
    var records: [Record]
}

class Record: Decodable {
    var _id: Int = 0
    var sarea: String = ""
    var sareaen: String = ""
    var sna: String = ""
    var aren: String = ""
    var sno: String = ""
    var tot: String = ""
    var snaen: String = ""
    var bemp: String = ""
    var ar: String = ""
    var act: String = ""
    var lat: String = ""
    var lng: String = ""
    var sbi: String = ""
    var mday: String = ""
}
