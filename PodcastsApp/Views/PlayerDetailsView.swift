//
//  PlayerDetailsView.swift
//  PodcastsApp
//
//  Created by Zinko Viacheslav on 11.05.2019.
//  Copyright © 2019 Zinko Viacheslav. All rights reserved.
//

import UIKit
import AVKit
import MediaPlayer
import AVKit

// this View init with build TabBar
class PlayerDetailsView: UIView {
	
	@IBOutlet weak var miniPlayerView: UIStackView! // stack container
	@IBOutlet weak var miniTitleImage: UIImageView!
	@IBOutlet weak var miniLabel: UILabel!
	@IBOutlet weak var miniPlayPauseBttn: UIButton!
	
	@IBOutlet weak var maximizedStackView: UIStackView!
	@IBOutlet weak var timeBeginLabel: UILabel!
	@IBOutlet weak var timeEndLabel: UILabel!
	@IBOutlet weak var currentTimeSlider: UISlider!
	@IBOutlet weak var currentVolumeSlider: UISlider!
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
			setupLockScreenPlayingInfo()
			setupAudiosessionBackgroundMode()
			playEpisode()
			guard let url = URL(string: episode.imageLink) else { return }
			titleImage.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "image_placeholder"), options: [])
			miniTitleImage.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "image_placeholder"), options: []) {
				(image, _, _, _) in
				guard let image = image else { return }
				self.setupLockScreenPlayingArtwork(image: image)
			}
		}
	}
	private let player: AVPlayer = {
		let avp = AVPlayer()
		avp.automaticallyWaitsToMinimizeStalling = false // remove delay on begining of autoplay
		return avp
	}()
	private var panGesture: UIPanGestureRecognizer!
	public var playlist = [Episode]() {
		didSet {
			print("playlist.count = ", playlist.count)
		}
	}
	
	
	
	
	
	//MARK:- Class methods
	
	public static func initFromNib() -> PlayerDetailsView {
		let playerDetailView = Bundle.main.loadNibNamed("PlayerDetailsView", owner: self, options: nil)?.first as! PlayerDetailsView
		return playerDetailView
	}
	

	override func awakeFromNib() {
		super.awakeFromNib()
		setupBackgroundControls()
		setupGestures()
		currentVolumeSlider.value = playerVolume
		setupInteruptionObserver()
		observeCurrentPlayerTime()
		observeBoundaryTime()
	}
	
	
	@objc private func setupInteruptionObserver() {
		NotificationCenter.default.addObserver(self, selector: #selector(handleInterruption), name: AVAudioSession.interruptionNotification, object: nil)
	}
	
	
	@objc private func handleInterruption(notification: Notification) {
		guard let userInfo = notification.userInfo else { return }
		guard let type = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt else { return }
		if type == AVAudioSession.InterruptionType.began.rawValue {
			print("Interruption began")
			playPauseBttn.setImage(#imageLiteral(resourceName: "play"), for: .normal)
			miniPlayPauseBttn.setImage(#imageLiteral(resourceName: "play"), for: .normal)
		}
		else {
			print("Interruption ended")
			guard let options = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else { return }
			if options == AVAudioSession.InterruptionOptions.shouldResume.rawValue {
				onPlayPauseClick()
			}
		}
	}
	
	
	private func observeBoundaryTime() {
		let time = CMTimeMake(value: 1, timescale: 3) // dispatcher animation after 1 second of playing
		let times = [NSValue(time: time)]
		player.addBoundaryTimeObserver(forTimes: times, queue: .main) {
			[weak self] in // episode start playing
			self?.enlargeTitleImage()
			self?.setupLockScreenPlayingCurrentTime(needEditDuration: true)
		}
	}
	
	
	/// lockscreen Author + title setup
	private func setupLockScreenPlayingInfo() {
		var mediaDict = [String:Any]()
		mediaDict[MPMediaItemPropertyArtist] = episode.author
		mediaDict[MPMediaItemPropertyTitle] = episode.title
		MPNowPlayingInfoCenter.default().nowPlayingInfo = mediaDict
	}
	
	
	/// lockscreen Album artwork setup
	private func setupLockScreenPlayingArtwork(image: UIImage) {
		let artwork = MPMediaItemArtwork(boundsSize: image.size, requestHandler: {
			(_) -> UIImage in
			return image
		})
		MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPMediaItemPropertyArtwork] = artwork
	}
	
	
	/// lockscreen current time + duration setup
	private func setupLockScreenPlayingCurrentTime(needEditDuration: Bool) {
		if needEditDuration, let duration = player.currentItem?.duration.seconds {
			MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPMediaItemPropertyPlaybackDuration] = duration
		}
		// if not set elapsedTime you will have a bug after pause click
		let elapsedTime = player.currentTime().seconds
		MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = elapsedTime
	}
	
	
	/// allow play podcasts on locked screen (or in background)
	private func setupAudiosessionBackgroundMode() {
		do {
			try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
			try AVAudioSession.sharedInstance().setActive(true, options: [.notifyOthersOnDeactivation])
		}
		catch let err {
			print("Failed to activate session: ", err.localizedDescription)
		}
	}
	
	
	/// setupRemoteControl in background
	private func setupBackgroundControls() {
		UIApplication.shared.beginReceivingRemoteControlEvents()
		let commandCenter = MPRemoteCommandCenter.shared()
		commandCenter.playCommand.isEnabled = true
		commandCenter.playCommand.addTarget {
			(_) -> MPRemoteCommandHandlerStatus in
			self.onPlayPauseClick()
			return .success
		}
		commandCenter.pauseCommand.isEnabled = true
		commandCenter.pauseCommand.addTarget {
			(_) -> MPRemoteCommandHandlerStatus in
			self.onPlayPauseClick()
			return .success
		}
		commandCenter.togglePlayPauseCommand.isEnabled = true // for headphones button
		commandCenter.togglePlayPauseCommand.addTarget {
			(_) -> MPRemoteCommandHandlerStatus in
			self.onPlayPauseClick()
			return .success
		}
		commandCenter.nextTrackCommand.addTarget(self, action: #selector(onNextTrack))
		commandCenter.previousTrackCommand.addTarget(self, action: #selector(onPrevTrack))
	}
	
	
	
	@objc private func onPrevTrack() {
		changeTrack(arg: -1)
	}
	
	@objc private func onNextTrack() {
		changeTrack(arg: 1)
	}
	
	@objc private func changeTrack(arg: Int) {
		guard !playlist.isEmpty else { return }
		let currentIndex = playlist.firstIndex {
			(ep) -> Bool in
			return self.episode.author == ep.author && self.episode.title == ep.title
		}
		guard var index = currentIndex else { return }
		if arg > 0 { // next track
			if index == playlist.count - 1 {
				index = 0
			}
			else {
				index += 1
			}
		}
		else { // prev track
			if index == 0 {
				index = playlist.count - 1
			}
			else {
				index -= 1
			}
		}
		let nextEpisode = playlist[index]
		episode = nextEpisode // this line switch current played track!
	}
	
	
	private func setupGestures() {
		panGesture = UIPanGestureRecognizer(target: self, action: #selector(onPan(gesture:)))
		miniPlayerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onThisViewClick)))
		miniPlayerView.addGestureRecognizer(panGesture)
		maximizedStackView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(dragToDismiss)))
	}
	
	
	@objc private func dragToDismiss(gesture: UIPanGestureRecognizer) {
		let translation = gesture.translation(in: superview)
		if gesture.state == .changed {
			maximizedStackView.transform = CGAffineTransform(translationX: 0, y: translation.y)
		}
		else if gesture.state == .ended {
			let velocity = gesture.velocity(in: superview)
			UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
				self.maximizedStackView.transform = .identity
				if translation.y > 100 || velocity.y > 500 {
					UIApplication.tabBarVC()?.minimizePlayer()
				}
			})
		}
		
	}
	
	
	/// maximize
	@objc private func onThisViewClick() {
		UIApplication.tabBarVC()?.maximizePlayer(episode: nil)
		//panGesture.isEnabled = false
	}
	
	
	/// minimize
	@IBAction func onDismissClick(_ sender: Any) {
		UIApplication.tabBarVC()?.minimizePlayer()
	}
	
	
	private func observeCurrentPlayerTime() {
		timeBeginLabel.text = "00:00"
		timeEndLabel.text = "--:--"
		
		let interval = CMTimeMake(value: 1, timescale: 2) // timer for update durations
		player.addPeriodicTimeObserver(forInterval: interval, queue: .main) {
			[weak self] (time) in
			guard let strongSelf = self else { return } // fix retain cycle
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
			MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyPlaybackRate] = 1
		}
		else {
			player.pause()
			playPauseBttn.setImage(#imageLiteral(resourceName: "play"), for: .normal)
			miniPlayPauseBttn.setImage(#imageLiteral(resourceName: "play"), for: .normal)
			shrinkTitleImage()
			MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyPlaybackRate] = 0
		}
		setupLockScreenPlayingCurrentTime(needEditDuration: false)
	}
	
	/// drag to maximize
	@objc public func onPan(gesture: UIPanGestureRecognizer) {
		if gesture.state == .began {
			print("began")
		}
		else if gesture.state == .changed {
			panChanged(gesture: gesture)
		}
		else if gesture.state == .ended {
			panEnded(gesture: gesture)
		}
	}
	
	
	private func panChanged(gesture: UIPanGestureRecognizer) {
		let translation = gesture.translation(in: self.superview)
		transform = CGAffineTransform(translationX: 0, y: translation.y)
		self.miniPlayerView.alpha = 1 + translation.y / 200
		self.maximizedStackView.alpha = -translation.y / 200
	}
	
	private func panEnded(gesture: UIPanGestureRecognizer) {
		let translation = gesture.translation(in: self.superview)
		let velocity = gesture.velocity(in: self.superview)
		UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
			self.transform = .identity
			
			if translation.y < -200 || velocity.y < -500 {
				UIApplication.tabBarVC()?.maximizePlayer(episode: nil)
			}
			else {
				self.miniPlayerView.alpha = 1
				self.maximizedStackView.alpha = 0
			}
		})
	}
	
	
	@IBAction func onTimelineScrubbing(_ sender: Any) {
		let percentage = currentTimeSlider.value
		guard let duration = player.currentItem?.duration.seconds else { return }
		let seekTime = Double(percentage) * duration
		// 1000 instead 1 - fix error "very low timescale"
		let cmTime = CMTime(seconds: seekTime, preferredTimescale: 1000)
		// fix for background
		let seconds = cmTime.seconds
		MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = seconds
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
		var url: URL
		if episode.fileUrl != nil { // local file playing
			// figure out file name for finding variable location
			guard let fileURL = URL(string: episode.fileUrl ?? "") else { return }
			let fileName = fileURL.lastPathComponent
			guard var trueLocation = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
			else { return }
			trueLocation.appendPathComponent(fileName)
			url = trueLocation
		}
		else {
			guard let safeURL = URL(string: episode.strimLink) else { return }
			url = safeURL
		}
		
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
