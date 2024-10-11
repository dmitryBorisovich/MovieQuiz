import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    
    // MARK: - Private Properties
    
    private var alertPresenter: AlertPresentProtocol?
    private var presenter: MovieQuizPresenter!
    
    // MARK: - IB Outlets
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        alertPresenter = AlertPresenter(delegate: self)
        presenter = MovieQuizPresenter(viewController: self)
    }
    
    // MARK: - Internal Methods
    
    func operateLoadingIndicator() {
        activityIndicator.isHidden.toggle()
        activityIndicator.isHidden ? activityIndicator.stopAnimating() : activityIndicator.startAnimating()
    }
    
    func showNetworkError(message: Error) {
        operateLoadingIndicator()
        requestAlertPresentation(for: .networkError(message))
    }
    
    func show(quiz step: QuizStepViewModel) {
        imageView.layer.borderColor = UIColor.clear.cgColor
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        noButton.isEnabled = true
        yesButton.isEnabled = true
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        noButton.isEnabled = false
        yesButton.isEnabled = false
    }
    
    // MARK: - IB Actions
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }
}

// MARK: - Extensions

extension MovieQuizViewController: AlertPresenterDelegate {
    
    func requestAlertPresentation(for alertModelType: AlertModelType) {
        alertPresenter?.showAlert(with: alertModelType)
    }
    
    func createAlertModel(with alertModelType: AlertModelType) -> AlertModel {
        
        switch alertModelType {
            
        case .result:
            let result = presenter.makeResultMessage()
            
            return AlertModel(
                title: result.title,
                message: result.text,
                buttonText: result.buttonText
            ) { [weak self] in
                self?.presenter.restartGame()
            }
            
        case .networkError(let error):
            return AlertModel(
                title: "Ошибка",
                message: error.localizedDescription,
                buttonText: "Попробовать еще раз"
            ) { [weak self] in
                self?.presenter.reloadData()
            }
            
        case .imageFail:
            return AlertModel(
                title: "Что-то пошло не так",
                message: "Не удалось загрузить изображение",
                buttonText: "Попробовать еще раз"
            ) { [weak self] in
                self?.presenter.restartGame()
            }
        case .incorrectData:
            return AlertModel(
                title: "Ошибка",
                message: "Данные с сервера не удалось корректно обработать",
                buttonText: "Попробовать еще раз"
            ) { [weak self] in
                self?.presenter.reloadData()
            }
        }
    }
}

