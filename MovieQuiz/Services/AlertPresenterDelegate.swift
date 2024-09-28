import Foundation

protocol AlertPresenterDelegate: AnyObject {
    func createAlertModel(with alertModelType: AlertModelType) -> AlertModel
}
