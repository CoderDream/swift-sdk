//
//  LCInt.swift
//  LeanCloud
//
//  Created by Tang Tianyong on 2/27/16.
//  Copyright © 2016 LeanCloud. All rights reserved.
//

import Foundation

/**
 LeanCloud integer type.

 It is a wrapper of Int type, used to store an integer value.
 */
public class LCInt: LCType {

    /**
     Increase integer value by 1.
     */
    public func increase() {
        updateParent { (object, key) -> Void in
            object.addOperation(.Increment, key, nil)
        }
    }
}