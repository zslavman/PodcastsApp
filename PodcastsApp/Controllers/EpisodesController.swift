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
	private var episodes = [Episode]()
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupTableView()
	}
	
	
	private func setupTableView() {
		tableView.register(PodcastCell.self, forCellReuseIdentifier: PodcastCell.cellID)
		tableView.tableFooterView = UIView()
	}
	
	private func fetchEpisodes() {
		guard let url = podcast?.feedUrl else { return }
		
		// add secure for link (http -> https)
		let secureFeedString: String
		if url.contains("https") {
			secureFeedString = url
		}
		else {
			secureFeedString = url.replacingOccurrences(of: "http", with: "https")
		}
		guard let feedUrl = URL(string: secureFeedString) else { return }
		
		let parser = FeedParser(URL: feedUrl)
		parser.parseAsync {
			(result) in
			// How to access a Swift enum associated value outside of a switch statement:
			// variant 1
			//if case .rss(let value) = result { }
			
			// variant 2
			// associative enum value
			switch result {
			case .failure(let error):
				print("Error retrieving data:", error.localizedDescription)
			case .rss(let feed):		// Really Simple Syndication Feed Model
				feed.items?.forEach({
					(feedItem) in
					let episode = Episode(title: feedItem.title ?? "")
					self.episodes.append(episode)
				})
				DispatchQueue.main.async {
					self.tableView.reloadData()
				}
			default:
				print("Found a feed, use another enum value!")
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
