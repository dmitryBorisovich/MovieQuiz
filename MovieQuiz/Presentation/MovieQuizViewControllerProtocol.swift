import Foundation

protocol MovieQuizViewControllerProtocol: AnyObject {
    
    func operateLoadingIndicator()
    
    func showNetworkError(message: Error)
    
    func show(quiz step: QuizStepViewModel)
    
    func highlightImageBorder(isCorrectAnswer: Bool)
    
    func requestAlertPresentation(for alertModelType: AlertModelType)
}
