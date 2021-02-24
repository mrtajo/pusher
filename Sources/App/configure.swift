import Fluent
import FluentPostgresDriver
import Leaf
import Vapor
import APNS

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    
    app.databases.use(.postgres(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? PostgresConfiguration.ianaPortNumber,
        username: Environment.get("DATABASE_USERNAME") ?? "vapor_username",
        password: Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
        database: Environment.get("DATABASE_NAME") ?? "vapor_database"//"vapor_database"
    ), as: .psql)
    
    app.migrations.add(CreateToken())
    try! app.autoMigrate().wait()
    
    if app.environment != .production {
        app.http.server.configuration.hostname = "192.168.3.79"
    }
    
    // register routes
    try routes(app)
    
    let apnsEnvironment: APNSwiftConfiguration.Environment
    apnsEnvironment = app.environment == .production ? .production : .sandbox
    
    let auth: APNSwiftConfiguration.AuthenticationMethod = try .jwt(
        key: .private(filePath: "/Users/brian.jo/Codes/APNS_KEY/AuthKey_D54W4A79D9.p8"),
        keyIdentifier: "D54W4A79D9",
        teamIdentifier: "7YV3XSFHJM"
    )
    
    app.apns.configuration = .init(authenticationMethod: auth,
                                   topic: "com.mrtajo.payone",
                                   environment: apnsEnvironment)
    
    app.lifecycle.use(PushNotifier())
}
