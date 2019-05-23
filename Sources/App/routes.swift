import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
  // Basic "It works" example
  router.get { req in
    return "It works!"
  }
  
  // Basic "Hello, world!" example
  router.get("hello") { req in
    return "Hello, world!"
  }
  
  // Example of configuring a controller
  let usersController = UsersController()
  try router.register(collection: usersController)
  
  let recipeController = RecipeController()
  try router.register(collection: recipeController)
  
  let stepController = StepController()
  try router.register(collection: stepController)
}
