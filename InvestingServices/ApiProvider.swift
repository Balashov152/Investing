//
//  EndPoints.swift
//  BubbleComics
//
//  Created by Azov Vladimir on 25/02/2019.
//  Copyright © 2019 Bubble. All rights reserved.
//

import Combine
import Foundation
import Moya
import UIKit
import InvestingStorage

class ApiProvider<Target>: MoyaProvider<Target> where Target: TargetType {
    init() {
        let plugins: [PluginType] = [
            NewBearerTokenPlugin(),
            NetworkLoggerPlugin(configuration: .init(formatter: NetworkLoggerPlugin.Configuration.Formatter(),
                                                     output: { _, _ in },
                                                     logOptions: [.requestMethod, .errorResponseBody]))
        ]

        super.init(endpointClosure: MoyaProvider.defaultEndpointMapping,
                   requestClosure: MoyaProvider<Target>.defaultRequestMapping,
                   stubClosure: MoyaProvider.neverStub,
                   callbackQueue: nil,
                   session: MoyaProvider<Target>.defaultAlamofireSession(),
                   plugins: plugins,
                   trackInflights: false)
    }

    func request(_ target: Target) -> AnyPublisher<Response, MoyaError> {
        requestPublisher(target).filterSuccessfulStatusAndRedirectCodes()
    }
}

extension TargetType {
    var headers: [String: String]? {
        ["Content-Type": "application/json"]
    }

    var sampleData: Data { Data() }
}

extension Response {
    var json: [String: Any] {
        do {
            let json = try mapJSON() as? [String: Any]
            return json ?? [:]
        } catch {
//            assertionFailure(error.localizedDescription)
            debugPrint(error.localizedDescription)
            return [:]
        }
    }

    var arrayJson: [[String: Any]] {
        do {
            let json = try mapJSON() as? [[String: Any]]
            return json ?? []
        } catch {
//            assertionFailure(error.localizedDescription)
            debugPrint(error.localizedDescription)
            return []
        }
    }
}

struct BearerTokenPlugin: PluginType {
    public func prepare(_ request: URLRequest, target _: TargetType) -> URLRequest {
        var request = request
        let authValue = AuthorizationType.bearer.value + " " + Storage.token
        request.addValue(authValue, forHTTPHeaderField: "Authorization")
        return request
    }
}

struct NewBearerTokenPlugin: PluginType {
    public func prepare(_ request: URLRequest, target _: TargetType) -> URLRequest {
        var request = request
        let authValue = AuthorizationType.bearer.value + " " + Storage.newToken
        request.addValue(authValue, forHTTPHeaderField: "Authorization")
        return request
    }
}

struct SandboxPlugin: PluginType {
    let isSandbox: Bool

    internal init(isSandbox: Bool) {
        self.isSandbox = isSandbox
    }

    public func prepare(_ request: URLRequest, target _: TargetType) -> URLRequest {
        var request = request
        let authValue = AuthorizationType.bearer.value + " " + Storage.token
        request.addValue(authValue, forHTTPHeaderField: "Authorization")
        return request
    }
}
