//
//  Server.swift
//  MyExpress
//
//  Created by CaryZheng on 2018/3/19.
//

import Foundation
import NIO
import NIOHTTP1

public class Server {
    var host: String
    var port: Int
    
    var group: MultiThreadedEventLoopGroup
    var threadPool: BlockingIOThreadPool
    
    var fileIO: NonBlockingFileIO
    
    var router: Router
    
    init(host: String, port: Int, router: Router, eventLoopThreads: Int = 1, poolThreads: Int = System.coreCount) {
        self.host = host
        self.port = port
        self.router = router
        
        group = MultiThreadedEventLoopGroup(numThreads: eventLoopThreads)
        threadPool = BlockingIOThreadPool(numberOfThreads: poolThreads)
        
        fileIO = NonBlockingFileIO(threadPool: threadPool)
    }
    
    func run() {
        let bootstrap = ServerBootstrap(group: group)
            .serverChannelOption(ChannelOptions.backlog, value: 256)
            .serverChannelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)
            
            .childChannelInitializer { channel in
                channel.pipeline.configureHTTPServerPipeline().then {
                    channel.pipeline.add(handler: Handler(fileIO: self.fileIO, router: self.router))
                }
            }
            
            .childChannelOption(ChannelOptions.socket(IPPROTO_TCP, TCP_NODELAY), value: 1)
            .childChannelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)
            .childChannelOption(ChannelOptions.maxMessagesPerRead, value: 1)
        
        do {
            let channel = try bootstrap.bind(host: host, port: port).wait()
            
            print("Server started, listening on: \(String(describing: channel.localAddress))")
            
            try channel.closeFuture.wait()
        } catch {
            print("Fail to start server")
        }
    }
}
