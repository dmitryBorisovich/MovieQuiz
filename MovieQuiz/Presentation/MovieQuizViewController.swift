import UIKit

final class MovieQuizViewController: UIViewController {
    
    // MARK: - Private Properties
    
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    
    private var alertPresenter: AlertPresentProtocol?
    private var statisticService: StatisticServiceProtocol?
    
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
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        
        statisticService = StatisticService()
        
        alertPresenter = AlertPresenter(delegate: self)
        
        questionFactory?.loadData()
    }
    
    // MARK: - Private Methods
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
    }
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        noButton.isEnabled = false
        yesButton.isEnabled = false
        
        if isCorrect {
            correctAnswers += 1
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrResults()
            self.imageView.layer.borderWidth = 0
            self.noButton.isEnabled = true
            self.yesButton.isEnabled = true
        }
    }
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            let finishedGame = GameResult(
                correct: correctAnswers,
                total: questionsAmount,
                date: Date()
            )
            statisticService?.store(game: finishedGame)
            alertPresenter?.showAlert(with: .result)
        } else {
            currentQuestionIndex += 1
            
            questionFactory?.requestNextQuestion()
        }
    }
    
    private func processAnswer(_ answer: Bool) {
        guard let currentQuestion = currentQuestion else { return }
        showAnswerResult(isCorrect: currentQuestion.correctAnswer == answer)
    }
    
    private func operateLoadingIndicator() {
        activityIndicator.isHidden.toggle()
        activityIndicator.isHidden ? activityIndicator.stopAnimating() : activityIndicator.startAnimating()
    }
    
    private func showNetworkError(message: Error) {
        operateLoadingIndicator()
        alertPresenter?.showAlert(with: .networkError(message))
    }
    
    // MARK: - IB Actions
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        processAnswer(true)
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        processAnswer(false)
    }
}

// MARK: - Extensions

extension MovieQuizViewController: QuestionFactoryDelegate {
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return }
        currentQuestion = question
        let viewModel = convert(model: question)
            
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    func didLoadDataFromServer() {
        operateLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }

    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error)
    }
}


extension MovieQuizViewController: AlertPresenterDelegate {
    
    func createAlertModel(with alertModelType: AlertModelType) -> AlertModel {
        
        switch alertModelType {
            
        case .result:
            let statistic = statisticService ?? StatisticService()
            let result = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: """
                    Ваш результат: \(correctAnswers)/\(questionsAmount)
                    Количество сыгранных квизов: \(statistic.gamesCount)
                    Рекорд: \(statistic.bestGame.correct)/\(questionsAmount) (\(statistic.bestGame.date.dateTimeString))
                    Средняя точность: \(String(format: "%.2f", statistic.totalAccuracy))%
                    """,
                buttonText: "Сыграть еще раз"
            )
            
            return AlertModel(
                title: result.title,
                message: result.text,
                buttonText: result.buttonText
            ) { [weak self] in
                self?.currentQuestionIndex = 0
                self?.correctAnswers = 0
                self?.questionFactory?.requestNextQuestion()
            }
            
        case .networkError(let error):
            return AlertModel(
                title: "Ошибка",
                message: error.localizedDescription,
                buttonText: "Попробовать еще раз"
            ) { [weak self] in
                self?.currentQuestionIndex = 0
                self?.correctAnswers = 0
                self?.questionFactory?.loadData()
            }
        }
    }
}
