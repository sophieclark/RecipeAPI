import Vapor
import Authentication
import Fluent

struct RecipeController: RouteCollection {
  
  func boot(router: Router) throws {
    let recipesRoute = router.grouped("api", "recipes")
    recipesRoute.get(Recipe.parameter, use: getRecipeWithStepsAndIngredients)
    let basicAuthMiddleware = User.tokenAuthMiddleware()
    let authRecipeRouteGroup = recipesRoute.grouped(basicAuthMiddleware)
    authRecipeRouteGroup.post(CreateRecipe.self, use: createHandler)
    authRecipeRouteGroup.delete(Recipe.parameter, use: deleteHandler)
  }
  
  func createHandler(_ req: Request, recipe: CreateRecipe) throws -> Future<Recipe> {
    let user = try req.requireAuthenticated(User.self)
    let recipe = try Recipe(name: recipe.name, photo: recipe.photo, userID: user.requireID())
    return recipe.save(on: req)
  }
  
  func getRecipeWithStepsAndIngredients(_ req: Request) throws -> Future<RecipeWithStepsAndIngredients> {
    return try req.parameters.next(Recipe.self).flatMap { recipe in
      let steps = try recipe.steps.query(on: req).all()
      let ingredients = try recipe.ingredients.query(on: req).all()
      return steps.and(ingredients).map(to: RecipeWithStepsAndIngredients.self) { (steps, ingredients) in
        return RecipeWithStepsAndIngredients(userID: recipe.userID, name: recipe.name, photo: recipe.photo, steps: steps, ingredients: ingredients)
      }
    }
  }
  
  func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
    let _ = try req.requireAuthenticated(User.self)
    return try req.parameters.next(Recipe.self).delete(on: req).transform(to: .ok)
  }
}
