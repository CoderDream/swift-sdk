//
//  TypeTestCase.swift
//  LeanCloud
//
//  Created by Tang Tianyong on 9/2/16.
//  Copyright © 2016 LeanCloud. All rights reserved.
//

import XCTest
import LeanCloud

class TypeTestCase: BaseTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func convert(object: LCTypeConvertible) -> LCType {
        return object.lcType
    }

    func testNullConvertible() {
        XCTAssertEqual(convert(NSNull()) as? LCNull, LCNull())
    }

    func testIntegerConvertible() {
        XCTAssertEqual(convert(Int(42))    as? LCNumber, 42)
        XCTAssertEqual(convert(UInt(42))   as? LCNumber, 42)
        XCTAssertEqual(convert(Int8(42))   as? LCNumber, 42)
        XCTAssertEqual(convert(UInt8(42))  as? LCNumber, 42)
        XCTAssertEqual(convert(Int16(42))  as? LCNumber, 42)
        XCTAssertEqual(convert(UInt16(42)) as? LCNumber, 42)
        XCTAssertEqual(convert(Int32(42))  as? LCNumber, 42)
        XCTAssertEqual(convert(UInt32(42)) as? LCNumber, 42)
        XCTAssertEqual(convert(Int64(42))  as? LCNumber, 42)
        XCTAssertEqual(convert(UInt64(42)) as? LCNumber, 42)
    }

    func testFloatConvertible() {
        XCTAssertEqual(convert(Float(42))   as? LCNumber, 42)
        XCTAssertEqual(convert(Float80(42)) as? LCNumber, 42)
        XCTAssertEqual(convert(Double(42))  as? LCNumber, 42)
    }

    func testStringConvertible() {
        XCTAssertEqual(convert("foo") as? LCString, "foo")
        XCTAssertEqual(convert(NSString(string: "foo")) as? LCString, "foo")
    }

    func testArrayConvertible() {
        let array = [42, true, NSNull(), [:], [], NSData(), NSDate()]
        XCTAssertEqual(convert(array) as? LCArray, LCArray(unsafeObject: array))
    }

    func testDictionaryConvertible() {
        let dictionary = ["foo": "bar", "true": true, "dict": ["null": NSNull()]]
        XCTAssertEqual(convert(dictionary) as? LCDictionary, LCDictionary(unsafeObject: dictionary))
    }

    func testDataConvertible() {
        let data = NSData()
        XCTAssertEqual(convert(data) as? LCData, LCData(data))
    }

    func testDateConvertible() {
        let date = NSDate()
        XCTAssertEqual(convert(date) as? LCDate, LCDate(date))
    }

}
