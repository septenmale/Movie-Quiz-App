import UIKit
import Foundation

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    // MARK: - IB Outlets
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Private Properties
    private var correctAnswers = 0
    private var questionFactory: QuestionFactory?
    private var currentQuestion: QuizQuestion?
    private var alertPresenter: AlertPresenter?
    private var statisticService: StatisticService = StatisticServiceImplementation()
    private let presenter = MovieQuizPresenter()
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewController = self
        imageView.layer.cornerRadius = 20
        questionFactory = QuestionFactoryImplementation(moviesLoader: MoviesLoader(), delegate: self)
        
        questionFactory?.loadData()
        setLoadingIndicator(visible: true)
        
        alertPresenter = AlertPresenter(viewController: self)
    }
    
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        currentQuestion = question
        let viewModel = presenter.convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    // MARK: - IB Actions
    @IBAction private func noButtonClicked(_ sender: Any) {
        presenter.noButtonClicked()
        presenter.currentQuestion = currentQuestion
    }
    
    @IBAction private func yesButtonClicked(_ sender: Any) {
        presenter.yesButtonClicked()
        presenter.currentQuestion = currentQuestion
    }
    
    // MARK: - Private Methods
    func showAnswerResult(isCorrect: Bool) {
        changeButtonState(isEnabled: false)
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.cornerRadius = 20
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        if isCorrect == true {
            correctAnswers += 1
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [ weak self ] in
            guard let self = self else { return }
            self.showNextQuestionOrResults()
        }
    }
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    private func showNextQuestionOrResults() {
        changeButtonState(isEnabled: true)
        imageView.layer.borderWidth = 0
        
        if presenter.isLastQuestion() {
            
            let title = "Этот раунд закончен!"
            
            statisticService.store (
                correct: correctAnswers,
                total: presenter.questionsAmount
            )
            
            let gamesCount = statisticService.gamesCount
            let bestGame = statisticService.bestGame
            let totalAccuracy = statisticService.totalAccuracy
            let message =
"""
Ваш результат: \(correctAnswers)/\(presenter.questionsAmount)
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
                    presenter.resetQuestionIndex()
                    self.correctAnswers = 0
                    self.questionFactory?.requestNextQuestion()
                }
            )
            
            alertPresenter?.showAlert(model: model)
        } else {
            presenter.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
            setLoadingIndicator(visible: false)
        }
    }
    
    private func changeButtonState(isEnabled: Bool) {
        noButton.isEnabled = isEnabled
        yesButton.isEnabled = isEnabled
    }
        
    private func setLoadingIndicator(visible: Bool) {
        activityIndicator.isHidden = !visible
        visible ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
    }
    
   private func showNetworkError(message: String) {
        setLoadingIndicator(visible: false)
        let model = AlertModel(title: "Ошибка",
                               message: "Произошла ошибка",
                               buttonText: "Попробовать ещё раз",
                               completion: { [weak self] in
            guard let self = self else { return }
            
            presenter.resetQuestionIndex()
            self.correctAnswers = 0
            self.questionFactory?.requestNextQuestion()
            questionFactory?.loadData()
        }
        )
        alertPresenter?.showAlert(model: model)
    }
    
    func didLoadDataFromServer() {
        setLoadingIndicator(visible: false)
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
        setLoadingIndicator(visible: true)
    }
    
}
