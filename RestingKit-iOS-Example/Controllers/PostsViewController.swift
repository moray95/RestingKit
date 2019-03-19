//
//  PostsViewController.swift
//  RestingKit
//
//  Created by moray95 on 02/16/2019.
//  Copyright (c) 2019 moray95. All rights reserved.
//

import UIKit
import RestingKit

class PostsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    private var posts = [PostModel]()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        let request = RestingRequest(endpoint: Endpoints.Posts.list, body: Nothing())
        JSONPlaceholderClient.shared.perform(request).extractingBody().done {
            self.posts = $0
            self.tableView.reloadData()
        }.handlingErrors(in: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? PostDetailViewController {
            destination.postId = (sender as! Int)
        }
    }
}

extension PostsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell")!
        cell.textLabel?.text = posts[indexPath.row].title
        return cell
    }
}

extension PostsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = posts[indexPath.row]
        performSegue(withIdentifier: "showPostDetail", sender: post.id)
    }
}
