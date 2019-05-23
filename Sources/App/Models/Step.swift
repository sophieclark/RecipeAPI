import Vapor
import FluentPostgreSQL

final class Step: Codable {
  var id: Int?
  var recipeID: Recipe.ID
  var number: Int
  var instructions: String
  var photo: Data?
    
  init(id: Int?, recipeID: Recipe.ID, number: Int, instructions: String, photo: Data?) {
    self.id = id
    self.recipeID = recipeID
    self.number = number
    self.instructions = instructions
    self.photo = photo
  }
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
