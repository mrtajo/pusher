//
//  File.swift
//  
//
//  Created by brian.jo on 2021/02/18.
//

import Foundation
import Vapor
import APNS
import Fluent

struct PushNotifier: LifecycleHandler {
    func didBoot(_ application: Application) throws {
        
        let alert = APNSwiftAlert(title: "Updated Server", body: application.http.server.configuration.hostname)
        
        Token.query(on: application.db).all().flatMap { tokens -> EventLoopFuture<Void> in
            tokens.map { token in
                application.apns.send(alert, to: token.token)
            }
            return application.db.eventLoop.future()
        }
        
        // 1
//        Token.query(on: application.db)
//            .all()
//            // 2
//            .flatMap { tokens in
//                // 3
//                tokens.map { token in
//                    application.apns.send(alert, to: token.token)
//                        // 4
//                        .flatMapError {
//                            // Unless APNs said it was a bad device token, just ignore the error.
//                            guard case let APNSwiftError.ResponseError.badRequest(response) = $0,
//                                  response == .badDeviceToken else {
//                                return
//                            }
//
//                            return
//                        }
//                }
//            }
        
        
    }
}
