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

class TestController: UIViewController {

	private var tableView: UITableView!
	private var purchases = [SKProduct]()
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .white
		navigationController?.navigationBar.isTranslucent = true
		setupController()
	}
	
	
	private func setupController() {
		navigationItem.title = "Встроенные покупки"
		installTable()
		navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Восстан.", style: .plain, target: self,
															action: #selector(onRestoreClick))
		navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Explore", style: .plain, target: self,
														   action: #selector(onExploreClick))
		purchases = IAPManager.shared.availablePurchases
		if purchases.isEmpty {
			NotificationCenter.default.addObserver(self, selector: #selector(onGotPurchasesList),
												   name: Notification.Name.gotPurchasesList, object: nil)
			//TODO: add spiner
		}
		NotificationCenter.default.addObserver(self, selector: #selector(onReceiveDownloadCompleteEvent),
											   name: .purchaseDownloadingCompleted, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(onReceiveDownloadCompleteEvent),
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
		tableView.separatorStyle = .none
		view.addSubview(tableView)
		tableView.fillSuperView()
	}
	
	
	@objc private func onGotPurchasesList() {
		//TODO: hide spiner
		purchases = IAPManager.shared.availablePurchases
		// animated tableview output
		let range = NSMakeRange(0, 1)
		let sections = NSIndexSet(indexesIn: range)
		DispatchQueue.main.async {
			self.tableView.reloadSections(sections as IndexSet, with: .bottom)
		}
	}
	
	
	/// reload cell with specific id
	@objc private func onReceiveDownloadCompleteEvent(notif: Notification) {
		guard let updateId = notif.object as? String else { return }
		for (index, item) in purchases.enumerated() {
			if item.productIdentifier == updateId {
				let indexPath = IndexPath(item: index, section: 0)
				DispatchQueue.main.async {
					self.tableView.reloadRows(at: [indexPath], with: .fade)
				}
				return
			}
		}
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




extension TestController: UITableViewDelegate, UITableViewDataSource {
	
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
		return 125
	}
	
//	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//		tableView.deselectRow(at: indexPath, animated: true)
//		let selectedProductID = purchases[indexPath.row].productIdentifier
//		IAPManager.shared.purchaseProduct(productID: selectedProductID)
//	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: PurchaseCell.identifier(),
												 for: indexPath) as! PurchaseCell
		
		let content = purchases[indexPath.row]
		cell.configureWith(productViewModel: content)
//		let str = content.localizedTitle + " - " + content.localizedPrice!
//		cell.textLabel?.text = str
		return cell
	}
	
}

