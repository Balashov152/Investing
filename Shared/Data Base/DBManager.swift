//
//  DBManager.swift
//  SellFashion
//
//  Created by Sergey Balashov on 05.06.2020.
//  Copyright © 2020 SELLFASHION. All rights reserved.
//

import Combine
import Foundation

struct DBManager {
    static let version = 1

    let env: Environment
    let realmManager: RealmManager
    var cancellables = Set<AnyCancellable>()

    init(env: Environment, realmManager: RealmManager) {
        self.env = env
        self.realmManager = realmManager
    }

    mutating func updateIfNeeded(didUpdate: @escaping () -> Void) {
        let isNeedUpdate = realmManager.isEmptyDB() || Storage.currentDBVersion < DBManager.version

        guard isNeedUpdate else {
            didUpdate()
            return
        }

        Publishers.CombineLatest4(env.api().instrumentsService.getBonds(),
                                  env.api().instrumentsService.getStocks(),
                                  env.api().instrumentsService.getCurrency(),
                                  env.api().instrumentsService.getEtfs()).map { $0 + $1 + $2 + $3 }
            .print("getInstruments")
            .replaceError(with: [])
            .receive(on: realmManager.syncQueue)
            .sink { [unowned realmManager] instuments in
                realmManager.write(objects: instuments)
                Storage.currentDBVersion = DBManager.version
                didUpdate()
            }.store(in: &cancellables)
    }

//    private func checkUpdateCoreData(lastUpdateTimeshamp: Int, didUpdate: @escaping () -> Void) {
//        print("check update core data values to version: \(DBManager.version) from last save \(Storage.currentDBVersion)")
//        print("check update core data values to date: \(lastUpdateTimeshamp) from last save \(Storage.currentDBUpdateDate)")
//
//        let isNeedUpdate = Storage.currentDBUpdateDate < lastUpdateTimeshamp || Storage.currentDBVersion < DBManager.version
//        print("isNeedUpdate Data base", isNeedUpdate)
//        if isNeedUpdate {
//            Observable<Void>.just(()).flatMap { _ -> Single<Void> in
//                RealmManager.shared.deleteLists()
//                return .just(())
//            }.flatMap { _ -> Single<Void> in
//                self.configService.updateRealmConfig().mapToVoid()
//            }.flatMap { _ -> Single<Void> in
//                self.sizeService.updateRealmSizes().mapToVoid()
//            }.flatMap { _ -> Single<Void> in
//                self.categoryService.updateRealmCategory().mapToVoid()
//            }.flatMap { _ -> Single<Void> in
//                self.colorService.updateRealmColors().mapToVoid()
//            }.flatMap { _ -> Single<Void> in
//                self.brandService.updateRealmBrands().mapToVoid()
//            }.asSingle().subscribe(onSuccess: { _ in
//                Storage.currentDBVersion = DBManager.version
//                Storage.currentDBUpdateDate = lastUpdateTimeshamp
//
//                print("did update core data values to version: \(DBManager.version) from \(Storage.currentDBVersion)")
//                print("did update core data values to date: \(lastUpdateTimeshamp) from \(Storage.currentDBUpdateDate)")
//
//                RealmManager.shared.debugPrintCount()
//
//                didUpdate()
//            }) { error in
//                assertionFailure(error.localizedDescription)
//            }.disposed(by: disposeBag)
//        } else {
//            didUpdate()
//        }
//    }
}
