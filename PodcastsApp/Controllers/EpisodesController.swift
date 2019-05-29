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
	private var episodes = [Episode]()
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupTableView()
	}
	
	
	private func setupTableView() {
		let nib = UINib(nibName: "EpisodeCell", bundle: nil)
		tableView.register(nib, forCellReuseIdentifier: PodcastCell.cellID)
		tableView.tableFooterView = UIView()
	}
	
	private func fetchEpisodes() {
		guard let urlString = podcast?.feedUrl else { return }
		APIServices.shared.fetchEpisodes(urlString: urlString) {
			(episodesArr) in
			self.episodes = episodesArr
			DispatchQueue.main.async {
				self.tableView.reloadData()
			}
		}
	}
	
	
	//MARK:- UITableView Methods
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return episodes.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: PodcastCell.cellID, for: indexPath) as! EpisodeCell
		cell.episode = episodes[indexPath.row]
		return cell
	}
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 134
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let tabBarVC = UIApplication.shared.keyWindow?.rootViewController as? TabBarController
		tabBarVC?.playerDetailsView.playlist = episodes
		tabBarVC?.maximizePlayer(episode: episodes[indexPath.row])
	}
	
	override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
		let activityIndicatorView = UIActivityIndicatorView(style: .whiteLarge)
		activityIndicatorView.color = .darkGray
		activityIndicatorView.startAnimating()
		return activityIndicatorView
	}
	
	override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return episodes.isEmpty ? 200 : 0
	}
	
	
}
