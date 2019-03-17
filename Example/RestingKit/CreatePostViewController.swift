//
//  CreatePostViewController.swift
//  RestingKit
//
//  Created by Moray on 2/17/19.
//  Copyright © 2019 RestingKit. All rights reserved.
//

import UIKit
import RestingKit

class CreatePostViewController: UIViewController {
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var bodyTextView: UITextView!


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? PostDetailViewController {
            destination.postId = (sender as! Int)
        }
    }

    @IBAction func createPost() {
        guard let title = titleTextField.text, let body = bodyTextView.text else {
            showError(message: "Please fill the title and body!")
            return
        }
        let createModel = PostCreateModel(userId: 1, title: title, body: body)
        let request = RestingRequest(endpoint: Endpoints.Posts.create, body: createModel)
        JSONPlaceholderClient.shared.perform(request).extractingBody().done { _ in 
            self.navigationController?.popViewController(animated: true)
        }.handlingErrors(in: self)
    }
}
