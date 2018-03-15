//
//  ServerResponse.swift
//  MyExpress
//
//  Created by CaryZheng on 2018/3/15.
//

import Foundation
import NIO
import NIOHTTP1

class ServerResponse {
    var status = HTTPResponseStatus.ok
    var headers = HTTPHeaders()
    let channel: Channel
    
    var didWriteHeader = false
    var didEnd = false
    
    init(channel: Channel) {
        self.channel = channel
    }
    
    func send(_ s: String) {
        flushHeader()
        
        let utf8 = s.utf8
        var buffer = channel.allocator.buffer(capacity: utf8.count)
        buffer.write(bytes: utf8)
        
        let part = HTTPServerResponsePart.body(.byteBuffer(buffer))
        
        _ = channel.writeAndFlush(part)
            .mapIfError(handleError)
            .map { self.end() }
    }
    
    func flushHeader() {
        guard !didWriteHeader else { return }
        
        didWriteHeader = true
        
        let head = HTTPResponseHead(version: .init(major: 1, minor: 1), status: status, headers: headers)
        let part = HTTPServerResponsePart.head(head)
        _ = channel.writeAndFlush(part).mapIfError(handleError)
    }
    
    func handleError(_ error: Error) {
        print("handleError error = \(error)")
        
        end()
    }
    
    func end() {
        guard !didEnd else { return }
        didEnd = true
        
        _ = channel.writeAndFlush(HTTPServerResponsePart.end(nil))
            .map { self.channel.close()}
    }
}

extension ServerResponse {
    
    public subscript(name: String) -> String? {
        set {
            assert(!didWriteHeader, "header is out")
            if let v = newValue {
                headers.replaceOrAdd(name: name, value: v)
            } else {
                headers.remove(name: name)
            }
        }
        
        get {
            return headers[name].joined(separator: ", ")
        }
    }
    
}

extension ServerResponse {
    
    func json<T: Encodable>(_ model: T) {
        let data: Data
        do {
            data = try JSONEncoder().encode(model)
        } catch {
            return handleError(error)
        }
        
        self["Content-Type"] = "application/json"
        self["Content-Length"] = "\(data.count)"
        
        flushHeader()
        
        var buffer = channel.allocator.buffer(capacity: data.count)
        buffer.write(bytes: data)
        let part = HTTPServerResponsePart.body(.byteBuffer(buffer))
        
        _ = channel.writeAndFlush(part)
            .mapIfError(handleError)
            .map { self.end() }
    }
    
}
