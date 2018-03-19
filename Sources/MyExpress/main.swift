import Foundation
import NIO

struct User: Codable {
    let name: String
    let age: Int
}

let users = [
    User(name: "Cary", age: 18),
    User(name: "zzb", age: 20)
]

let router = Router()

router.get("/users") {
    return users
}

router.get("/user/0") {
    return users[0]
}

let server = Server(host: "localhost", port: 8989, router: router)
server.run()

print("Server closed")
