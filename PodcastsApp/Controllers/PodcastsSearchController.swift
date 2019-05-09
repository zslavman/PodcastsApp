//
//  PodcastsSearchController.swift
//  PodcastsApp
//
//  Created by Zinko Viacheslav on 31.03.2019.
//  Copyright © 2019 Zinko Viacheslav. All rights reserved.
//
// affiliate.itunes.apple.com/resources/documentation/itunes-store-web-service-search-api/

import UIKit

class PodcastsSearchController: UITableViewController {
	
	private var podcasts = [Podcast]()
	private let searchController = UISearchController(searchResultsController: nil)
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupTable()
		setupSearchBar()
	}
	
	private func setupTable() {
		tableView.tableFooterView = UIView()
		let nib = UINib(nibName: "PodcastCell", bundle: nil)
		tableView.register(nib, forCellReuseIdentifier: PodcastCell.cellID)
	}
	
	private func setupSearchBar() {
		definesPresentationContext = true // fix for didSelectRow, fix black screen-crash
		navigationItem.searchController = searchController
		navigationItem.hidesSearchBarWhenScrolling = false
		searchController.dimsBackgroundDuringPresentation = false
		searchController.searchBar.delegate = self
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return podcasts.count
	}
	
	override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let label = UILabel()
		label.text = "Введите условия поиска"
		label.textColor = .lightGray
		label.textAlignment = .center
		label.font = UIFont.boldSystemFont(ofSize: 18)
		return label
	}
	
	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		if podcasts.count == 0 {
			return 250
		}
		return 0
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: PodcastCell.cellID, for: indexPath) as! PodcastCell
		cell.podcast = podcasts[indexPath.row]
		//let podcast = podcasts[indexPath.row]
		//cell.textLabel?.text = "\(podcast.trackName ?? "")\n\(podcast.artistName ?? "")"
		//cell.textLabel?.numberOfLines = -1 // trix - multilines
		//cell.imageView?.image = #imageLiteral(resourceName: "appicon")
		return cell
	}
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 132
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let episodesVC = EpisodesController()
		episodesVC.podcast = podcasts[indexPath.row]
		navigationController?.pushViewController(episodesVC, animated: true)
		
	}
}


extension PodcastsSearchController: UISearchBarDelegate {
	
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		AlamofireService.shared.fetchPodcasts(searchText: searchText) {
			[weak self] (podcasts) in
			guard let strongSelf = self else { return }
			strongSelf.podcasts = podcasts
			DispatchQueue.main.async {
				strongSelf.tableView.reloadData()
			}
		}
	}
	
}


struct SearchResult: Decodable {
	let resultCount: Int
	let results: [Podcast]
}
