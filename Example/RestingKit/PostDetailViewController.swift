//
//  PostDetailViewController.swift
//  RestingKit
//
//  Created by Moray on 2/17/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import RestingKit

class PostDetailViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textView: UITextView!

    var postId: Int!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let request = RestingRequest(endpoint: Endpoints.Posts.get, body: Nothing(), pathVariables: ["post_id": postId])
        JSONPlaceholderClient.shared.perform(request).extractingBody().done {
            self.titleLabel.text = $0.title
            self.textView.text = $0.body
        }.handlingErrors(in: self)
    }

}
