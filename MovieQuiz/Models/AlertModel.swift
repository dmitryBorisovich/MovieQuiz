import UIKit

struct AlertModel {
    let title: String
    let message: String
    let buttonText: String
    
    let completion: () -> Void
}

enum AlertModelType {
    case result
    case networkError(Error)
}
