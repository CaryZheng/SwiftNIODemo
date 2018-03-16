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
        let state = RouterState(middleware[middleware.indices],
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
        _ = router.middleware.map {
            self.middleware.append($0)
        }
    }
    
    func use(_ part: String, router: Router) {
        router.part = part
        use(router: router)
    }
    
}
