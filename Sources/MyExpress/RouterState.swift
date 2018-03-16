//
//  RouterState.swift
//  MyExpress
//
//  Created by CaryZheng on 2018/3/16.
//

import Foundation

final class RouterState {
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
