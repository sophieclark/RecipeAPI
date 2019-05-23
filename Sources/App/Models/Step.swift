import Vapor
import FluentPostgreSQL

final class Step: Codable {
  var id: Int?
  var recipeID: Recipe.ID
  var number: Int
  var instructions: String
  var photo: Data?
}

extension Step: PostgreSQLModel {}
extension Step: Migration {}
extension Step: Content {}
extension Step: Parameter {}

extension Step {
  var recipe: Parent<Step, Recipe> {
    return parent(\.recipeID)
  }
}
