//
//  RLMManager.swift
//  Taoyuan-UBike
//
//  Created by 沈維庭 on 2019/2/13.
//  Copyright © 2019年 沈維庭. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

typealias RLMFailHandle = ((Error) -> Void)?

protocol Manageable {
    var realm: Realm { get }
}

protocol RLMManagerProtocol {
    func execute(_ block: () -> Void, failHandler: RLMFailHandle)
    func add(objc: Object, failHandler: RLMFailHandle)
    func fetch<T: Object>(type: T.Type) -> Results<T>
    func fetch<T: Object>(type: T.Type) -> [T]
    func add<S: Sequence>(objcs: S, failHandler: RLMFailHandle) where S.Iterator.Element: Object
}

class RLMManager: Manageable, RLMManagerProtocol {
    static var sharedInstance = RLMManager()
    
    var realm: Realm
    
    private init() {
        self.realm = try! Realm()
        print("Realm資料庫路徑： \(self.realm.configuration.fileURL?.absoluteString ?? "無路徑")")
    }
    
    func execute(_ block: () -> Void, failHandler: ((Error) -> Void)?) {
        do {
            try self.realm.write {
                block()
            }
        } catch {
            failHandler?(error)
        }
    }
    
    func add(objc: Object, failHandler: RLMFailHandle = nil) {
        self.execute({
            self.realm.add(objc, update: true)
        }, failHandler: failHandler)
    }
    
    func add<S: Sequence>(objcs: S, failHandler: RLMFailHandle = nil) where S.Iterator.Element: Object {
        self.execute({
            self.realm.add(objcs, update: true)
        }, failHandler: failHandler)
    }
    
    func fetch<T: Object>(type: T.Type) -> Results<T> {
        return self.realm.objects(type)
    }
    
    func fetch<T: Object>(type: T.Type) -> [T] {
        return Array(self.realm.objects(type))
    }
}

