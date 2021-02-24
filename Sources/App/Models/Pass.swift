//
//  Pass.swift
//  
//
//  Created by brian.jo on 2021/02/16.
//

import Vapor

struct Pass {
    let url: URL
}

extension Pass: ResponseEncodable {
    func encodeResponse(for request: Request) -> EventLoopFuture<Response> {
        do {
            var headers = HTTPHeaders()
                headers.add(name: .contentType, value: "application/x-www-form-urlencoded")
            let data = try Data(contentsOf: url)
            return request.eventLoop.makeSucceededFuture(.init(status: .ok, headers: headers, body: .init(data: data)))
        } catch {
            return request.eventLoop.makeFailedFuture(Abort(.notFound))
        }
    }
}
