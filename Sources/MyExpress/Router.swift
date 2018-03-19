//
//  Router.swift
//  MyExpress
//
//  Created by CaryZheng on 2018/3/19.
//

import Foundation

public protocol Responder {
    func respond() -> String
}

public struct RouterResponder<T>: Responder where T: Encodable {
    
    public typealias Handler = () -> T
    
    public let handler: Handler
    
    public init(handler: @escaping Handler) {
        self.handler = handler
    }
    
    public func respond() -> String {
        do {
            let data = try JSONEncoder().encode(handler())
            return String(data: data, encoding: .utf8)!
        } catch {
            print("RouterResponder respond error")
        }
        
        return ""
    }
    
}

public class Router {
    
    var routingTable = [String: Responder]()
    
    func get<T: Encodable>(_ route: String, handler: @escaping () -> T) {
        routingTable[route] = RouterResponder<T>(handler: handler)
    }
    
}
