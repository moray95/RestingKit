//
//  Promise+RestingKit.swift
//  RestingKit
//
//  Created by Moray on 2/17/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
import PromiseKit
import RestingKit

extension Promise where T: HTTPResponseType {
    func extractingBody() -> Promise<T.BodyType> {
        return map {
            return $0.body
        }
    }
}

extension Promise {
    @discardableResult
    func handlingErrors(in controller: UIViewController) -> PMKFinalizer {
        return self.catch { [weak controller] error in
            controller?.showError(message: error.localizedDescription)
        }
    }
}
