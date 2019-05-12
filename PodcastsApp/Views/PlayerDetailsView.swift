//
//  PlayerDetailsView.swift
//  PodcastsApp
//
//  Created by Zinko Viacheslav on 11.05.2019.
//  Copyright © 2019 Zinko Viacheslav. All rights reserved.
//

import UIKit
import AVKit

class PlayerDetailsView: UIView {
	
	@IBOutlet weak var timeBeginLabel: UILabel!
	@IBOutlet weak var timeEndLabel: UILabel!
	@IBOutlet weak var currentTimeSlider: UISlider!
	@IBOutlet weak var currentVolumeSlider: UISlider!
	@IBOutlet weak var maximizedStackView: UIStackView!
	
	@IBOutlet weak var minimizedStackView: UIStackView!
	@IBOutlet weak var miniTitleImage: UIImageView!
	@IBOutlet weak var miniLabel: UILabel!
	@IBOutlet weak var miniPlayPauseBttn: UIButton!
	
	
	@IBOutlet weak var titleImage: UIImageView! {
		didSet {
			titleImage.layer.cornerRadius = 8
			titleImage.clipsToBounds = true
			titleImage.transform = shrunkingTransform
		}
	}
	private let animDuration: TimeInterval = 0.5
	private let shrunkingTransform = CGAffineTransform(scaleX: 0.7, y: 0.7)
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var authorLabel: UILabel!
	@IBOutlet weak var playPauseBttn: UIButton! {
		didSet {
			playPauseBttn.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
			playPauseBttn.addTarget(self, action: #selector (onPlayPauseClick), for: .touchUpInside)
		}
	}
	public var episode: Episode! {
		didSet {
			miniLabel.text = episode.title
			titleLabel.text = episode.title
			authorLabel.text = episode.author
			playEpisode()
			guard let url = URL(string: episode.imageLink) else { return }
			titleImage.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "image_placeholder"), options: [])
			miniTitleImage.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "image_placeholder"), options: [])
		}
	}
	private let player: AVPlayer = {
		let avp = AVPlayer()
		avp.automaticallyWaitsToMinimizeStalling = false // remove delay on begin of autoplay
		return avp
	}()
	
	
	
	//MARK:- Class methods
	
	public static func initFromNib() -> PlayerDetailsView {
		let playerDetailView = Bundle.main.loadNibNamed("PlayerDetailsView", owner: self, options: nil)?.first as! PlayerDetailsView
		return playerDetailView
	}
	
	
	override func awakeFromNib() {
		super.awakeFromNib()
		currentVolumeSlider.value = playerVolume
		addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onThisViewClick)))
		observeCurrentPlayerTime()
		let time = CMTimeMake(value: 1, timescale: 3) // dispatcher animation after 1 second of playing
		let times = [NSValue(time: time)]
		player.addBoundaryTimeObserver(forTimes: times, queue: .main) {
			[weak self] in
			self?.enlargeTitleImage()
		}
	}
	
	
	@objc private func onThisViewClick() {
		let tabBarVC = UIApplication.shared.keyWindow?.rootViewController as? TabBarController
		tabBarVC?.maximizePlayer(episode: nil)
	}
	
	
	private func observeCurrentPlayerTime() {
		timeBeginLabel.text = "00:00"
		timeEndLabel.text = "--:--"
		
		let interval = CMTimeMake(value: 1, timescale: 2) // timer for update durations
		player.addPeriodicTimeObserver(forInterval: interval, queue: .main) {
			[weak self] (time) in
			guard let strongSelf = self else { return }
			let totalSeconds = CMTimeGetSeconds(time)
			strongSelf.timeBeginLabel.text = SUtils.convertTime(seconds: totalSeconds)
			if let duration = strongSelf.player.currentItem?.duration.seconds, !duration.isNaN {
				strongSelf.timeEndLabel.text = SUtils.convertTime(seconds: duration, needHours: true)
				strongSelf.updateTimeSlider()
			}
		}
	}
	
	
	private func updateTimeSlider() {
		let curTime = player.currentTime().seconds
		let overallTime = player.currentItem?.duration.seconds ?? CMTimeMake(value: 1, timescale: 1).seconds
		let percentage = curTime / overallTime
		currentTimeSlider.value = Float(percentage)
	}
	
	
	@objc private func onPlayPauseClick() {
		if player.timeControlStatus == .paused {
			player.play()
			playPauseBttn.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
			miniPlayPauseBttn.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
			enlargeTitleImage()
		}
		else {
			player.pause()
			playPauseBttn.setImage(#imageLiteral(resourceName: "play"), for: .normal)
			miniPlayPauseBttn.setImage(#imageLiteral(resourceName: "play"), for: .normal)
			shrinkTitleImage()
		}
	}
	
	
	@IBAction func onTimelineScrubbing(_ sender: Any) {
		let percentage = currentTimeSlider.value
		guard let duration = player.currentItem?.duration.seconds else { return }
		let seekTime = Double(percentage) * duration
		// 1000 instead 1 - fix error "very low timescale"
		let cmTime = CMTime(seconds: seekTime, preferredTimescale: 1000)
		player.seek(to: cmTime)
	}
	
	
	@IBAction func onVolumeScrubbing(_ sender: UISlider) {
		playerVolume = sender.value
	}
	
	
	@IBAction func onRewindClick(_ sender: Any) {
		timelineJump(seconds: -15)
	}
	
	
	@IBAction func onForwardClick(_ sender: Any) {
		timelineJump(seconds: 15)
	}
	
	
	@IBAction func onDismissClick(_ sender: Any) {
		//self.removeFromSuperview()
		let tabBarVC = UIApplication.shared.keyWindow?.rootViewController as? TabBarController
		tabBarVC?.minimizePlayer()
	}
	
	private func timelineJump(seconds: Int) {
		let fifteenSeconds = CMTime(seconds: Double(seconds), preferredTimescale: 1)
		let seekTime = CMTimeAdd(player.currentTime(), fifteenSeconds)
		player.seek(to: seekTime)
	}
	
	
	private func enlargeTitleImage() {
		UIView.animate(withDuration: animDuration, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
			self.titleImage.transform = .identity
		})
	}
	
	
	private func shrinkTitleImage() {
		UIView.animate(withDuration: animDuration, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
			self.titleImage.transform = self.shrunkingTransform
		})
	}
	
	
	private func playEpisode() {
		guard let url = URL(string: episode.strimLink) else { return }
		let playerItem = AVPlayerItem(url: url)
		player.replaceCurrentItem(with: playerItem)
		player.volume = playerVolume
		player.play()
	}
	
	private var playerVolume: Float {
		get {
			guard let generalVolume = UserDefaults.standard.object(forKey: "generalVolume") as? Float
			else { return 1 }
			return generalVolume
		}
		set {
			UserDefaults.standard.set(newValue, forKey: "generalVolume")
			player.volume = newValue
		}
	}
	
	
	@IBAction func onMiniPlayPauseClick(_ sender: UIButton) {
		onPlayPauseClick()
	}
	
	
	@IBAction func onMiniForwardClick(_ sender: UIButton) {
		timelineJump(seconds: 15)
	}
	
	
}
