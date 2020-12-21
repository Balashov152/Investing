//
//  MoyaTask+Ex.swift
//  Investing
//
//  Created by Sergey Balashov on 21.12.2020.
//

import Foundation
import Moya

extension Task {
    static func requestCustomParametersEncodable<Model>(_ encodable: Model, encoder: JSONEncoder = JSONEncoder()) -> Task where Model: Encodable {
        do {
            let data = try encoder.encode(encodable)
            let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
            return .requestParameters(parameters: json ?? [:], encoding: URLEncoding.queryString)
            
        } catch {
            assertionFailure(error.localizedDescription)
            return .requestPlain
        }
    }
}
