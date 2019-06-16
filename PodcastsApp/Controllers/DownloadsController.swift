//
//  DownloadsController.swift
//  PodcastsApp
//
//  Created by Zinko Viacheslav on 16.06.2019.
//  Copyright © 2019 Zinko Viacheslav. All rights reserved.
//

import UIKit

class DownloadsController: UITableViewController {
	
	private var downloadedEpArr = UserDefaults.standard.getDownloadedEpisodes()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupTableView()
	}
	
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		downloadedEpArr = UserDefaults.standard.getDownloadedEpisodes()
		tableView.reloadData()
	}
	
	
	private func setupTableView() {
		tableView.tableFooterView = UIView()
		let nib = UINib(nibName: "EpisodeCell", bundle: nil)
		tableView.register(nib, forCellReuseIdentifier: EpisodeCell.cellID)
	}
	
	
	//MARK:- UITableView
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return downloadedEpArr.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: EpisodeCell.cellID, for: indexPath) as! EpisodeCell
		cell.episode = downloadedEpArr[indexPath.row]
		return cell
	}
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 134
	}
	
	
}
