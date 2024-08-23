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
         get {
             storage.double(forKey: "totalAccuracy")
         }
         set { 
             storage.set(newValue, forKey: "totalAccuracy")
         }
     }
     
    func store(correct count: Int, total amount: Int) {
        let previousCorrect = storage.integer(forKey: Keys.correct.rawValue)
        let previousTotal = storage.integer(forKey: Keys.total.rawValue)
        let previousGameCount = storage.integer(forKey: Keys.gamesCount.rawValue)
        let newBestGame = GameResult(correct: count, total: amount, date: Date())
        let correct = storage.integer(forKey: Keys.correct.rawValue)
        let total = storage.integer(forKey: Keys.total.rawValue)
        
        
        if total != 0 {
            totalAccuracy = (Double(correct) / Double(total)) * 100.0
        }
        else { totalAccuracy = 0 }
        
        storage.set(previousCorrect + count, forKey: Keys.correct.rawValue)
        storage.set(previousTotal + amount, forKey: Keys.total.rawValue)
        storage.set(previousGameCount + 1, forKey: Keys.gamesCount.rawValue)
        
        if newBestGame.correct > bestGame.correct {
            bestGame = newBestGame
        }
    }
}
 

