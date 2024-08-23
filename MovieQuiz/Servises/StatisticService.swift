import Foundation

 class StatisticService: StatisticServiceProtocol {
    private let storage: UserDefaults = .standard
     private enum Keys: String {
        case correct
        case bestGame
        case gamesCount
        case total
        case date
    }
    
     var totalCorrectAnswers: Int {
         get {
             storage.integer(forKey: "totalCorrectAnswers")
         }
         set {
             storage.set(newValue, forKey: "totalCorrectAnswers")
         }
     }
     
     var totalQuestion: Int {
         get {
             storage.integer(forKey: "totalQuestion")
         }
         set {
             storage.set(newValue, forKey: "totalQuestion")
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
            let correct = storage.integer(forKey: Keys.correct.rawValue)
            let total = storage.integer(forKey: Keys.total.rawValue)
            let date = storage.object(forKey: Keys.date.rawValue) as? Date ?? Date()
            
            return GameResult(correct: correct, total: total, date: date)
        }
        set {
            storage.set(newValue.correct, forKey: Keys.correct.rawValue)
            storage.set(newValue.total, forKey: Keys.total.rawValue)
            storage.set(newValue.date, forKey: Keys.date.rawValue)
        }
    }
    
     var totalAccuracy: Double {
         guard totalQuestion != 0 else { return 0 }
         return Double(totalCorrectAnswers) / Double(totalQuestion) * 100
     }
     
    func store(correct count: Int, total amount: Int) {
        
        guard amount != 0 else { return }
        
        let gameResult = GameResult(correct: count, total: amount, date: Date())
        
        gamesCount += 1
        totalQuestion += amount
        totalCorrectAnswers += count
        
        if gameResult.isBetterThan(bestGame) {
            bestGame = gameResult
        }
    }
}
 

