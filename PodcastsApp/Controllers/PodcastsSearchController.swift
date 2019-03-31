//
//  PodcastsSearchController.swift
//  PodcastsApp
//
//  Created by Zinko Viacheslav on 31.03.2019.
//  Copyright © 2019 Zinko Viacheslav. All rights reserved.
//

import UIKit

class PodcastsSearchController: UITableViewController {
	
	private let podcasts = [
		Podcast(name: "Музыка", artistName: "Michael Jackson"),
		Podcast(name: "Фонограмма", artistName: "Лорди"),
		Podcast(name: "Рассказ", artistName: "Жуки")
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
		cell.textLabel?.text = "\(podcast.name)\n\(podcast.artistName)"
		cell.textLabel?.numberOfLines = -1 // trix - multilines
		cell.imageView?.image = #imageLiteral(resourceName: "appicon")
		
		return cell
	}
}


extension PodcastsSearchController: UISearchBarDelegate {
	
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		print(searchText)
		//TODO: implement Alamofire for search iTunes API
	}
	
}
