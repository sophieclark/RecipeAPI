import FluentPostgreSQL
import Vapor
import Authentication

public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
  try services.register(FluentPostgreSQLProvider())
  try services.register(AuthenticationProvider())
  let router = EngineRouter.default()
  try routes(router)
  services.register(router, as: Router.self)
  var middlewares = MiddlewareConfig()
  middlewares.use(ErrorMiddleware.self)
  services.register(middlewares)

  var databases = DatabasesConfig()
  let databaseConfig = PostgreSQLDatabaseConfig(
    hostname: "localhost",
    username: "sophie",
    database: "sophie",
    password: "password")
  let database = PostgreSQLDatabase(config: databaseConfig)
  databases.add(database: database, as: .psql)
  services.register(databases)
  
  var migrations = MigrationConfig()
  migrations.add(model: User.self, database: .psql)
  migrations.add(model: Recipe.self, database: .psql)
  migrations.add(model: Step.self, database: .psql)
  migrations.add(model: Token.self, database: .psql)
  migrations.add(model: Ingredient.self, database: .psql)
  migrations.add(migration: CreateDefaultUser.self, database: .psql)
  services.register(migrations)
}
