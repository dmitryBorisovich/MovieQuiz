import UIKit

final class AlertPresenter: AlertPresentProtocol {
    
    weak var delegate: AlertPresenterDelegate?
    
    init(delegate: AlertPresenterDelegate?) {
        self.delegate = delegate
    }
    
    func showAlert(with alertModelType: AlertModelType) {
        guard let alertModel = delegate?.createAlertModel(with: alertModelType),
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

