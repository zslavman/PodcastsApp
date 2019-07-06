//
//  DownloadsController.swift
//  PodcastsApp
//
//  Created by Zinko Viacheslav on 16.06.2019.
//  Copyright © 2019 Zinko Viacheslav. All rights reserved.
//

import UIKit
import MediaPlayer

class DownloadsController: UIViewController {
	
	private var downloadedEpArr = UserDefaults.standard.getDownloadedEpisodes()
	private var placeholder: PlaceholderView!
	private var tableView: UITableView = UITableView(frame: .zero, style: .plain)
	
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .white
		setupEmty()
		setupTableView()
		setupObservers()
		
//		let volumeView = MPVolumeView(frame: CGRect(x: 100, y: 100, width: 100, height: 100))
//		volumeView.backgroundColor = .red
//		volumeView.isHidden = false
//		volumeView.alpha = 0.8
//		view.addSubview(volumeView)
	}
	
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		downloadedEpArr = UserDefaults.standard.getDownloadedEpisodes()
		tableView.reloadData()
	}
	
	
	private func setupTableView() {
		tableView.delegate = self
		tableView.dataSource = self
		tableView.tableFooterView = UIView()
		let nib = UINib(nibName: "EpisodeCell", bundle: nil)
		tableView.register(nib, forCellReuseIdentifier: EpisodeCell.cellID)
		
		view.insertSubview(tableView, belowSubview: placeholder)
		tableView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
			tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
			tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
		])
	}
	
	
	/// configure empty collectionView
	private func setupEmty() {
		placeholder = PlaceholderView(img: #imageLiteral(resourceName: "placeholder_downloads"), title: "Нет файлов")
		view.addSubview(placeholder)
	}
	
	
	private func setupObservers() {
		NotificationCenter.default.addObserver(self, selector: #selector(handleNotifProgress), name: .podLoadingProgress, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(handleLoadComplete), name: .downloadComplete, object: nil)
	}
	
	
	@objc private func handleNotifProgress(notif: Notification) {
		guard let userInfo = notif.userInfo as? [String: Any] else { return }
		guard let progress = userInfo["progress"] as? Double else { return }
		guard let title = userInfo["title"] as? String else { return }
//		guard let row = downloadedEpArr.firstIndex(where: {$0.title == title}) else { return }
//		guard let cell = tableView.cellForRow(at: IndexPath(row: row, section: 0)) as? EpisodeCell else { return }
		let visibleCells = tableView.visibleCells as! [EpisodeCell]
		visibleCells.forEach {
			(cell) in
			if cell.episode.fileUrl == nil {
				if cell.titleLabel.text == title {
					cell.progressBar.progress = Float(progress)
					cell.progressBar.isHidden = false
					cell.episodeImageView.alpha = 0.25
				}
			}
			else {
				cell.progressBar.isHidden = true
				cell.episodeImageView.alpha = 1
			}
		}
	}
	
	
	@objc private func handleLoadComplete(notif: Notification) {
		guard let epLoadCompl = notif.object as? APIServices.EpisodeDownloadCompleteTuple else { return }
		guard let index = downloadedEpArr.firstIndex(where: {$0.title == epLoadCompl.episodeTitle}) else { return }
		downloadedEpArr[index].fileUrl = epLoadCompl.fileUrl
		guard let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? EpisodeCell else { return }
		DispatchQueue.main.async {
			cell.progressBar.isHidden = true
			cell.episodeImageView.alpha = 1
		}
	}
}


//MARK:- UITableView
extension DownloadsController: UITableViewDelegate, UITableViewDataSource {
	
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if downloadedEpArr.count == 0 {
			tableView.alwaysBounceVertical = false
			placeholder.isHidden = false
		}
		else {
			tableView.alwaysBounceVertical = true
			placeholder.isHidden = true
		}
		return downloadedEpArr.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: EpisodeCell.cellID, for: indexPath) as! EpisodeCell
		cell.episode = downloadedEpArr[indexPath.row]
		return cell
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 134
	}
	
	func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
		let delAction = UITableViewRowAction(style: .destructive, title: "Удалить") {
			(action, indexPath) in
			self.downloadedEpArr.remove(at: indexPath.row)
			UserDefaults.standard.saveEpisode(episodes: self.downloadedEpArr, addOperation: false)
			self.tableView.deleteRows(at: [indexPath], with: .automatic)
		}
		return [delAction]
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let selected = downloadedEpArr[indexPath.row]
		if selected.fileUrl == nil {
			let actionSheetVC = UIAlertController(title: "Ошибка!", message: "Невозможно найти локальный файл. Запустить  онлайн стрим?", preferredStyle: .actionSheet)
			let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
			let okAction = UIAlertAction(title: "OK", style: .default) {
				(action) in
				UIApplication.tabBarVC()?.maximizePlayer(episode: selected, playlist: self.downloadedEpArr)
			}
			actionSheetVC.addAction(okAction)
			actionSheetVC.addAction(cancelAction)
			present(actionSheetVC, animated: true)
		}
		else {
			UIApplication.tabBarVC()?.maximizePlayer(episode: selected, playlist: downloadedEpArr)
		}
		tableView.deselectRow(at: indexPath, animated: true)
	}
	
}
