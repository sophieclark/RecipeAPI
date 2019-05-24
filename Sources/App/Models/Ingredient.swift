import Vapor
import FluentPostgreSQL

struct Ingredient: Codable {
  var id: Int?
  var recipeID: Recipe.ID
  var amount: Float
  var name: String
  var measurementType: String
}

extension Ingredient: PostgreSQLModel {}
extension Ingredient: Migration {}
extension Ingredient: Content {}
extension Ingredient: Parameter {}

extension Ingredient {
  var recipe: Parent<Ingredient, Recipe> {
    return parent(\.recipeID)
  }
}
