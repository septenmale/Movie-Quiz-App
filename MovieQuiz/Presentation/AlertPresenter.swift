import UIKit

final class AlertPresenter {
    weak var vievController: UIViewController?
    
    init(vievController: UIViewController) {
        self.vievController = vievController
    }
    
    func showAlert (model: AlertModel) {
        let alert = UIAlertController(
            title: model.title,
            message: model.message,
            preferredStyle: .alert)
        let action = UIAlertAction(title: model.buttonText, style: .default) {
           _ in model.completion()
        }
        alert.addAction(action)
        vievController?.present(alert, animated: true, completion: nil)
    }
}
