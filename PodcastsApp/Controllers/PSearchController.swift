//
//  PodcastsSearchController.swift
//  PodcastsApp
//
//  Created by Zinko Viacheslav on 31.03.2019.
//  Copyright © 2019 Zinko Viacheslav. All rights reserved.
//
// affiliate.itunes.apple.com/resources/documentation/itunes-store-web-service-search-api/

import UIKit

class PSearchController: UITableViewController {
	
	private var podcasts = [Podcast]()
	private let searchController = UISearchController(searchResultsController: nil)
	private var timer: Timer?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		tableView.keyboardDismissMode = .interactive
		setupTable()
		setupSearchBar()
		searchBar(searchController.searchBar, textDidChange: "loung") // set default search phrase
		//navigationController?.hidesBarsOnSwipe = true
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

	override func scrollViewDidScroll(_ scrollView: UIScrollView) {
		if scrollView.panGestureRecognizer.translation(in: scrollView).y < 0 {
			UIApplication.tabBarVC()?.setTabBar(hidden: true)
			self.navigationController?.navigationBar.prefersLargeTitles = false
		}
		else {
			UIApplication.tabBarVC()?.setTabBar(hidden: false)
			self.navigationController?.navigationBar.prefersLargeTitles = true
		}
	}
	
	
	//MARK:- UITableView methods
	
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
		return cell
	}
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 132
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let episodesVC = EpisodesController()
		episodesVC.podcast = podcasts[indexPath.row]
		UIApplication.tabBarVC()?.setTabBar(hidden: false)
		navigationController?.pushViewController(episodesVC, animated: true)
	}
}


extension PSearchController: UISearchBarDelegate {
	
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		// fix flickering results on each letter inputs
		timer?.invalidate()
		timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: {
			(_) in
			APIServices.shared.fetchPodcasts(searchText: searchText) {
				[weak self] (podcasts) in
				guard let strongSelf = self else { return }
				strongSelf.podcasts = podcasts
				DispatchQueue.main.async {
					strongSelf.tableView.reloadData()
				}
			}
		})
	}
	
	
}


