import Foundation

struct HighScoreEntry: Codable {
    let score: Int
    let difficulty: String
    let restaurant: String
    let fatStage: Int
    let date: Date
}

class HighScoreManager {
    static let shared = HighScoreManager()
    private init() {}

    private let key = "BurgerBanditHighScores"
    private let maxEntries = 20

    var scores: [HighScoreEntry] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let entries = try? JSONDecoder().decode([HighScoreEntry].self, from: data) else {
            return []
        }
        return entries.sorted { $0.score > $1.score }
    }

    func saveScore(score: Int, difficulty: Difficulty, restaurant: RestaurantType, fatStage: Int) {
        let entry = HighScoreEntry(
            score: score,
            difficulty: difficulty.displayName,
            restaurant: restaurant.displayName,
            fatStage: fatStage,
            date: Date()
        )

        var existing = scores
        existing.append(entry)
        existing.sort { $0.score > $1.score }
        if existing.count > maxEntries {
            existing = Array(existing.prefix(maxEntries))
        }

        if let data = try? JSONEncoder().encode(existing) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    var highScore: Int {
        scores.first?.score ?? 0
    }
}
