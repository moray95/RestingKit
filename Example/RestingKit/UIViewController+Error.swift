//
//  UIViewController+Error.swift
//  RestingKit
//
//  Created by Moray on 2/17/19.
//  Copyright © 2019 RestingKit. All rights reserved.
//

import UIKit

extension UIViewController {
    func showError(message: String) {
        let alertController = UIAlertController(title: "An error occurred!", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alertController, animated: true)
    }
}
