//
//  PodcastsSearchController.swift
//  PodcastsApp
//
//  Created by Zinko Viacheslav on 31.03.2019.
//  Copyright © 2019 Zinko Viacheslav. All rights reserved.
//

import UIKit
import Alamofire
// https://affiliate.itunes.apple.com/resources/documentation/itunes-store-web-service-search-api/

class PodcastsSearchController: UITableViewController {
	
	private var podcasts = [
		Podcast(trackName: "Музыка", artistName: "Michael Jackson"),
		Podcast(trackName: "Фонограмма", artistName: "Лорди"),
		Podcast(trackName: "Рассказ", artistName: "Жуки")
	]
	private let cellID = "cellID"
	private let searchController = UISearchController(searchResultsController: nil)
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupSearchBar()
		tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellID")
	}
	
	
	private func setupSearchBar() {
		navigationItem.searchController = searchController
		navigationItem.hidesSearchBarWhenScrolling = false
		searchController.dimsBackgroundDuringPresentation = false
		searchController.searchBar.delegate = self
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return podcasts.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
		
		let podcast = podcasts[indexPath.row]
		cell.textLabel?.text = "\(podcast.trackName ?? "")\n\(podcast.artistName ?? "")"
		cell.textLabel?.numberOfLines = -1 // trix - multilines
		cell.imageView?.image = #imageLiteral(resourceName: "appicon")
		
		return cell
	}
}


extension PodcastsSearchController: UISearchBarDelegate {
	
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		let url = "https://itunes.apple.com/search?term=\(searchText))"
		Alamofire.request(url).responseData {
			(dataResponse) in
			if let error = dataResponse.error {
				print("Error: \(error.localizedDescription)")
				return
			}
			guard let data = dataResponse.data else { return }
			do {
				let decoded = try JSONDecoder().decode(SearchResult.self, from: data)
				self.podcasts = decoded.results
				self.tableView.reloadData()
			}
			catch let err {
				print("Failed to parse", err.localizedDescription)
			}
		}
	}
	
}


struct SearchResult: Decodable {
	let resultCount: Int
	let results: [Podcast]
}
