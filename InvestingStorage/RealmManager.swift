//
//  RealmManager.swift
//  SellFashion
//
//  Created by Sergey Balashov on 04.06.2020.
//  Copyright © 2020 SELLFASHION. All rights reserved.
//

import Foundation
import InvestModels
import Realm
import RealmSwift
import InvestingFoundation

class RealmManager {
    static let version = 23
    
    let specificKey = DispatchSpecificKey<String>()
    let specificValue = "RealmManager.queue"

    static let shared = RealmManager()
    private init() {}

    lazy var syncQueue: DispatchQueue = {
        let queue = DispatchQueue(label: "RealmManager.queue", qos: .userInitiated)
        queue.setSpecific(key: specificKey, value: specificValue)
        return queue
    }()

    lazy var realm: Realm = {
        do {
            let configuration = Realm.Configuration(
                schemaVersion: UInt64(RealmManager.version),
                migrationBlock: { migration, oldSchemaVersion in
                    print("migration", migration, "oldSchemaVersion", oldSchemaVersion)
                }, objectTypes: [
                    RealmBrokerAccount.self,
                    RealmOperation.self,
                    RealmPrice.self,
                    RealmShare.self,
                    RealmPortfolio.self,
                    RealmPosition.self,
                    RealmCandle.self,
                ]
            )

            let realm = try Realm(configuration: configuration, queue: syncQueue)
            print("Realm url: ", Realm.Configuration.defaultConfiguration.fileURL?.absoluteString ?? "")
            return realm
        } catch {
            fatalError(error.localizedDescription)
        }
    }()

    func syncQueueBlock(block: () -> Void) {
        if DispatchQueue.getSpecific(key: specificKey) == specificValue {
            block()
        } else {
            syncQueue.sync(flags: .barrier, execute: block)
        }
    }

    func writeBlock(block: () -> Void) {
        syncQueueBlock {
            do {
                try realm.write {
                    autoreleasepool {
                        block()
                    }
                }
            } catch {
                assertionFailure(error.localizedDescription)
            }
        }
    }

    func write<T: Object>(objects: [T], policy: Realm.UpdatePolicy = .modified) {
        writeBlock {
            self.realm.add(objects, update: policy)
        }
    }

    func objects<T>(
        _ type: T.Type,
        predicate: NSPredicate? = nil,
        sorted: [NSSortDescriptor] = []
    ) -> [T] where T: Object {
//        print(#function)
//        dispatchPrecondition(condition: DispatchPredicate.notOnQueue(syncQueue))

        var objects: [T] = []
        syncQueueBlock {
            objects = Array(results(type, predicate: predicate, sorted: sorted))
        }

        return objects
    }

    func objects<T, Result>(
        _ type: T.Type,
        predicate: NSPredicate? = nil,
        sorted: [NSSortDescriptor] = [],
        syncMap: (T) -> (Result)
    ) -> [Result] where T: Object {
        var objects: [Result] = []
        syncQueueBlock {
            let realmObjects = results(type, predicate: predicate, sorted: sorted)
            objects = Array(realmObjects).map(syncMap)
        }

        return objects
    }

    private func results<T>(_ type: T.Type,
                            predicate: NSPredicate? = nil,
                            sorted: [NSSortDescriptor] = []) -> Results<T> where T: Object
    {
        var result = realm.objects(type)

        if let predicate = predicate {
            result = result.filter(predicate)
        }

        if !sorted.isEmpty {
            for sort in sorted where !sort.key.orEmpty.isEmpty {
                if let key = sort.key {
                    result = result.sorted(byKeyPath: key, ascending: sort.ascending)
                }
            }
        }

        return result
    }

    func object<T>(_ type: T.Type, for id: String) -> T? where T: Object {
        var object: T?
        syncQueueBlock {
            object = realm.object(ofType: type, forPrimaryKey: id)
        }
        return object
    }

    func deleteAllObjects() {
        writeBlock {
            self.realm.deleteAll() // .delete(self.realm.objects(type))
        }
    }

//    func debugPrintCount() {
//        syncQueueBlock {
//            for objectType in self.objectTypes {
//                print("\(objectType)", self.realm.objects(objectType).count)
//            }
//        }
//    }
}

extension Thread {
    class func printCurrent() {
        print("\r⚡️: \(Thread.current)\r" + "🏭: \(OperationQueue.current?.underlyingQueue?.label ?? "None")\r")
    }
}
