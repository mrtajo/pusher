import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get("pass") { req -> Pass in
        let url = URL(fileURLWithPath: app.directory.publicDirectory + "passes/membership-pass.pkpass")
        return Pass(url: url)
    }
    
    try app.register(collection: TokenController())
}
