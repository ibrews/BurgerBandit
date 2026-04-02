import SpriteKit

enum RestaurantType: String, CaseIterable {
    case burgerBarn     // McDonald's inspired — yellow/red
    case queenBurger    // Burger King inspired — orange/brown
    case freckles       // Wendy's inspired — red/white, square burgers
    case papaRoosters   // Popeyes inspired — purple/spice, chicken focused

    var displayName: String {
        switch self {
        case .burgerBarn:    return "Burger Barn"
        case .queenBurger:   return "Queen Burger"
        case .freckles:      return "Freckle's"
        case .papaRoosters:  return "Papa Rooster's"
        }
    }

    var tagline: String {
        switch self {
        case .burgerBarn:    return "Billions and Billions Stolen"
        case .queenBurger:   return "Have It Your (Stolen) Way"
        case .freckles:      return "Quality Is Our Recipe... For Theft"
        case .papaRoosters:  return "Love That Chicken From Rooster's"
        }
    }

    // Main kitchen wall / counter theme colors
    var primaryColor: UIColor {
        switch self {
        case .burgerBarn:    return UIColor(red: 0.98, green: 0.82, blue: 0.0, alpha: 1)   // golden yellow
        case .queenBurger:   return UIColor(red: 0.95, green: 0.5, blue: 0.05, alpha: 1)  // flame orange
        case .freckles:      return UIColor(red: 0.9, green: 0.15, blue: 0.15, alpha: 1)  // Wendy's red
        case .papaRoosters:  return UIColor(red: 0.55, green: 0.15, blue: 0.7, alpha: 1)  // cajun purple
        }
    }

    var secondaryColor: UIColor {
        switch self {
        case .burgerBarn:    return UIColor(red: 0.95, green: 0.2, blue: 0.1, alpha: 1)   // ketchup red
        case .queenBurger:   return UIColor(red: 0.55, green: 0.3, blue: 0.1, alpha: 1)   // BK brown
        case .freckles:      return UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1)    // white
        case .papaRoosters:  return UIColor(red: 0.95, green: 0.7, blue: 0.1, alpha: 1)   // spicy orange
        }
    }

    var floorColor: UIColor {
        switch self {
        case .burgerBarn:    return UIColor(red: 0.98, green: 0.97, blue: 0.88, alpha: 1)
        case .queenBurger:   return UIColor(red: 0.95, green: 0.9, blue: 0.8, alpha: 1)
        case .freckles:      return UIColor(red: 0.95, green: 0.9, blue: 0.88, alpha: 1)
        case .papaRoosters:  return UIColor(red: 0.9, green: 0.88, blue: 0.95, alpha: 1)
        }
    }

    var wallColor: UIColor {
        switch self {
        case .burgerBarn:    return UIColor(red: 0.88, green: 0.7, blue: 0.05, alpha: 1)
        case .queenBurger:   return UIColor(red: 0.82, green: 0.4, blue: 0.05, alpha: 1)
        case .freckles:      return UIColor(red: 0.75, green: 0.1, blue: 0.1, alpha: 1)
        case .papaRoosters:  return UIColor(red: 0.42, green: 0.1, blue: 0.58, alpha: 1)
        }
    }

    var counterColor: UIColor {
        // All kitchens use stainless steel counters (slight tint)
        return UIColor(red: 0.78, green: 0.80, blue: 0.82, alpha: 1)
    }

    var servingCounterColor: UIColor {
        switch self {
        case .burgerBarn:    return UIColor(red: 0.75, green: 0.55, blue: 0.3, alpha: 1)
        case .queenBurger:   return UIColor(red: 0.65, green: 0.45, blue: 0.25, alpha: 1)
        case .freckles:      return UIColor(red: 0.8, green: 0.6, blue: 0.55, alpha: 1)
        case .papaRoosters:  return UIColor(red: 0.6, green: 0.45, blue: 0.65, alpha: 1)
        }
    }

    var guardUniformColor: UIColor {
        switch self {
        case .burgerBarn:    return UIColor(red: 0.2, green: 0.4, blue: 0.8, alpha: 1)    // blue security
        case .queenBurger:   return UIColor(red: 0.15, green: 0.55, blue: 0.25, alpha: 1) // green security
        case .freckles:      return UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1)    // dark gray
        case .papaRoosters:  return UIColor(red: 0.55, green: 0.15, blue: 0.7, alpha: 1)  // purple (matches brand)
        }
    }

    // Preferred food types that spawn more frequently in this restaurant
    var boostedFoods: [FoodType] {
        switch self {
        case .burgerBarn:    return [.completeBurger, .rawPatty, .bun]
        case .queenBurger:   return [.completeBurger, .chickenPiece, .condimentPacket]
        case .freckles:      return [.completeBurger, .softDrink, .bun]
        case .papaRoosters:  return [.chickenPiece, .chickenPiece, .fries]
        }
    }

    var layoutVariant: Int {
        switch self {
        case .burgerBarn:    return 0
        case .queenBurger:   return 1
        case .freckles:      return 2
        case .papaRoosters:  return 3
        }
    }

    // Spatial order: Burger Barn | Queen Burger | Freckle's | Papa Rooster's
    var leftNeighbor: RestaurantType? {
        switch self {
        case .burgerBarn:    return nil
        case .queenBurger:   return .burgerBarn
        case .freckles:      return .queenBurger
        case .papaRoosters:  return .freckles
        }
    }

    var rightNeighbor: RestaurantType? {
        switch self {
        case .burgerBarn:    return .queenBurger
        case .queenBurger:   return .freckles
        case .freckles:      return .papaRoosters
        case .papaRoosters:  return nil
        }
    }
}
