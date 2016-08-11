//
//  RESTClient.swift
//  LeanCloud
//
//  Created by Tang Tianyong on 3/30/16.
//  Copyright © 2016 LeanCloud. All rights reserved.
//

import Foundation
import Alamofire

/**
 LeanCloud REST client.

 This class manages requests for LeanCloud REST API.
 */
class RESTClient {
    /// HTTP Method.
    enum Method: String {
        case GET
        case POST
        case PUT
        case DELETE

        /// Get Alamofire corresponding method
        var alamofireMethod: Alamofire.HTTPMethod {
            switch self {
            case .GET:    return .get
            case .POST:   return .post
            case .PUT:    return .put
            case .DELETE: return .delete
            }
        }
    }

    /// Data type.
    enum DataType: String {
        case Object   = "Object"
        case Pointer  = "Pointer"
        case Relation = "Relation"
        case GeoPoint = "GeoPoint"
        case Bytes    = "Bytes"
        case Date     = "Date"
    }

    /// Reserved key.
    class ReservedKey {
        static let Op         = "__op"
        static let InternalId = "__internalId"
        static let Children   = "__children"
    }

    /// Header field name.
    class HeaderFieldName {
        static let ID         = "X-LC-Id"
        static let Signature  = "X-LC-Sign"
        static let Session    = "X-LC-Session"
        static let Production = "X-LC-Prod"
        static let UserAgent  = "User-Agent"
        static let Accept     = "Accept"
    }

    /// REST API version.
    static let APIVersion = "1.1"

    /// Default timeout interval of each request.
    static let defaultTimeoutInterval: TimeInterval = 10

    /// REST client shared instance.
    static let sharedInstance = RESTClient()

    /// Request dispatch queue.
    static let dispatchQueue = DispatchQueue(label: "LeanCloud.REST", attributes: .concurrent)

    /// Shared request manager.
    static var requestManager: Alamofire.SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = defaultTimeoutInterval
        return SessionManager(configuration: configuration)
    }()

    /// User agent of SDK.
    static let userAgent = "LeanCloud-Swift-SDK/\(Version)"

    /// Signature of each request.
    static var signature: String {
        let timestamp = String(format: "%.0f", 1000 * Date().timeIntervalSince1970)
        let hash = "\(timestamp)\(Configuration.sharedInstance.applicationKey!)".MD5String.lowercased()

        return "\(hash),\(timestamp)"
    }

    /// Common REST request headers.
    static var commonHeaders: [String: String] {
        var headers: [String: String] = [
            HeaderFieldName.ID:        Configuration.sharedInstance.applicationID,
            HeaderFieldName.Signature: self.signature,
            HeaderFieldName.UserAgent: self.userAgent,
            HeaderFieldName.Accept:    "application/json"
        ]

        if let sessionToken = LCUser.current?.sessionToken {
            headers[HeaderFieldName.Session] = sessionToken.value
        }

        return headers
    }

    /// REST host for current service region.
    static var host: String {
        switch Configuration.sharedInstance.serviceRegion {
        case .cn: return "api.leancloud.cn"
        case .us: return "us-api.leancloud.cn"
        }
    }

    /**
     Get endpoint of object.

     - parameter object: The object from which you want to get the endpoint.

     - returns: The endpoint of object.
     */
    static func endpoint(_ object: LCObject) -> String {
        return endpoint(object.actualClassName)
    }

    /**
     Get eigen endpoint of object.

     - parameter object: The object from which you want to get the eigen endpoint.

     - returns: The eigen endpoint of object.
     */
    static func eigenEndpoint(_ object: LCObject) -> String? {
        guard let objectId = object.objectId else {
            return nil
        }

        return "\(endpoint(object))/\(objectId.value)"
    }

    /**
     Get endpoint for class name.

     - parameter className: The class name.

     - returns: The endpoint for class name.
     */
    static func endpoint(_ className: String) -> String {
        switch className {
        case LCUser.objectClassName():
            return "users"
        case LCRole.objectClassName():
            return "roles"
        default:
            return "classes/\(className)"
        }
    }

    /**
     Get absolute REST API URL string for endpoint.

     - parameter endpoint: The REST API endpoint.

     - returns: An absolute REST API URL string.
     */
    static func absoluteURLString(_ endpoint: String) -> String {
        return "https://\(self.host)/\(self.APIVersion)/\(endpoint)"
    }

    /**
     Merge headers with common headers.

     Field in `headers` will overrides the field in common header with the same name.

     - parameter headers: The headers to be merged.

     - returns: The merged headers.
     */
    static func mergeCommonHeaders(_ headers: [String: String]?) -> [String: String] {
        var result = commonHeaders

        headers?.forEach { (key, value) in result[key] = value }

        return result
    }

    /**
     Creates a request to REST API and sends it asynchronously.

     - parameter method:            The HTTP Method.
     - parameter endpoint:          The REST API endpoint.
     - parameter parameters:        The request parameters.
     - parameter headers:           The request headers.
     - parameter completionHandler: The completion callback closure.

     - returns: A request object.
     */
    static func request(
        _ method: Method,
        _ endpoint: String,
        parameters: [String: AnyObject]? = nil,
        headers: [String: String]? = nil,
        completionHandler: (LCResponse) -> Void)
        -> LCRequest
    {
        let method    = method.alamofireMethod
        let URLString = absoluteURLString(endpoint)
        let headers   = mergeCommonHeaders(headers)
        var encoding: ParameterEncoding!

        switch method {
        case .get: encoding = .urlEncodedInURL
        default:   encoding = .json
        }

        let request = requestManager.request(URLString, withMethod: method, parameters: parameters, encoding: encoding, headers: headers)

        request.responseJSON(queue: dispatchQueue) { response in
            completionHandler(LCResponse(response))
        }

        return LCRequest(request)
    }

    /**
     Creates a request to REST API and sends it synchronously.

     - parameter method:     The HTTP Method.
     - parameter endpoint:   The REST API endpoint.
     - parameter parameters: The request parameters.
     - parameter headers:    The request headers.

     - returns: A response object.
     */
    static func request(
        _ method: Method,
        _ endpoint: String,
        headers: [String: String]? = nil,
        parameters: [String: AnyObject]? = nil)
        -> LCResponse
    {
        var result: LCResponse!

        let semaphore = DispatchSemaphore(value: 0)

        _ = request(method, endpoint, parameters: parameters, headers: headers) { response in
            result = response
            semaphore.signal()
        }

        _ = semaphore.wait(timeout: DispatchTime.distantFuture)

        return result
    }

    /**
     Asynchronize task into request dispatch queue.

     - parameter task:       The task to be asynchronized.
     - parameter completion: The completion closure to be called on main thread after task finished.
     */
    static func asynchronize<Result>(_ task: () -> Result, completion: (Result) -> Void) {
        Utility.asynchronize(task, dispatchQueue, completion)
    }
}
