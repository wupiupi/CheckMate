//
//  AlertControllerBuilder.swift
//  CheckMate
//
//  Created by Paul Makey on 21.02.24.
//

import UIKit

final class AlertControllerBuilder {
    private let alertController: UIAlertController
    
    init(title: String, message: String) {
        alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
    }
    
    func addTextField(text: String?, placeholder: String?) -> AlertControllerBuilder {
        alertController.addTextField { textField in
            textField.text = text
            textField.placeholder = placeholder
        }
        return self
    }
    
    func addAction(
        title: String,
        style: UIAlertAction.Style,
        handler: ((String, String) -> Void)? = nil
    ) -> AlertControllerBuilder {
        let action = UIAlertAction(
            title: title,
            style: style) { [unowned alertController] _ in
                guard let title = alertController.textFields?.first?.text,
                      !title.isEmpty else { return }
                
                let note = alertController.textFields?.last?.text
                handler?(title, note ?? "")
            }
        alertController.addAction(action)
        
        return self
    }
    
    func build() -> UIAlertController {
        alertController
    }
}
