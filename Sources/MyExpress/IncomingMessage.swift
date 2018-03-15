//
//  IncomingMessage.swift
//  MyExpress
//
//  Created by CaryZheng on 2018/3/15.
//

import NIOHTTP1

class IncomingMessage {
    let header: HTTPRequestHead
    var userInfo = [String: Any]()
    
    init(header: HTTPRequestHead) {
        self.header = header
    }
}
