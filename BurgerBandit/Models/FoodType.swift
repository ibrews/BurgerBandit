import SpriteKit

enum FoodType: String, CaseIterable {
    // Low value — raw ingredients
    case rawPatty
    case bun
    case condimentPacket

    // High value — finished food on serving counter
    case completeBurger
    case fries
    case chickenPiece
    case softDrink

    // Special — rare speed boost
    case veggie

    var displayName: String {
        switch self {
        case .rawPatty:       return "Raw Patty"
        case .bun:            return "Bun"
        case .condimentPacket: return "Condiment"
        case .completeBurger: return "Burger!"
        case .fries:          return "Fries!"
        case .chickenPiece:   return "Chicken!"
        case .softDrink:      return "Drink!"
        case .veggie:         return "VEGGIE???"
        }
    }

    var points: Int {
        switch self {
        case .rawPatty:       return 5
        case .bun:            return 3
        case .condimentPacket: return 2
        case .completeBurger: return 25
        case .fries:          return 20
        case .chickenPiece:   return 30
        case .softDrink:      return 15
        case .veggie:         return 50
        }
    }

    // Negative = lose health, positive = gain health
    var healthEffect: Int {
        switch self {
        case .rawPatty:       return -5
        case .bun:            return -3
        case .condimentPacket: return -2
        case .completeBurger: return -15
        case .fries:          return -12
        case .chickenPiece:   return -10
        case .softDrink:      return -8
        case .veggie:         return +12
        }
    }

    var isHighValue: Bool {
        switch self {
        case .completeBurger, .fries, .chickenPiece, .softDrink: return true
        default: return false
        }
    }

    var isVegetable: Bool { self == .veggie }

    var countsAsFatFood: Bool { self != .veggie }

    // Body fill color (cell shaded)
    var bodyColor: UIColor {
        switch self {
        case .rawPatty:       return UIColor(red: 0.85, green: 0.45, blue: 0.35, alpha: 1)
        case .bun:            return UIColor(red: 0.95, green: 0.82, blue: 0.55, alpha: 1)
        case .condimentPacket: return UIColor(red: 0.95, green: 0.2, blue: 0.15, alpha: 1)
        case .completeBurger: return UIColor(red: 0.85, green: 0.55, blue: 0.15, alpha: 1)
        case .fries:          return UIColor(red: 1.0, green: 0.88, blue: 0.2, alpha: 1)
        case .chickenPiece:   return UIColor(red: 0.98, green: 0.75, blue: 0.25, alpha: 1)
        case .softDrink:      return UIColor(red: 0.35, green: 0.7, blue: 0.95, alpha: 1)
        case .veggie:         return UIColor(red: 0.25, green: 0.85, blue: 0.3, alpha: 1)
        }
    }

    var accentColor: UIColor {
        switch self {
        case .rawPatty:       return UIColor(red: 0.7, green: 0.3, blue: 0.2, alpha: 1)
        case .bun:            return UIColor(red: 0.8, green: 0.65, blue: 0.35, alpha: 1)
        case .condimentPacket: return UIColor(red: 0.7, green: 0.1, blue: 0.1, alpha: 1)
        case .completeBurger: return UIColor(red: 0.6, green: 0.35, blue: 0.05, alpha: 1)
        case .fries:          return UIColor(red: 0.85, green: 0.65, blue: 0.1, alpha: 1)
        case .chickenPiece:   return UIColor(red: 0.85, green: 0.55, blue: 0.1, alpha: 1)
        case .softDrink:      return UIColor(red: 0.15, green: 0.45, blue: 0.8, alpha: 1)
        case .veggie:         return UIColor(red: 0.1, green: 0.65, blue: 0.15, alpha: 1)
        }
    }

    // Spawn weight for random selection (higher = more common)
    var spawnWeight: Double {
        switch self {
        case .rawPatty:       return 25
        case .bun:            return 20
        case .condimentPacket: return 15
        case .completeBurger: return 12
        case .fries:          return 12
        case .chickenPiece:   return 10
        case .softDrink:      return 10
        case .veggie:         return 1  // extremely rare!
        }
    }

    // Random food for serving counters (high value only)
    static func randomHighValue() -> FoodType {
        let highValue: [FoodType] = [.completeBurger, .fries, .chickenPiece, .softDrink]
        return highValue.randomElement()!
    }

    // Random food for prep counters (low value)
    static func randomLowValue() -> FoodType {
        let lowValue: [FoodType] = [.rawPatty, .rawPatty, .bun, .bun, .condimentPacket]
        return lowValue.randomElement()!
    }
}
