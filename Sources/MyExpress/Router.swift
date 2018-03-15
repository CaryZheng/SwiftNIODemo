//
//  Router.swift
//  MyExpress
//
//  Created by CaryZheng on 2018/3/15.
//

import Foundation
import NIO

protocol RouterProtocol {
    var middleware: [Middleware] { get set }
    func use(_ middleware: Middleware...)
}

class Router: RouterProtocol {
    
    private var part = ""
    var middleware = [Middleware]()
    
    init() {
        middleware.append(testMiddle)
    }
    
    func testMiddle(req: IncomingMessage, res: ServerResponse, next: Next) {
        print("testMiddle")
        
        res.send("Test from Cary")
    }
    
    func use(_ middleware: Middleware...) {
        self.middleware.append(contentsOf: middleware)
    }
    
    func handle(request: IncomingMessage,
                response: ServerResponse,
                next upperNext: @escaping Next) {
        final class State {
            var stack: ArraySlice<Middleware>
            let request: IncomingMessage
            let response: ServerResponse
            var next: Next?
            
            init(_ stack: ArraySlice<Middleware>,
                _ request: IncomingMessage,
                _ response: ServerResponse,
                _ next: @escaping Next) {
                self.stack = stack
                self.request = request
                self.response = response
                self.next = next
            }
            
            func step(_ args: Any...) {
                if let middleware = stack.popFirst() {
                    middleware(request, response, self.step)
                } else {
                    next?()
                    next = nil
                }
            }
        }
        
        let state = State(middleware[middleware.indices],
                          request,
                          response,
                          upperNext)
        state.step()
    }
    
}

extension Router {
    
    func get(_ path: String = "", middleware: @escaping Middleware) {
        use { req, res, next in
            guard req.header.method == .GET,
                req.header.uri.hasPrefix(self.part+path)
            else { return next() }
            
            middleware(req, res, next)
        }
    }
    
}

extension Router {
    
    func use(router: Router) {
        router.middleware.map {
            self.middleware.append($0)
        }
    }
    
    func use(_ part: String, router: Router) {
        router.part = part
        use(router: router)
    }
    
}
