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
			prepareToPlay()
			guard let url = URL(string: episode.imageLink) else { return }
			miniTitleImage.image = #imageLiteral(resourceName: "image_placeholder")
			titleImage.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "image_placeholder"), options: []) {
				[weak self] (loadedImage, error, _, _) in
				if let err = error {
					print(err.localizedDescription)
					return
				}
				guard let image = loadedImage else { return }
				self?.miniTitleImage.image = image
				self?.setupLockScreenPlayingArtwork(imageLarge: image)
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
		//observeBoundaryTime()
	}
	
	
	private func setupGestures() {
		panGesture = UIPanGestureRecognizer(target: self, action: #selector(onPan(gesture:)))
		miniPlayerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onThisViewClick)))
		miniPlayerView.addGestureRecognizer(panGesture)
		maximizedStackView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(dragToDismiss)))
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
	
	
	/// lockscreen Author + title setup
	private func setupLockScreenPlayingInfo() {
		var mediaDict = [String : Any]()
		mediaDict[MPMediaItemPropertyArtist] = episode.author
		mediaDict[MPMediaItemPropertyTitle] = episode.title
		mediaDict[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(image: #imageLiteral(resourceName: "appicon"))
		MPNowPlayingInfoCenter.default().nowPlayingInfo = mediaDict
	}
	
	
	/// lockscreen Album artwork setup
	private func setupLockScreenPlayingArtwork(imageLarge: UIImage) {
		let picSize = CGSize(width: 100, height: 100)
		let resizedImg = SUtils.resizeImage(imageLarge, toSize: picSize)
		print("Prepare return image")
//		MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: resizedImg.size) {
//			(_) -> UIImage in
//			print("Return image!")
//			return resizedImg
//		}
		MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(image: resizedImg)
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
		//commandCenter.playCommand.isEnabled = true
		commandCenter.playCommand.addTarget {
			[unowned self] (event) in
			if self.player.rate == 0.0 {
				self.onPlayPauseClick()
				return .success
			}
			return .commandFailed
		}
		//commandCenter.pauseCommand.isEnabled = true
		commandCenter.pauseCommand.addTarget {
			[unowned self] (event) in
			if self.player.rate == 1.0 {
				self.onPlayPauseClick()
				return .success
			}
			return .commandFailed
		}
		//commandCenter.togglePlayPauseCommand.isEnabled = true // for headphones button
		commandCenter.togglePlayPauseCommand.addTarget {
			(_) -> MPRemoteCommandHandlerStatus in
			self.onPlayPauseClick()
			return .success
		}
		commandCenter.nextTrackCommand.addTarget(self, action: #selector(onNextTrack))
		commandCenter.previousTrackCommand.addTarget(self, action: #selector(onPrevTrack))
		commandCenter.changePlaybackPositionCommand.isEnabled = true
		commandCenter.changePlaybackPositionCommand.addTarget(self, action: #selector(onChangePlaybackPosition))
	}
	
	
	@objc private func onChangePlaybackPosition(_ event:MPChangePlaybackPositionCommandEvent) -> MPRemoteCommandHandlerStatus {
		let seekTime = event.positionTime
		print("time = \(time)")
		let cmTime = CMTime(seconds: seekTime, preferredTimescale: 1000)
		MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = cmTime.seconds
		player.seek(to: cmTime)
		return .success
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
	
	//MARK: main player timer
	/// timer
	private func observeCurrentPlayerTime() {
		let interval = CMTimeMake(value: 1, timescale: 2) // timer for update durations
		player.addPeriodicTimeObserver(forInterval: interval, queue: .main) {
			[weak self] (time) in
			guard let strongSelf = self else { return } // fix retain cycle
			let totalSeconds = CMTimeGetSeconds(time)
			strongSelf.timeBeginLabel.text = SUtils.convertTime(seconds: totalSeconds)
			if let duration = strongSelf.player.currentItem?.asset.duration.seconds, !duration.isNaN {
				strongSelf.timeEndLabel.text = SUtils.convertTime(seconds: duration, needHours: true)
				strongSelf.updateTimeSlider()
				strongSelf.updateLockScreenPlayingTime(elapsedTime: Int(totalSeconds), duration: Int(duration))
			}
			else {
				print("Error occure!")
			}
		}
	}
	
	
	/// lockscreen current time + duration setup
	private func updateLockScreenPlayingTime(elapsedTime: Int, duration: Int) {
		MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = elapsedTime
		MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPMediaItemPropertyPlaybackDuration] = duration
	}
	
	
	private func updateTimeSlider() {
		let curTime = player.currentTime().seconds
		let overallTime = player.currentItem?.duration.seconds ?? CMTimeMake(value: 1, timescale: 1).seconds
		let percentage = curTime / overallTime
		currentTimeSlider.value = Float(percentage)
	}
	
	
	@objc private func onPlayPauseClick() {
		if player.timeControlStatus == .paused {
			internalPlayFunc()
		}
		else {
			player.pause()
			playPauseBttn.setImage(#imageLiteral(resourceName: "play"), for: .normal)
			miniPlayPauseBttn.setImage(#imageLiteral(resourceName: "play"), for: .normal)
			shrinkTitleImage()
			MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyPlaybackRate] = 0
		}
	}
	
	private func internalPlayFunc() {
		player.play()
		playPauseBttn.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
		miniPlayPauseBttn.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
		enlargeTitleImage()
		MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyPlaybackRate] = 1
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
	
	
	private func prepareToPlay() {
		//removeBoundaryTimeObserver()
		timeBeginLabel.text = "00:00"
		timeEndLabel.text = "--:--"
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
		internalPlayFunc()
		//addBoundaryTimeObserver()
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
	
	
	@IBAction func onMiniCloseClick(_ sender: UIButton) {
		player.pause()
		playPauseBttn.setImage(#imageLiteral(resourceName: "play"), for: .normal)
		miniPlayPauseBttn.setImage(#imageLiteral(resourceName: "play"), for: .normal)
		shrinkTitleImage()
		MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyPlaybackRate] = 0
		UIApplication.tabBarVC()?.hideMiniPlayer()
	}
	
	
	// this is serious BUG which doesn't give properly load data for background!!!!
	//	private func observeBoundaryTime() {
	//		let time = CMTimeMake(value: 1, timescale: 3) // dispatcher animation after 1 second of playing
	//		let times = [NSValue(time: time)]
	//		boundaryTimeObserver = player.addBoundaryTimeObserver(forTimes: times, queue: .main) {
	//			[weak self] in // episode start playing
	//			self?.updateLockScreenPlayingTime(updDur: <#T##Bool#>, updElaps: <#T##Bool#>)
	//			print(#function)
	//		}
	//	}
	//
	//
	//	var boundaryTimeObserver: Any?
	//
	//	func addBoundaryTimeObserver() {
	//		// Divide the asset's duration into quarters.
	//		guard let duration = player.currentItem?.asset.duration else {
	//			print("Can't get player.currentItem!")
	//			return
	//		}
	//		print(duration)
	//		let interval = CMTimeMultiplyByFloat64(duration, multiplier: 0.25)
	//		var currentTime = CMTime.zero
	//		var times = [NSValue]()
	//
	//		// Calculate boundary times
	//		while currentTime < duration {
	//			currentTime = currentTime + interval
	//			times.append(NSValue(time:currentTime))
	//		}
	//		print(times)
	//		boundaryTimeObserver = player.addBoundaryTimeObserver(forTimes: times, queue: .main) {
	//			// Update UI
	//			print(Date().timeIntervalSinceNow)
	//		}
	//	}
	//
	//	func removeBoundaryTimeObserver() {
	//		if let timeObserverToken = boundaryTimeObserver {
	//			player.removeTimeObserver(timeObserverToken)
	//			boundaryTimeObserver = nil
	//		}
	//	}
	
	
}
