import Foundation
import Vapor
import FluentPostgreSQL
import Authentication

final class Token: Codable {
  var id: UUID?
  var token: String
  var userID: User.ID
  
  init(token: String, userID: User.ID) {
    self.token = token
    self.userID = userID
  }
}

extension Token: PostgreSQLUUIDModel {}
extension Token: Migration {}
extension Token: Content {}

extension Token {
  static func generate(for user: User, on req: Request) throws -> Token {
    let random = try CryptoRandom().generateData(count: 32)
      .base64EncodedString()
    return try Token(token: random, userID: user.requireID())
  }
}

extension Token: Authentication.Token {
  typealias UserType = User
  static let userIDKey: UserIDKey = \Token.userID
}

extension Token: BearerAuthenticatable {
  static let tokenKey: TokenKey = \Token.token
}
