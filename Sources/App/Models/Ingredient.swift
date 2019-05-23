import Vapor
import FluentPostgreSQL

enum MeasurementType: String, Codable {
  case grams
  case kilograms
  case litres
  case mililetres
  case centiletres
  case ounce
  case pound
  case quantity
}

extension MeasurementType: ReflectionDecodable {
  static func reflectDecoded() throws -> (MeasurementType, MeasurementType) {
    return (.grams, .kilograms)
  }
}

struct Ingredient: Codable {
  var id: Int?
  var recipeID: Recipe.ID
  var amount: Float
  var name: String
  var measurementType: MeasurementType
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
