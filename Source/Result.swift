//
//  Result.swift
//  LeanCloud
//
//  Created by Tang Tianyong on 4/26/16.
//  Copyright © 2016 LeanCloud. All rights reserved.
//

import Foundation

public enum QueryResult<T: LCObject> {
    case Success(objects: [T])
    case Failure(error: Error)

    public var isSuccess: Bool {
        switch self {
        case .Success: return true
        case .Failure: return false
        }
    }

    public var objects: [T]? {
        switch self {
        case let .Success(objects):
            return objects
        case .Failure:
            return nil
        }
    }
}

public enum CountResult {
    case Success(count: Int)
    case Failure(error: Error)

    public var isSuccess: Bool {
        switch self {
        case .Success: return true
        case .Failure: return false
        }
    }

    init(response: Response) {
        if let error = response.error {
            self = .Failure(error: error)
        } else {
            self = .Success(count: response.count)
        }
    }
}