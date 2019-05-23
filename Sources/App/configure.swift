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
  let databaseConfig: PostgreSQLDatabaseConfig
  if let url = Environment.get("DATABASE_URL") {
    databaseConfig = PostgreSQLDatabaseConfig(url: url)!
  } else if let url = Environment.get("DB_POSTGRESQL") {
    databaseConfig = PostgreSQLDatabaseConfig(url: url)!
  } else {
    let hostname = Environment.get("DATABASE_HOSTNAME") ?? "localhost"
    let username = Environment.get("DATABASE_USER") ?? "vapor"
    let password = Environment.get("DATABASE_PASSWORD") ?? "password"
    let databaseName: String
    let databasePort: Int
    if (env == .testing) {
      databaseName = "vapor-test"
      if let testPort = Environment.get("DATABASE_PORT") {
        databasePort = Int(testPort) ?? 5433
      } else {
        databasePort = 5433
      }
    } else {
      databaseName = Environment.get("DATABASE_DB") ?? "vapor"
      databasePort = 5432
    }
    
    databaseConfig = PostgreSQLDatabaseConfig(
      hostname: hostname,
      port: databasePort,
      username: username,
      database: databaseName,
      password: password)
  }
  
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
