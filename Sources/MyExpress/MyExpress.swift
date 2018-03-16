//
//  MyExpress.swift
//  MyExpress
//
//  Created by CaryZheng on 2018/3/14.
//

import Foundation
import NIO
import NIOHTTP1

typealias Next = (Any...) -> Void
typealias Middleware = (IncomingMessage, ServerResponse, Next) -> Void

class MyExpress {
    
    let loopGroup = MultiThreadedEventLoopGroup(numThreads: System.coreCount)
    
    func listen(_ port: Int) {
        let reuseAddrOpt = ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR)
        
        let bootstrap = ServerBootstrap(group: loopGroup)
            .serverChannelOption(ChannelOptions.backlog, value: 256)
            .serverChannelOption(reuseAddrOpt, value: 1)
            
            .childChannelInitializer { channel in
                channel.pipeline.addHTTPServerHandlers().then {
                    channel.pipeline.add(handler: HTTPHandler())
                }
            }
        
            .childChannelOption(ChannelOptions.socket(IPPROTO_TCP, TCP_NODELAY), value: 1)
            .childChannelOption(ChannelOptions.maxMessagesPerRead, value: 1)
        
        do {
            let serverChannel = try bootstrap.bind(host: "localhost", port: port)
                .wait()
            
            print("Server running on: \(String(describing: serverChannel.localAddress))")
            
            try serverChannel.closeFuture.wait()
        } catch {
            fatalError("Fail to start server: \(error)")
        }
    }
    
}
