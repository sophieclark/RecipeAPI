import Vapor
import FluentPostgreSQL

struct Recipe: Codable {
  var id: Int?
  var userID: User.ID
  var name: String
  var photo: Data?
  
  init(name: String, photo: Data?, userID: User.ID) {
    self.name = name
    self.photo = photo
    self.userID = userID
  }
}

extension Recipe: PostgreSQLModel {}
extension Recipe: Migration {}
extension Recipe: Content {}
extension Recipe: Parameter {}

extension Recipe {
  var user: Parent<Recipe, User> {
    return parent(\.userID)
  }
  var steps: Children<Recipe, Step> {
    return children(\.recipeID)
  }
  var ingredients: Children<Recipe, Ingredient> {
    return children(\.recipeID)
  }
}

struct RecipeWithStepsAndIngredients: Content {
  var userID: User.ID
  var name: String
  var photo: Data?
  var steps: [Step]?
  var ingredients: [Ingredient]?
}

struct CreateRecipe: Content {
  var name: String
  var photo: Data?
  
  init(name: String, photo: Data?) {
    self.name = name
    self.photo = photo
  }
}
