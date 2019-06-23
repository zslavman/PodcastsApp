//
//  EpisodesController.swift
//  PodcastsApp
//
//  Created by Zinko Viacheslav on 09.05.2019.
//  Copyright © 2019 Zinko Viacheslav. All rights reserved.
//
import UIKit
import FeedKit

class EpisodesController: UITableViewController, UIGestureRecognizerDelegate {
	
	public var podcast: Podcast? {
		didSet {
			guard let safePodcast = podcast else { return }
			navigationItem.title = safePodcast.trackName
			fetchEpisodes()
			podcastsArray = UserDefaults.standard.fetchFavorites()
		}
	}
	private var episodes = [Episode]()
	private var podcastsArray = [Podcast]()
	internal var flyingView: UIImageView!

	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupTableView()
		setupNavBar()
	}
	
	override func scrollViewDidScroll(_ scrollView: UIScrollView) {
		if scrollView.panGestureRecognizer.translation(in: scrollView).y < 0 {
			UIApplication.tabBarVC()?.setTabBar(hidden: true)
		}
		else {
			UIApplication.tabBarVC()?.setTabBar(hidden: false)
		}
	}
	
	
	private func setupNavBar() {
		let savedPodcasts = UserDefaults.standard.fetchFavorites()
		guard let podcast = podcast else { return }
		if savedPodcasts.contains(podcast) {
			navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "heart"), style: .plain, target: nil, action: nil)
		}
		else {
			navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "heart"), style: .plain, target: self, action: #selector(onLikeClick))
			navigationItem.rightBarButtonItem?.tintColor = UIColor.clear.withAlphaComponent(0.1)
		}
	}
	
	
	/// save favorite into persistance storage
	@objc private func onLikeClick(sender: UIBarButtonItem) {
		guard let podcast = podcast else { return }
		if podcastsArray.contains(podcast) { return }
		podcastsArray.append(podcast)
		// transform podcast into Data
		let data = NSKeyedArchiver.archivedData(withRootObject: podcastsArray)
		UserDefaults.standard.set(data, forKey: "favPodKey")
		// update button appearance
		navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "heart"), style: .plain, target: nil, action: nil)
		// animation
		guard let originView = sender.value(forKey: "view") as? UIView else { return }
		let globalCoords = originView.convert(CGPoint.zero, to: nil)

		let img = UIImageView(image: #imageLiteral(resourceName: "heart"))
		img.tintColor = .blue
		flyingAnimation(fromPoint: globalCoords, toTabBarItemNo: 1, img: img)
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
	
	
	private func prepareToFlightAnim(fromSender: UIView, indexPath: IndexPath, toTabBarItemNo: Int) {
		let startPoint = fromSender.convert(CGPoint.zero, to: nil) // convert to global coords
		// get image from clicked cell
		guard let cell = tableView.cellForRow(at: indexPath) as? EpisodeCell else { return }
		guard let img = cell.episodeImageView else { return }
		
		// create copy of image, otherwise you will use image from cell
		guard let cgImage = img.image?.cgImage?.copy() else { return }
		let newImage = UIImageView(image: UIImage(cgImage: cgImage))
		
		newImage.layer.cornerRadius = 16
		newImage.layer.masksToBounds = true
		newImage.alpha = 0.8
		newImage.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
		
		flyingAnimation(fromPoint: startPoint, toTabBarItemNo: toTabBarItemNo, img: newImage)
	}
	
	
	/// Picture flight to tabBar animation
	private func flyingAnimation(fromPoint: CGPoint, toTabBarItemNo: Int, img: UIImageView) {
		guard let window = UIApplication.shared.keyWindow else { return }
		let animation = CAKeyframeAnimation(keyPath: "position")// don't edit string - it's a key!
		animation.delegate = self
		animation.path = customPath(startPoint: fromPoint, toPointtoTabBarItemNo: toTabBarItemNo).cgPath
		animation.duration = 0.7
		animation.fillMode = CAMediaTimingFillMode.backwards
		animation.isRemovedOnCompletion = true
		animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
		let animID = (toTabBarItemNo == 1) ? "first" : "second"
		animation.setValue(animID, forKey: "animID")
		
		flyingView = img
		flyingView.layer.add(animation, forKey: nil)
		window.addSubview(flyingView)
		
		// animated image scaling to final width = 30
		let wid = img.frame.width
		let multiplier: CGFloat = 30 / wid
		UIView.animate(withDuration: animation.duration) {
			[weak self] in
			self?.flyingView.transform = CGAffineTransform(scaleX: multiplier, y: multiplier)
		}
	}
	
	
	/// Calculate & Return animation path
	///
	/// - Parameter startPoint: start point of path (in glogal coords)
	func customPath(startPoint: CGPoint, toPointtoTabBarItemNo: Int) -> UIBezierPath {
		let path = UIBezierPath()
		path.move(to: startPoint)
		let endPoint = SUtils.getPointForTabbarItemAt(toPointtoTabBarItemNo)
		let randomShiftX = CGFloat(10 + drand48() * 200)
		// appcoda.com/wp-content/uploads/2017/03/bezier-curve.png
		let controlPoint1 = CGPoint(x: startPoint.x - randomShiftX, y: startPoint.y)
		let controlPoint2 = CGPoint(x: endPoint.x - randomShiftX, y: endPoint.y)
		
		path.addCurve(to: endPoint, controlPoint1: controlPoint1, controlPoint2: controlPoint2)
		return path
	}
	
	
	//MARK:- UITableView Methods
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return episodes.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: EpisodeCell.cellID, for: indexPath) as! EpisodeCell
		cell.episode = episodes[indexPath.row]
		return cell
	}
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 134
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		let tabBarVC = UIApplication.tabBarVC()
		tabBarVC?.maximizePlayer(episode: episodes[indexPath.row], playlist: episodes)
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
	
	override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		//check if allready have selected episode in downloads
		let selectedPod = episodes[indexPath.row]
		let allSavedPods = UserDefaults.standard.getDownloadedEpisodes()
		var allowEdit = true
		allSavedPods.forEach {
			(episode) in
			if episode == selectedPod {
				allowEdit = false
			}
		}
		let action: UIContextualAction
		if allowEdit { // allow download
			action = UIContextualAction(style: .normal, title: "Скачать", handler: {
				(act, someView, completionHandler) in
				self.prepareToFlightAnim(fromSender: someView, indexPath: indexPath, toTabBarItemNo: 2)
				UserDefaults.standard.saveEpisode(episodes: [selectedPod], addOperation: true)
				APIServices.shared.startDownloadEpisode(episode: selectedPod)
				completionHandler(true) // perform action
			})
			action.backgroundColor = #colorLiteral(red: 0.2124915746, green: 0.6660024672, blue: 0.148491782, alpha: 1)
			action.image = #imageLiteral(resourceName: "downloads")
		}
		else { // show "Уже скачали"
			action = UIContextualAction(style: .normal, title: "Скачано", handler: {
				(_, _, completionHandler) in
				completionHandler(true)
			})
			action.backgroundColor = UIColor.clear
		}
		let swipeAction = UISwipeActionsConfiguration(actions: [action])
		swipeAction.performsFirstActionWithFullSwipe = false // disables full swipe
		return swipeAction
	}
	
}
	

extension EpisodesController: CAAnimationDelegate {
	
	func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
		var tabBarItemNum = 1
		// identify current animation
		if let animType = anim.value(forKey: "animID") as? String {
			tabBarItemNum = (animType == "first") ? 1 : 2
		}
		let badgeValue = UIApplication.tabBarVC()?.viewControllers?[2].tabBarItem.badgeValue
		if let bv = badgeValue, var intFromString = Int(bv) {
			intFromString += 1
			UIApplication.tabBarVC()?.viewControllers?[tabBarItemNum].tabBarItem.badgeValue = intFromString.description
		}
		else {
			UIApplication.tabBarVC()?.viewControllers?[tabBarItemNum].tabBarItem.badgeValue = "1"
		}
		flyingView.removeFromSuperview()
	}
	
}
