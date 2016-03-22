//
//  RequestBuilder.swift
//  LeanCloud
//
//  Created by Tang Tianyong on 3/22/16.
//  Copyright © 2016 LeanCloud. All rights reserved.
//

import Foundation

class Request {
    let object: LCObject
    let operationTable: OperationTable

    init(object: LCObject, operationTable: OperationTable) {
        self.object = object
        self.operationTable = operationTable
    }
}

class RequestBuilder {
    /**
     Get a list of requests of an object.

     - parameter object: The object from which you want to get.

     - returns: A list of requests.
     */
    static func buildShallowRequests(object: LCObject) -> [Request] {
        return buildRequests(object, depth: 0)
    }

    /**
     Get a list of requests of an object and its descendant objects.

     - parameter object: The object from which you want to get.

     - returns: A list of requests.
     */
    static func buildDeepRequests(object: LCObject) -> [Request] {
        return buildRequests(object, depth: -1)
    }

    /**
     Get operation table list of object.

     - returns: A list of operation tables.
     */
    static func operationTableList(object: LCObject) -> OperationTableList {
        if object.objectId != nil {
            return object.operationHub.operationTableList()
        } else {
            var operationTable: OperationTable = [:]

            /* Collect all non-null properties. */
            ObjectProfiler.iterateProperties(object) { (key, value) in
                if let value = value {
                    operationTable[key] = Operation(name: .Set, key: key, value: value)
                }
            }

            return [operationTable]
        }
    }

    /**
     Get a list of requests of an object.

     - parameter object: The object from which you want to get.

     - returns: A list of request.
     */
    static func buildRequests(object: LCObject) -> [Request] {
        return operationTableList(object).map { Request(object: object, operationTable: $0) }
    }

    /**
     Get a list of requests of an object with depth option.

     - parameter object: The object from which you want to get.
     - parameter depth:  The depth of objects to deal with.

     - returns: A list of requests.
     */
    static func buildRequests(object: LCObject, depth: Int) -> [Request] {
        var result: [Request] = []

        ObjectProfiler.iterateObject(object, depth: depth) { (object) in
            let requests = buildRequests(object)

            if requests.count > 0 {
                result.appendContentsOf(requests)
            }
        }

        return result
    }
}