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
	private let cellID = "id"
	private var purchases = [SKProduct]()
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .white
		setupController()
	}
	
	
	private func setupController() {
		navigationItem.title = "Встроенные покупки"
		installTable()
		navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Восстановить", style: .plain, target: self,
															action: #selector(onRestoreClick))
		navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Explore saved", style: .plain, target: self,
														   action: #selector(onExploreClick))
		purchases = IAPManager.shared.availablePurchases
		if purchases.isEmpty {
			NotificationCenter.default.addObserver(self, selector: #selector(onGotPurchasesList),
												   name: Notification.Name.gotPurchasesList, object: nil)
			//TODO: add spiner
		}
	}
	
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
	
	
	private func installTable() {
		tableView = UITableView(frame: .zero, style: .plain)
		tableView.delegate = self
		tableView.dataSource = self
		tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
		tableView.tableFooterView = UIView()
		tableView.contentInset.top = 20
		tableView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(tableView)
		NSLayoutConstraint.activate([
			tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
			tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
			tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
		])
	}
	
	
	@objc private func onGotPurchasesList() {
		//TODO: hide spiner
		purchases = IAPManager.shared.availablePurchases
		DispatchQueue.main.async {
			self.tableView.reloadData()
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
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return purchases.count
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 50
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		let selectedProductID = purchases[indexPath.row].productIdentifier
		IAPManager.shared.purchaseProduct(productID: selectedProductID)
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
		let content = purchases[indexPath.row]
		let str = content.localizedTitle + " - " + content.localizedPrice!
		cell.textLabel?.text = str
		return cell
	}
	
}

