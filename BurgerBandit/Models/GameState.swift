import Foundation

enum Difficulty: String, CaseIterable {
    case easy
    case medium
    case hard

    var displayName: String {
        switch self {
        case .easy:   return "EASY"
        case .medium: return "MEDIUM"
        case .hard:   return "HARD"
        }
    }

    var guardCount: Int {
        switch self {
        case .easy:   return 1
        case .medium: return 2
        case .hard:   return 3
        }
    }

    var guardBaseSpeed: CGFloat {
        switch self {
        case .easy:   return 120
        case .medium: return 160
        case .hard:   return 200
        }
    }

    var chaseDistance: CGFloat {
        switch self {
        case .easy:   return 160
        case .medium: return 220
        case .hard:   return 320
        }
    }

    // How many foods before each fat stage trigger
    var fatThresholds: [Int] { // [stage1, stage2, stage3]
        switch self {
        case .easy:   return [6, 14, 24]
        case .medium: return [4, 9, 16]
        case .hard:   return [2, 5, 10]
        }
    }

    var healthDamageOnCatch: Int {
        switch self {
        case .easy:   return 15
        case .medium: return 22
        case .hard:   return 30
        }
    }

    var foodSpawnInterval: TimeInterval {
        switch self {
        case .easy:   return 4.0
        case .medium: return 5.5
        case .hard:   return 7.0
        }
    }

    // 0.0 to 1.0 chance a veggie spawns when a food item is chosen
    var vegetableSpawnChance: Double {
        switch self {
        case .easy:   return 0.06
        case .medium: return 0.04
        case .hard:   return 0.02
        }
    }
}

class GameState {
    static let shared = GameState()
    private init() {}

    // Persisted across game start
    var difficulty: Difficulty = .medium
    var selectedRestaurant: RestaurantType = .burgerBarn

    // Per-game state — reset each run
    var score: Int = 0
    var lives: Int = 3
    var health: Int = 100   // 0-100
    var foodEaten: Int = 0  // only junk food counts
    var isInvincible: Bool = false  // after taking damage
    var hasSpeedBoost: Bool = false
    var speedBoostEndTime: TimeInterval = 0

    func reset() {
        score = 0
        lives = 3
        health = 100
        foodEaten = 0
        isInvincible = false
        hasSpeedBoost = false
        speedBoostEndTime = 0
    }

    // Returns 0-3
    var fatStage: Int {
        let thresholds = difficulty.fatThresholds
        if foodEaten >= thresholds[2] { return 3 }
        if foodEaten >= thresholds[1] { return 2 }
        if foodEaten >= thresholds[0] { return 1 }
        return 0
    }

    // 0.0 = no fat, 1.0 = fully obese
    var fatFraction: CGFloat {
        let thresholds = difficulty.fatThresholds
        let maxFood = CGFloat(thresholds[2])
        return min(CGFloat(foodEaten) / maxFood, 1.0)
    }

    // Speed multiplier: 1.0 (slim) → 0.3 (obese), plus boost
    func playerSpeedMultiplier() -> CGFloat {
        let stageSpeeds: [CGFloat] = [1.0, 0.78, 0.55, 0.35]
        var speed = stageSpeeds[fatStage]
        if hasSpeedBoost { speed = min(speed + 0.5, 1.2) }
        return speed
    }

    // Base radius for player drawing (visual)
    func playerRadius() -> CGFloat {
        let stageRadii: [CGFloat] = [20, 25, 30, 36]
        return stageRadii[fatStage]
    }

    // Collision radius — smaller than visual to avoid getting stuck in gaps
    func playerCollisionRadius() -> CGFloat {
        let stageRadii: [CGFloat] = [17, 20, 23, 27]
        return stageRadii[fatStage]
    }

    // Called when player eats food
    func collectFood(_ foodType: FoodType) {
        score += foodType.points
        let newHealth = health + foodType.healthEffect
        health = max(0, min(100, newHealth))
        if foodType.countsAsFatFood {
            foodEaten += 1
        }
    }

    // Called when guard catches the player. Returns true if a life is lost.
    func takeDamage() -> Bool {
        guard !isInvincible else { return false }
        health -= difficulty.healthDamageOnCatch
        if health <= 0 {
            health = 0
            lives -= 1
            health = 60  // reset health for next life (if any)
            return true
        }
        return false
    }

    var isGameOver: Bool { lives <= 0 }
}
