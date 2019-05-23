import Vapor
import Crypto
import Authentication

struct UsersController: RouteCollection {

  func boot(router: Router) throws {
    let usersRoute = router.grouped("api", "users")
    usersRoute.post(use: createHandler)
    let basicAuthMiddleware = User.basicAuthMiddleware(using: BCryptDigest())
    let loginRouteGroup = usersRoute.grouped(basicAuthMiddleware)
    loginRouteGroup.post("login", use: loginHandler)
    let authUserRouteGroup = usersRoute.grouped(basicAuthMiddleware)
    authUserRouteGroup.put(User.self, at: User.parameter, use: updateHandler)
  }

  func createHandler(_ req: Request) throws -> Future<User> {
    return try req.content.decode(User.self)
      .flatMap(to: User.self) { user in
        user.password = try BCrypt.hash(user.password)
        user.emailAddress = try BCrypt.hash(user.emailAddress)
        return user.save(on: req)
    }
  }
  
  func loginHandler(_ req: Request) throws -> Future<Token> {
    let user = try req.requireAuthenticated(User.self)
    let token = try Token.generate(for: user, on: req)
    return token.save(on: req)
  }
  
  func updateHandler(_ req: Request, updatedUser: User) throws -> Future<User> {
    return try req.parameters.next(User.self).flatMap(to: User.self) { user in
      user.firstname = updatedUser.firstname
      user.surname = updatedUser.surname
      user.username = updatedUser.username
      user.password = try BCrypt.hash(updatedUser.password)
      user.emailAddress = try BCrypt.hash(updatedUser.emailAddress)
      return user.save(on: req)
    }
  }
}
