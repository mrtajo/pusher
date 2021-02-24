//
//  File.swift
//  
//
//  Created by brian.jo on 2021/02/03.
//

import Vapor
import Fluent

struct CreateToken: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("tokens")
            .id()
            .field("token", .string, .required)
            .field("debug", .bool, .required)
            .unique(on: "token")
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("tokens").delete()
    }
}
