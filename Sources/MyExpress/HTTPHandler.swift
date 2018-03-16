//
//  HTTPHandler.swift
//  MyExpress
//
//  Created by CaryZheng on 2018/3/16.
//

import Foundation
import NIO
import NIOHTTP1

final class HTTPHandler: ChannelInboundHandler {
    typealias InboundIn = HTTPServerRequestPart
    
    let router = Router()
    
    func channelRead(ctx: ChannelHandlerContext, data: NIOAny) {
        let reqPart = unwrapInboundIn(data)
        
        print("reqPart: \(reqPart)")
        
        switch reqPart {
        case .head(let header):
            print("req: \(header)")
            
            let req = IncomingMessage(header: header)
            let res = ServerResponse(channel: ctx.channel)
            
            router.handle(request: req, response: res) {
                (itmes: Any...) in
                
                res.status = .notFound
                res.send("No middleware handled the request")
            }
            
        case .body:
            break
        case .end:
            break
        }
    }
}
