import Foundation
import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    var correctAnswers: Int = 0
    var currentQuestion: QuizQuestion?
    private let statisticService: StatisticService! // recntly changed
    var alertPresenter: AlertPresenter?
    private weak var viewController: MovieQuizViewController?
    var questionFactory: QuestionFactory?
    
    init(viewController: MovieQuizViewController) {
        self.viewController = viewController
        
        statisticService = StatisticServiceImplementation() // recently added
        
        questionFactory = QuestionFactoryImplementation(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        alertPresenter = AlertPresenter(viewController: viewController)
        viewController.setLoadingIndicator(visible: true)
    }
    
    // MARK: - QuestionFactoryDelegate
    func didLoadDataFromServer() {
        viewController?.setLoadingIndicator(visible: false)
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        let message = error.localizedDescription
        viewController?.showNetworkError(message: message)
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = isYes
        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    func didAnswerCorrectly(isCorrectAnswer: Bool) {
        if isCorrectAnswer == true {
            correctAnswers += 1 }
    }
    
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    func showNextQuestionOrResults() {
        self.viewController?.hideLayerBorders()
        viewController?.changeButtonState(isEnabled: true)
        
        if self.isLastQuestion() {
            
            let title = "Этот раунд закончен!"
            
            statisticService.store (
                correct: self.correctAnswers,
                total: self.questionsAmount
            )
            
            let gamesCount = statisticService.gamesCount
            let bestGame = statisticService.bestGame
            let totalAccuracy = statisticService.totalAccuracy
            let message =
"""
Ваш результат: \(self.correctAnswers)/\(self.questionsAmount)
Количество сыгранных квизов: \(gamesCount)
Ваш рекорд: \(bestGame.correct)/\(bestGame.total) \(bestGame.date.dateTimeString)
Средняя точность: \(String(format: "%.2f", totalAccuracy))%
"""
            let model = AlertModel(
                title: title,
                message: message,
                buttonText: "Сыграть ещё раз",
                completion: { [weak self] in
                    guard let self = self else { return }
                    self.restartGame()
                    self.questionFactory?.requestNextQuestion()
                    viewController?.setLoadingIndicator(visible: false)
                }
            )
            
            alertPresenter?.showAlert(model: model)
        } else {
            self.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
            print(currentQuestionIndex)
        
        }
    }
    
}
