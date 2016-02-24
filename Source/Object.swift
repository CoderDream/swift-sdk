//
//  Object.swift
//  LeanCloud
//
//  Created by Tang Tianyong on 2/23/16.
//  Copyright © 2016 LeanCloud. All rights reserved.
//

import Foundation

public class Object: NSObject {
    /**
     Register all subclasses.
     */
    static func registerSubclasses() {
        let subclasses = Runtime.subclasses(Object.self)

        for subclass in subclasses {
            ObjectProfiler.synthesizeNonComputedProperties(subclass)
        }
    }
}