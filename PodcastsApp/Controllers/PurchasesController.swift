//
//  TestController.swift
//  PodcastsApp
//
//  Created by Zinko Viacheslav on 22.08.2019.
//  Copyright © 2019 Zinko Viacheslav. All rights reserved.
//

import Foundation
import UIKit
import StoreKit
import SwiftyStoreKit
import PKHUD

class PurchasesController: UIViewController {

	private var tableView: UITableView!
	private var purchases = [SKProduct]()
	private var timer: Timer!
	private let refreshControl = UIRefreshControl()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .white
		extendedLayoutIncludesOpaqueBars = true
		setupController()
		addRefreshControl()
	}
	
	
	private func setupController() {
		navigationItem.title = "Покупки"
		installTable()
		navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Восстан.", style: .plain, target: self,
															action: #selector(onRestoreClick))
		navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Explore", style: .plain, target: self,
														   action: #selector(onExploreClick))
		purchases = IAPManager.shared.availablePurchases
		if purchases.isEmpty {
			NotificationCenter.default.addObserver(self, selector: #selector(onGotPurchasesList),
												   name: .gotPurchasesList, object: nil)
			PurchasesController.showLoading()
		}
		NotificationCenter.default.addObserver(self, selector: #selector(onReceiveDownloadCompleteEvent),
											   name: .purchaseDownloadingCompleted, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(onReceiveError),
											   name: .purchaseDownloadingError, object: nil)
	}
	
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
	
	
	private func installTable() {
		tableView = UITableView(frame: .zero, style: .plain)
		tableView.delegate = self
		tableView.dataSource = self
		tableView.register(PurchaseCell.self, forCellReuseIdentifier: PurchaseCell.identifier())
		tableView.tableFooterView = UIView()
		view.addSubview(tableView)
		tableView.fillSuperView()
	}
	
	
	private func addRefreshControl() {
		refreshControl.addTarget(self, action: #selector(didPullDownToUpdate),for: .valueChanged)
		tableView.refreshControl = refreshControl
	}
	
	
	@objc func didPullDownToUpdate() {
		JSONDownloadService.shared.downloadNewJSON(forced: true)
		DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: DispatchTime.now() + 2) {
			DispatchQueue.main.async {
				self.refreshControl.endRefreshing()
			}
		}
	}
	
	
	@objc private func onGotPurchasesList() {
		let tableWasEmpty: Bool = purchases.isEmpty
		purchases = IAPManager.shared.availablePurchases
//		for _ in 0...5 {
//			let copied = purchases.randomElement()!
//			purchases.append(copied)
//		}
		print("onGotPurchasesList triggered!")
		// animated tableview output
		let range = NSMakeRange(0, 1)
		let sections = NSIndexSet(indexesIn: range)
		HUD.hide()
		DispatchQueue.main.async {
			if tableWasEmpty {
				self.tableView.reloadSections(sections as IndexSet, with: .bottom)
			}
			else {
				self.tableView.reloadSections(sections as IndexSet, with: .fade)
			}
		}
	}
	
	
	/// reload cell with specific id
	@objc private func onReceiveDownloadCompleteEvent(notif: Notification) {
		guard let updateId = notif.object as? String else { return }
		reloadCellByPurchaseID(id: updateId)
	}
	
	
	@objc private func onReceiveError(notif: Notification) {
		guard let errorEntity = notif.object as? PurchaseErrorEntity else { return }
		reloadCellByPurchaseID(id: errorEntity.purchaseID)
		showAlert(message: errorEntity.error.localizedDescription)
	}
	
	
	private func reloadCellByPurchaseID(id: String) {
		for (index, item) in purchases.enumerated() {
			if item.productIdentifier == id {
				let indexPath = IndexPath(item: index, section: 0)
				DispatchQueue.main.async {
					self.tableView.reloadRows(at: [indexPath], with: .fade)
				}
				return
			}
		}
	}
	
	public static func showLoading() {
		HUD.flash(.labeledProgress(title: "Загрузка..", subtitle: nil), delay: 3)
	}
	
	
	private func showAlert(message: String) {
		let alertVC = UIAlertController(title: "Ошибка", message: message, preferredStyle: UIAlertController.Style.alert)
		let OK_action = UIAlertAction(title: "OK", style: .default)
		alertVC.addAction(OK_action)
		present(alertVC, animated: true)
	}
	
	
	@objc private func onRestoreClick() {
		print("Restore clicked!")
	}
	
	
	@objc private func onExploreClick() {
		// get all URLs of files(dirs) in documentsDir
		let purchaseName = "com.zslavman.Purchase1/Contents"
		let filesPaths = FilePathManager.shared.exploreDocumentsDir(withNextPath: purchaseName)
		print(filesPaths)
		
		// try to create images from filesPaths
		var images = [UIImage]()
		filesPaths.forEach {
			(fileURL) in
			let fileExtension = fileURL.pathExtension.lowercased()
			if fileExtension == "jpg" {
				if let img = FilePathManager.shared.createImageFromURL(pathString: fileURL.path) {
					images.append(img)
				}
			}
		}
		print(images)
	}
	
	
}




extension PurchasesController: UITableViewDelegate, UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return purchases.isEmpty ? 0 : 70
	}
	
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let label = UILabel()
		label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
		label.textColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
		label.textAlignment = .center
		label.text = "Наборы ассоциативно метафорических карт психолога"
		label.numberOfLines = 0
		label.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1).withAlphaComponent(0.95)
		return label
	}
	
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return purchases.count
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 130
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: PurchaseCell.identifier(),
												 for: indexPath) as! PurchaseCell
		let content = purchases[indexPath.row]
		let jsonModel = JSONDownloadService.shared.parsed.filter{ $0.purchaseID == content.productIdentifier}.first
		cell.configureWith(productViewModel: content, jsonModel: jsonModel)
		cell.delegate = self
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let id = purchases[indexPath.row].productIdentifier
		let detailVC = PurchaseDetailController()
		detailVC.initWith(productID: id)
		navigationController?.pushViewController(detailVC, animated: true)
	}
	
}

extension PurchasesController: PurchaseCellDelegate {

	func showHUD() {
		HUD.flash(.progress, onView: nil, delay: 2, completion: nil)
	}

}

