//
//  LCRelation.swift
//  LeanCloud
//
//  Created by Tang Tianyong on 3/24/16.
//  Copyright © 2016 LeanCloud. All rights reserved.
//

import Foundation

/**
 LeanCloud relation type.

 This type can be used to make one-to-many relation between objects.
 */
public final class LCRelation: LCType {
    typealias Element = LCObject

    var value: [Element] = []

    override var JSONValue: AnyObject? {
        return value.map { (element) in element.JSONValue! }
    }

    public override func copyWithZone(zone: NSZone) -> AnyObject {
        return self
    }

    override func forEachChild(body: (child: LCType) -> Void) {
        value.forEach { body(child: $0) }
    }

    /**
     Append an element.

     - parameter element: The element to be appended.
     */
    func append(element: Element) {
        value = value + [element]
    }

    /**
     Remove an element from list.

     - parameter element: The element to be removed.
     */
    func remove(element: Element) {
        value = value - [element]
    }
}