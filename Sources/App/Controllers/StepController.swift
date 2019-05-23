import Vapor

struct StepController: RouteCollection {
  
  func boot(router: Router) throws {
    let stepsRoute = router.grouped("api", "steps")
    let basicAuthMiddleware = User.tokenAuthMiddleware()
    let authStepsRouteGroup = stepsRoute.grouped(basicAuthMiddleware)
    authStepsRouteGroup.post([Step].self, use: createBulkHandler)
    authStepsRouteGroup.put(Step.self, at: Step.parameter, use: updateHandler)
  }
  
  func createBulkHandler(_ req: Request, steps: [Step]) throws -> Future<[Step]> {
    let _ = try req.requireAuthenticated(User.self)
    return steps.map { step in
      step.create(on: req)
    }.flatten(on: req)
  }
  
  func updateHandler(_ req: Request, updatedStep: Step) throws -> Future<Step> {
    return try req.parameters.next(Step.self).flatMap(to: Step.self) { step in
      step.instructions = updatedStep.instructions
      step.number = updatedStep.number
      step.photo = updatedStep.photo
      return step.save(on: req)
    }
  }
  
  func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
    return try req.parameters.next(Step.self).delete(on: req).transform(to: .ok)
  }
}
