//
//  RealmManager.swift
//  SellFashion
//
//  Created by Sergey Balashov on 04.06.2020.
//  Copyright © 2020 SELLFASHION. All rights reserved.
//

import Foundation
import InvestModels
import RealmSwift

class RealmManager {
    let specificKey = DispatchSpecificKey<String>()
    let specificValue = "RealmManager.queue"

    static let shared = RealmManager()
    private init() {}

    lazy var syncQueue: DispatchQueue = {
        let queue = DispatchQueue(label: "RealmManager.queue", qos: .userInitiated)
        queue.setSpecific(key: specificKey, value: specificValue)
        return queue
    }()

    let objectTypes: [Object.Type] = [CurrencyPairR.self, InstrumentR.self, PinnedInstrumentR.self]
    lazy var realm: Realm = {
        do {
            let configuration = Realm.Configuration(schemaVersion: UInt64(DBManager.version),
                                                    migrationBlock: { migration, oldSchemaVersion in
                                                        print("migration", migration, "oldSchemaVersion", oldSchemaVersion)
                                                    }, objectTypes: objectTypes)

            let realm = try Realm(configuration: configuration, queue: syncQueue)
            print("Realm url: ", Realm.Configuration.defaultConfiguration.fileURL?.absoluteString ?? "")
            return realm
        } catch {
            fatalError(error.localizedDescription)
        }
    }()

    func isEmptyDB() -> Bool {
        return objectTypes.allSatisfy(isEmpty)
    }

    func syncQueueBlock(block: () -> Void) {
        if DispatchQueue.getSpecific(key: specificKey) == specificValue {
            block()
        } else {
            syncQueue.sync(execute: block)
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

    func write<T: Object>(objects: [T]) {
        writeBlock {
            self.realm.add(objects, update: .all)
        }
    }

    func isEmpty<T>(_ type: T.Type) -> Bool where T: Object {
        objects(type).isEmpty
    }

    func objects<T>(_ type: T.Type,
                    predicate: NSPredicate? = nil,
                    sorted: [NSSortDescriptor] = []) -> [T] where T: Object
    {
//        print(#function)
//        dispatchPrecondition(condition: DispatchPredicate.notOnQueue(syncQueue))

        var objects: [T] = []
        syncQueueBlock {
            objects = Array(self.results(type, predicate: predicate, sorted: sorted))
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

    func deleteAllObjects(type: Object.Type) {
        writeBlock {
            self.realm.delete(self.realm.objects(type))
        }
    }

    func debugPrintCount() {
        syncQueueBlock {
            for objectType in self.objectTypes {
                print("\(objectType)", self.realm.objects(objectType).count)
            }
        }
    }
}

extension Thread {
    class func printCurrent() {
        print("\r⚡️: \(Thread.current)\r" + "🏭: \(OperationQueue.current?.underlyingQueue?.label ?? "None")\r")
    }
}
