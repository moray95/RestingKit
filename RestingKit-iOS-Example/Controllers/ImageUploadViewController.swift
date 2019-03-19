//
//  ImageUploadViewController.swift
//  RestingKit_Example
//
//  Created by Moray on 2/23/19.
//  Copyright © 2019 RestingKit. All rights reserved.
//

import UIKit
import RestingKit

class ImageUploadViewController: UIViewController {

    private var imageURL: URL?
    @IBOutlet weak var statusLabel: UILabel!

    @IBAction func selectImage() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        present(picker, animated: true)
    }

    @IBAction func uploadImage() {
        guard let imageURL = imageURL else { return }
        let model = ImageUploadModel(imageURL: imageURL)
        let request = RestingRequest(endpoint: Endpoints.Images.upload, body: model)
        ImageServerClient.shared.upload(request).progress {
            print($0.fractionCompleted)
        }.asVoid().done{
            print("Done!")
        }.handlingErrors(in: self)
    }
}

extension ImageUploadViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        imageURL = info[UIImagePickerController.InfoKey.imageURL] as? URL
        if imageURL != nil {
            statusLabel.text = "Image selected"
        }
    }
}
