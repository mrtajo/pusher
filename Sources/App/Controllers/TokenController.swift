//
//  File.swift
//  
//
//  Created by brian.jo on 2021/02/03.
//

import Fluent
import Vapor
import APNS

struct TokenController {
    func create(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        // 1
        try req.content.decode(Token.self)
            // 2
            .create(on: req.db)
            // 3
            .transform(to: .noContent)
    }
    
    func delete(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        // 1
        let token = req.parameters.get("token")!
        // 2
        return Token.query(on: req.db)
            // 3
            .filter(\.$token == token)
            // 4
            .first()
            .unwrap(or: Abort(.notFound))
            // 5
            .flatMap { $0.delete(on: req.db) }
            // 6
            .transform(to: .noContent)
    }
    
    func notify(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        print("notify start")
        let alert = APNSwiftAlert(title: "Hello!", body: "How are you today?")
        
        // 1
        return Token.query(on: req.db)
            .all()
            // 2
            .flatMap { tokens in
                // 3
                tokens.map { token in
                    req.apns.send(alert, to: token.token)
                        // 4
                        .flatMapError {
                            // Unless APNs said it was a bad device token, just ignore the error.
                            guard case let APNSwiftError.ResponseError.badRequest(response) = $0,
                                  response == .badDeviceToken else {
                                return req.db.eventLoop.future()
                            }
                            
                            return token.delete(on: req.db)
                        }
                }
                // 5
                .flatten(on: req.eventLoop)
                // 6
                .transform(to: .noContent)
            }
    }
    
    func stemp(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        print("stemp start")
        let alert = APNSwiftAlert(title: "카카오페이", body: "스탬프 꽝 !!!")
        
        // 1
        return Token.query(on: req.db)
            .all()
            // 2
            .flatMap { tokens in
                // 3
                tokens.map { token in
                    req.apns.send(alert, to: token.token)
                        // 4
                        .flatMapError {
                            // Unless APNs said it was a bad device token, just ignore the error.
                            guard case let APNSwiftError.ResponseError.badRequest(response) = $0,
                                  response == .badDeviceToken else {
                                return req.db.eventLoop.future()
                            }
                            
                            return token.delete(on: req.db)
                        }
                }
                // 5
                .flatten(on: req.eventLoop)
                // 6
                .transform(to: .noContent)
            }
    }
    
    func getIp(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        print("getIp start")
        // 1
        let alert = APNSwiftAlert(title: "Updated Server", body: req.application.http.server.configuration.hostname)
        do {
            let token = try req.content.decode(Token.self)
            req.apns.send(alert, to: token.token)
        } catch {
            return req.eventLoop.makeFailedFuture(Abort(.notFound))
        }
        return req.eventLoop.makeSucceededFuture(.ok)
    }
    
//    func pass(req: Request) throws -> EventLoopFuture<Response> {
//        guard let url = Bundle.main.url(forResource: "membership-pass", withExtension: "pkpass") else {
//            throw Abort(.notFound)
//        }
//        return Pass(url: url).encodeResponse(for: req)
//    }
}

extension TokenController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let tokens = routes.grouped("token")
        tokens.post(use: create)
        tokens.delete(":token", use: delete)
        tokens.post("notify", use: notify)
        tokens.post("stemp", use: stemp)
        tokens.post("ip", use: getIp)
    }
}
