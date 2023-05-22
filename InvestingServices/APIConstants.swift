//
//  APIConstants.swift
//  InvestingServices
//
//  Created by Sergey Balashov on 21.02.2023.
//

import Foundation

public enum APIConstants {
    public static let requestDelay: DispatchQueue.SchedulerTimeType.Stride = 0.25
    
    public enum FIGI: String {
        var value: RawValue { rawValue }

        case USD = "BBG0013HGFT4"
        case EUR = "BBG0013HJJ31"
    }
}
