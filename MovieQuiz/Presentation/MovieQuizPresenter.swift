import UIKit

final class MovieQuizPresenter {
    
    // MARK: - Private Properties
    
    private var questionFactory: QuestionFactoryProtocol?
    
    private var statisticService: StatisticServiceProtocol?
    
    private weak var viewController: MovieQuizViewController?
    
    private let questionsAmount = 10
    
    private var currentQuestionIndex = 0
    private var currentQuestion: QuizQuestion?
    private var correctAnswers = 0
    
    // MARK: - Initialization
    
    init(viewController: MovieQuizViewController) {
        self.viewController = viewController
        
        statisticService = StatisticService()
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        
        questionFactory?.loadData()
    }
    
    
    // MARK: - Internal Methods
    
    func yesButtonClicked() {
        processAnswer(true)
    }
    
    func noButtonClicked() {
        processAnswer(false)
    }
    
    func makeResultMessage() -> QuizResultsViewModel {
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
        
        return result
    }
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        
        questionFactory?.requestNextQuestion()
    }
    
    func reloadData() {
        currentQuestionIndex = 0
        correctAnswers = 0
        
        questionFactory?.loadData()
    }
    
    // MARK: - Private Methods
    
    private func showNetworkError(message: Error) {
        viewController?.operateLoadingIndicator()
        viewController?.requestAlertPresentation(for: .networkError(message))
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
    }
    
    private func didAnswer(isCorrectAnswer: Bool) {
        if isCorrectAnswer {
            correctAnswers += 1
        }
    }
    
    private func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    private func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    private func processAnswer(_ answer: Bool) {
        guard let currentQuestion = currentQuestion else { return }
        proceedWithAnswer(isCorrect: currentQuestion.correctAnswer == answer)
    }
    
    private func proceedWithAnswer(isCorrect: Bool) {
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
        
        didAnswer(isCorrectAnswer: isCorrect)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self else { return }
            self.proceedToNextQuestionOrResults()
        }
    }
    
    private func proceedToNextQuestionOrResults() {
        if self.isLastQuestion() {
            let finishedGame = GameResult(
                correct: correctAnswers,
                total: self.questionsAmount,
                date: Date()
            )
            statisticService?.store(game: finishedGame)
            viewController?.requestAlertPresentation(for: .result)
        } else {
            questionFactory?.requestNextQuestion()
            self.switchToNextQuestion()
        }
    }
}

// MARK: - Extensions

extension MovieQuizPresenter: QuestionFactoryDelegate {
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return }
        currentQuestion = question
        let viewModel = convert(model: question)
            
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    func didLoadDataFromServer() {
        viewController?.operateLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didLoadIncorrectData() {
        viewController?.requestAlertPresentation(for: .incorrectData)
    }

    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error)
    }
    
    func didFailToLoadImage() {
        viewController?.requestAlertPresentation(for: .imageFail)
    }
}
