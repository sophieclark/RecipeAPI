import Vapor
import FluentPostgreSQL
import Authentication

final class User: Codable {
  var id: UUID?
  var firstname: String
  var surname: String
  var emailAddress: String
  var username: String
  var password: String
  
  init(firstname: String, surname: String, emailAddress: String, username: String, password: String) {
    self.firstname = firstname
    self.surname = surname
    self.emailAddress = emailAddress
    self.username = username
    self.password = password
  }
  
  final class Public: Codable {
    var id: UUID?
    var firstname: String
    var surname: String
    var emailAddress: String
    var username: String
    
    init(id: UUID?, firstname: String, surname: String, emailAddress: String, username: String) {
      self.id = id
      self.firstname = firstname
      self.surname = surname
      self.emailAddress = emailAddress
      self.username = username
    }
  }
}

extension User: PostgreSQLUUIDModel {}
extension User: Migration {
  static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
    return Database.create(self, on: connection) { builder in
      try addProperties(to: builder)
      builder.unique(on: \.emailAddress)
      builder.unique(on: \.username)
    }
  }
}
extension User: Content {}
extension User: Parameter {}

extension User {
  var recipes: Children<User, Recipe> {
    return children(\.userID)
  }
}

extension User: BasicAuthenticatable {
  static let usernameKey: UsernameKey = \.username
  static let passwordKey: PasswordKey = \.password
}

extension User: TokenAuthenticatable {
  typealias TokenType = Token
}

extension User.Public: Content {}

extension User {
  func convertToPublic() -> User.Public {
    return User.Public(id: id, firstname: firstname, surname: surname, emailAddress: emailAddress, username: username)
  }
}

extension Future where T: User {
  func convertToPublic() -> Future<User.Public> {
    return self.map(to: User.Public.self) { user in
      return user.convertToPublic()
    }
  }
}

struct CreateDefaultUser: PostgreSQLMigration {
  static func prepare(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
    let password = try? BCrypt.hash("password")
    let email = try? BCrypt.hash("sophie.clark28@live.co.uk")
    guard let hashedPassword = password, let hashedEmailAddress = email else {
      fatalError("Failed to hash password for default user")
    }
    let user = User(firstname: "Sophie", surname: "Clark", emailAddress: hashedEmailAddress, username: "sophieclark", password: hashedPassword)
    return user.save(on: conn).transform(to: ())
  }
  
  static func revert(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
    return .done(on: conn)
  }
}
