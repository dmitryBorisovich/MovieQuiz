import Foundation

protocol AlertPresenterDelegate: AnyObject {
    func createAlertModel() -> AlertModel
}
