//
//  EpisodesController.swift
//  PodcastsApp
//
//  Created by Zinko Viacheslav on 09.05.2019.
//  Copyright © 2019 Zinko Viacheslav. All rights reserved.
//

import UIKit
import FeedKit

class EpisodesController: UITableViewController {
	
	public var podcast: Podcast? {
		didSet {
			guard let safePodcast = podcast else { return }
			navigationItem.title = safePodcast.trackName
			fetchEpisodes()
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
	
	private func fetchEpisodes() {
		guard let url = podcast?.feedUrl, let feedUrl = URL(string: url) else { return }
		let parser = FeedParser(URL: feedUrl)
		parser.parseAsync {
			(result) in
			print("sucess = ", result.isSuccess)
			
			switch result {
			case let .atom(feed):       // Atom Syndication Format Feed Model
			case let .rss(feed):        // Really Simple Syndication Feed Model
			case let .json(feed):       // JSON Feed Model
			case let .failure(error):
			}
		}
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
