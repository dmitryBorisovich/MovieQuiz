import Foundation

class StatisticService: StatisticServiceProtocol {
    
    private let storage: UserDefaults = .standard
    
    private enum Keys: String {
        case correctAnswers
        case bestGameCorrect
        case bestGameTotal
        case bestGameDate
        case gamesCount
    }
    
    private var correctAnswers: Int {
        get {
            storage.integer(forKey: Keys.correctAnswers.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.correctAnswers.rawValue)
        }
    }
    
    var gamesCount: Int {
        get {
            storage.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    var bestGame: GameResult {
        get {
            let gameCorrect = storage.integer(forKey: Keys.bestGameCorrect.rawValue)
            let gameTotal = storage.integer(forKey: Keys.bestGameTotal.rawValue)
            let gameDate = storage.object(forKey: Keys.bestGameDate.rawValue) as? Date ?? Date()
            
            return GameResult(correct: gameCorrect, total: gameTotal, date: gameDate)
        }
        set(newValue) {
            storage.set(newValue.correct, forKey: Keys.bestGameCorrect.rawValue)
            storage.set(newValue.total, forKey: Keys.bestGameTotal.rawValue)
            storage.set(newValue.date, forKey: Keys.bestGameDate.rawValue)
        }
    }
    
    var totalAccuracy: Double {
        guard gamesCount > 0 else { return 0 }
        return 100 * Double(correctAnswers) / (10 * Double(gamesCount))
    }
    
    func store(game: GameResult) {
        correctAnswers += game.correct
        gamesCount += 1
        
        if game.isBetterThan(bestGame) {
            bestGame = game
        }
    }
}
