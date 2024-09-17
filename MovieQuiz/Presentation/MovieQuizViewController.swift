import UIKit
import Foundation

final class MovieQuizViewController: UIViewController {
    
    // MARK: - IB Outlets
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Private Properties
    private var alertPresenter: AlertPresenter?
//    private var statisticService: StatisticService = StatisticServiceImplementation() // wtage 8 
    private var presenter: MovieQuizPresenter!
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = MovieQuizPresenter(viewController: self)
        alertPresenter = AlertPresenter(viewController: self)
        setLoadingIndicator(visible: true)
        
        imageView.layer.cornerRadius = 20
        
//        questionFactory = QuestionFactoryImplementation(moviesLoader: MoviesLoader(), delegate: self)
//        questionFactory?.loadData()
        
    }
    
    // MARK: - IB Actions
    @IBAction private func noButtonClicked(_ sender: Any) {
        presenter.noButtonClicked()
    }
    
    @IBAction private func yesButtonClicked(_ sender: Any) {
        presenter.yesButtonClicked()
    }
    
    // MARK: - Private Methods
    func showAnswerResult(isCorrect: Bool) {
        changeButtonState(isEnabled: false)
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.cornerRadius = 20
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
//        if (isCorrect) == true {
//            correctAnswers += 1
//        }
        presenter.didAnswerCorrectly(isCorrectAnswer: isCorrect)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [ weak self ] in
            guard let self = self else { return }
            self.presenter.showNextQuestionOrResults()
        }
    }
    
    func hideLayerBorders() {
        imageView.layer.borderWidth = 0
    }

    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    private func showNextQuestionOrResults() {
        self.presenter.showNextQuestionOrResults()
        
    }
    
    func changeButtonState(isEnabled: Bool) {
        noButton.isEnabled = isEnabled
        yesButton.isEnabled = isEnabled
    }
        
    func setLoadingIndicator(visible: Bool) {
        activityIndicator.isHidden = !visible
        visible ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
    }
    
   func showNetworkError(message: String) {
        setLoadingIndicator(visible: false)
        let model = AlertModel(title: "Ошибка",
                               message: "Произошла ошибка",
                               buttonText: "Попробовать ещё раз",
                               completion: { [weak self] in
            guard let self = self else { return }
            
            presenter.restartGame()
            self.presenter.questionFactory?.loadData()
        }
        )
        alertPresenter?.showAlert(model: model)
    }
    
//    func didLoadDataFromServer() {
//        setLoadingIndicator(visible: false)
//        questionFactory?.requestNextQuestion()
//    }
    
//    func didFailToLoadData(with error: Error) {
//        showNetworkError(message: error.localizedDescription)
//        setLoadingIndicator(visible: true)
//    }
    //    func didReceiveNextQuestion(question: QuizQuestion?) {
    //        presenter.didReceiveNextQuestion(question: question)
    //    }
    
}
