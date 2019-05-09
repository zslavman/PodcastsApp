//
//  EpisodesController.swift
//  PodcastsApp
//
//  Created by Zinko Viacheslav on 09.05.2019.
//  Copyright © 2019 Zinko Viacheslav. All rights reserved.
//

import UIKit

class EpisodesController: UITableViewController {
	
	public var podcast: Podcast? {
		didSet {
			guard let safePodcast = podcast else { return }
			navigationItem.title = safePodcast.trackName
			print("feedURL = \(safePodcast.feedUrl ?? "")")
		}
	}
	private struct Episode {
		let title: String
	}
	private var episodes = [
		Episode(title: "01111"),
		Episode(title: "222"),
		Episode(title: "333"),
	]
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupTableView()
	}
	
	
	private func setupTableView() {
		tableView.register(PodcastCell.self, forCellReuseIdentifier: PodcastCell.cellID)
		tableView.tableFooterView = UIView()
	}
	
	
	//MARK:- UITableView Methods
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return episodes.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: PodcastCell.cellID, for: indexPath) as! PodcastCell
		cell.textLabel?.text = episodes[indexPath.row].title
		return cell
	}
	
	
}
