import UIKit

class AlertPresenter: AlertPresentProtocol {
    
    weak var delegate: AlertPresenterDelegate?
    
    func showAlert() {
        guard let alertModel = delegate?.createAlertModel(),
              let viewController = delegate as? UIViewController
        else { return }
        
        let alert = UIAlertController(title: alertModel.title,
                                      message: alertModel.message,
                                      preferredStyle: .alert)
        
        let action = UIAlertAction(title: alertModel.buttonText, style: .default) { _ in alertModel.completion() }
        
        alert.addAction(action)
        
        viewController.present(alert, animated: true)
    }
}

