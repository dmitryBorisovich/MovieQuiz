import Foundation

struct GameResult {
    let correct: Int
    let total: Int
    var date: Date
    
    func isBetterThan(_ another: GameResult) -> Bool {
        correct > another.correct
    }
}
