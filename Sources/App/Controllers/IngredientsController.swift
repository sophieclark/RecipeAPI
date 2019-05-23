import Vapor

struct IngredientController: RouteCollection {
  
  func boot(router: Router) throws {
    let ingredientsRoute = router.grouped("api", "ingredients")
    let basicAuthMiddleware = User.tokenAuthMiddleware()
    let authIngredientsRouteGroup = ingredientsRoute.grouped(basicAuthMiddleware)
    authIngredientsRouteGroup.post([Ingredient].self, use: createBulkHandler)
  }
  
  func createBulkHandler(_ req: Request, ingredients: [Ingredient]) throws -> Future<[Ingredient]> {
    let _ = try req.requireAuthenticated(User.self)
    return ingredients.map { ingredient in
      ingredient.create(on: req)
      }.flatten(on: req)
  }
  
  func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
    return try req.parameters.next(Ingredient.self).delete(on: req).transform(to: .ok)
  }
}
