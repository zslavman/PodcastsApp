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
			titleLabel.text = episode.title
			authorLabel.text = episode.author
			playEpisode()
			guard let url = URL(string: episode.imageLink) else { return }
			titleImage.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "image_placeholder"), options: [])
		}
	}
	private let player: AVPlayer = {
		let avp = AVPlayer()
		avp.automaticallyWaitsToMinimizeStalling = false // remove delay on begin of autoplay
		return avp
	}()
	
	
	
	//MARK:- Class methods
	
	override func awakeFromNib() {
		super.awakeFromNib()
		observeCurrentPlayerTime()
		
		let time = CMTimeMake(value: 1, timescale: 3) // delayed dispatcher for start animation
		let times = [NSValue(time: time)]
		player.addBoundaryTimeObserver(forTimes: times, queue: .main) {
			[weak self] in
			self?.enlargeTitleImage()
		}
	}
	
	
	private func observeCurrentPlayerTime() {
		timeBeginLabel.text = "00:00"
		timeEndLabel.text = "--:--"
		
		let interval = CMTimeMake(value: 1, timescale: 2) // timer for update durations
		player.addPeriodicTimeObserver(forInterval: interval, queue: .main) {
			(time) in
			let totalSeconds = CMTimeGetSeconds(time)
			self.timeBeginLabel.text = SUtils.convertTime(seconds: totalSeconds)
			if let duration = self.player.currentItem?.duration.seconds {
				self.timeEndLabel.text = SUtils.convertTime(seconds: duration, needHours: true)
				self.updateTimeSlider()
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
			enlargeTitleImage()
		}
		else {
			player.pause()
			playPauseBttn.setImage(#imageLiteral(resourceName: "play"), for: .normal)
			shrinkTitleImage()
		}
	}
	
	
	@IBAction func onDismissClick(_ sender: Any) {
		player.pause()
		self.removeFromSuperview()
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
		player.play()
	}
	
	
}
