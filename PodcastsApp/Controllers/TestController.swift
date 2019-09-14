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
		navigationItem.title = "Purchases"
		installTable()
		getAvailablePurchases()
		navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Restore", style: .plain, target: self,
															action: #selector(onRestoreClick))
		navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Explore saved", style: .plain, target: self,
														   action: #selector(onExploreClick))
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
	
	
	private func getAvailablePurchases() {
		let purchaseIDs = Set(IAPProducts.allCases.compactMap{$0.rawValue})
		
		SwiftyStoreKit.retrieveProductsInfo(purchaseIDs) {
			result in
			if let error = result.error {
				print("Error: \(error.localizedDescription)")
				return
			}
			if !result.invalidProductIDs.isEmpty {
				print("Invalid products: \(result.invalidProductIDs)")
			}
			for product in result.retrievedProducts {
				self.purchases.append(product)
			}
			self.purchases.sort(by: {
				(pr1, pr2) -> Bool in
				return pr1.localizedTitle < pr2.localizedTitle
			})
			DispatchQueue.main.async {
				self.tableView.reloadData()
			}
		}
	}
	
	
	internal func purchaseProduct(productID: String) {
		SwiftyStoreKit.purchaseProduct(productID, quantity: 1, atomically: false) {
			result in
			switch result {
			case .success(let product):
				//				//fetch content from your server, then:
				//				if product.needsFinishTransaction {
				//					SwiftyStoreKit.finishTransaction(product.transaction)
				//				}
				//				print("Purchase Success: \(product.productId)")
				let downloads = product.transaction.downloads
				if !downloads.isEmpty {
					SwiftyStoreKit.start(downloads)
				}
			case .error(let error):
				switch error.code {
				case .unknown: print("Unknown error. Please contact support")
				case .clientInvalid: print("Not allowed to make the payment")
				case .paymentCancelled: break
				case .paymentInvalid: print("The purchase identifier was invalid")
				case .paymentNotAllowed: print("The device is not allowed to make the payment")
				case .storeProductNotAvailable: print("The product is not available in the current storefront")
				case .cloudServicePermissionDenied: print("Access to cloud service information is not allowed")
				case .cloudServiceNetworkConnectionFailed: print("Could not connect to the network")
				case .cloudServiceRevoked: print("User has revoked permission to use this cloud service")
				default: print((error as NSError).localizedDescription)
				}
			}
		}
	}
	
	
	// neeed to reloacate in AppDelegate or independance class
	public static func updateDownloads() {
		SwiftyStoreKit.updatedDownloadsHandler = {
			downloads in
			// contentURL is not nil if downloadState == .finished
			let contentURLs = downloads.compactMap { $0.contentURL }
			//print("downloading hosted content")
			
			if let skDownload = downloads.first {
				let progress = Int(skDownload.progress * 100)
				print("\(skDownload.contentIdentifier) =", progress, "%")
			}
			if contentURLs.count == downloads.count {
				print("download completed! \(contentURLs)")
				// process all downloaded files, then finish the transaction
				SwiftyStoreKit.finishTransaction(downloads[0].transaction)
				FilePathManager.shared.moveFileToDocumentsDir(tempURL: contentURLs[0], newFileName: downloads[0].contentIdentifier)
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
	
	
	
	deinit {
		NotificationCenter.default.removeObserver(self)
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
		purchaseProduct(productID: selectedProductID)
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
		let content = purchases[indexPath.row]
		let str = content.localizedTitle + " - " + content.localizedPrice!
		cell.textLabel?.text = str
		return cell
	}
	
}

