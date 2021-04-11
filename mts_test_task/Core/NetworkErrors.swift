//
//  NetworkErrors.swift
//  mts_test_task
//
//  Created by  Matvey on 09.04.2021.
//

import Foundation

enum NetworkError: Error {
    case errorURL
    case noDataError
    case decodeError
}

extension NetworkError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .decodeError:
            return NSLocalizedString("Can't decode server response", comment: "")
        case .errorURL:
            return NSLocalizedString("Wrong URL", comment: "")
        case .noDataError:
            return NSLocalizedString("No data in response", comment: "")
        }
    }
}
