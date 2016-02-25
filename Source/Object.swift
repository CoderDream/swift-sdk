//
//  Object.swift
//  LeanCloud
//
//  Created by Tang Tianyong on 2/23/16.
//  Copyright © 2016 LeanCloud. All rights reserved.
//

import Foundation

public class Object: NSObject {
    /// Stable data of object.
    /// Used to store values that have commited.
    lazy var stableData = NSMutableDictionary()

    /// Latest data of object.
    /// Used to store values that haven't committed yet.
    lazy var latestData = NSMutableDictionary()

    /**
     Get object for key.

     - parameter key: Specified key.

     - returns: Object for key.
     */
    func objectForKey(key:String) -> AnyObject? {
        return latestData[key]
    }

    /**
     Set object for key.

     - parameter object: New object.
     - parameter key:    Specified key.
     */
    func setObject(object: AnyObject?, forKey key:String) {
        latestData[key] = object
    }

    /**
     Save object.
     */
    public func save() {
        /* Stub method */
    }
}