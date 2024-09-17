import Foundation
import UIKit
protocol MovieQuizViewControllerProtocol: UIViewController {
    func show(quiz step: QuizStepViewModel)
    func hightLightImageBorder(isCorrectAnswerReceived: Bool)
    func setLoadingIndicator(visible: Bool)
    func showNetworkError(message: String)
    func changeButtonState(isEnabled: Bool)
    func hideLayerBorders()
}
