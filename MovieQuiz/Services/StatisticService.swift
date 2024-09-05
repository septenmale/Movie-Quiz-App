import Foundation

 class StatisticServiceImplementation: StatisticService {
     private let storage: UserDefaults = .standard
     
     private enum Keys: String {
         case totalCorrectAnswers
         case totalQuestion
         case gamesCount
     }
     
     private enum bestGameKeys: String{
         case correct
         case total
         case date
     }
     
     var totalCorrectAnswers: Int {
         get {
             storage.integer(forKey: Keys.totalCorrectAnswers.rawValue)
         }
         set {
             storage.set(newValue, forKey: Keys.totalCorrectAnswers.rawValue)
         }
     }
     
     var totalQuestion: Int {
         get {
             storage.integer(forKey: Keys.totalQuestion.rawValue)
         }
         set {
             storage.set(newValue, forKey: Keys.totalQuestion.rawValue)
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
            let correct = storage.integer(forKey: bestGameKeys.correct.rawValue)
            let total = storage.integer(forKey: bestGameKeys.total.rawValue)
            let date = storage.object(forKey: bestGameKeys.date.rawValue) as? Date ?? Date()
            
            return GameResult(correct: correct, total: total, date: date)
        }
        set {
            storage.set(newValue.correct, forKey: bestGameKeys.correct.rawValue)
            storage.set(newValue.total, forKey: bestGameKeys.total.rawValue)
            storage.set(newValue.date, forKey: bestGameKeys.date.rawValue)
        }
    }
    
     var totalAccuracy: Double {
         guard totalQuestion != 0 else { return 0 }
         return Double(totalCorrectAnswers) / Double(totalQuestion) * 100
     }
     
    func store(correct count: Int, total amount: Int) {
        
        gamesCount += 1
        totalQuestion += amount
        totalCorrectAnswers += count
        
        guard amount != 0 else { return }
        
        let gameResult = GameResult(correct: count, total: amount, date: Date())
        
        if gameResult.isBetterThan(bestGame) {
            bestGame = gameResult
        }
    }
}
 

