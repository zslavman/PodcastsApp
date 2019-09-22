//
//  IAPManager.swift
//  PodcastsApp
//
//  Created by Zinko Viacheslav on 11.08.2019.
//  Copyright © 2019 Zinko Viacheslav. All rights reserved.
//

import SwiftyStoreKit
import StoreKit

// this enum need to be received from third party server!
enum IAPProducts: String, CaseIterable {
	case purchase1 = "com.zslavman.Purchase1"
	case purchase2 = "com.zslavman.Purchase2"
	case purchase3 = "com.zslavman.Purchase3"
	// call "IAPProducts.allCases" to get an array of all cases
}

extension Notification.Name {
	static let gotPurchasesList = Notification.Name("gotPurchasesList")
	static let purchaseDownloadsUpdated = Notification.Name("purchaseDownloadsUpdated")
	static let purchaseDownloadingCompleted = Notification.Name("purchaseDownloadingCompleted")
	static let purchaseDownloadingError = Notification.Name("purchaseDownloadingError")
	static let gotNewJSON = Notification.Name("gotJSON")
}

struct PurchaseErrorEntity {
	let purchaseID: String
	let error: Error
}


class IAPManager {
	
	public static let shared = IAPManager()
	public var availablePurchases = [SKProduct]()
	private var purchaseIDs = Set<String>()
	private var downloadsPool = [SKDownload]()
	private let queue = DispatchQueue(label: "MultiAccessQueue", qos: .background) // avoid race condition
	public var suspendedPurchaseIDs: Set<String> {
		return _suspended
	}
	private var _suspended = Set<String>() // for purchases which just clicked "Buy"
	
	
	private init() {
		NotificationCenter.default.addObserver(self, selector: #selector(getAvailablePurchases), name: .gotNewJSON,
											   object: nil)
	}
	
	
	/// get all available purchases for application
	@objc private func getAvailablePurchases() {
		let parsedJSON = JSONDownloadService.shared.parsed
		purchaseIDs = Set(parsedJSON.compactMap{ $0.purchaseID })
		print("getAvailablePurchases triggered!")
		
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
				self.availablePurchases.append(product)
			}
			self.availablePurchases.sort(by: {
				(pr1, pr2) -> Bool in
				return pr1.productIdentifier < pr2.productIdentifier
			})
			NotificationCenter.default.post(name: .gotPurchasesList, object: nil)
			print("Successfully got PurchasesList!")
		}
	}
	
	
	/// if click buy product
	public func purchaseProduct(productID: String) {
		_suspended.insert(productID)
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
				let entity = PurchaseErrorEntity(purchaseID: productID, error: error)
				self._suspended.remove(productID)
				NotificationCenter.default.post(name: .purchaseDownloadingError, object: entity) // release locked button
			}
		}
	}
	
	
	/// handler for in-app downloads
	public func setDownloadsHandler() {
		SwiftyStoreKit.updatedDownloadsHandler = {
			[weak self] downloads in
			
			self?.queue.async(flags: .barrier) {
				self?.downloadsPool = downloads
				NotificationCenter.default.post(name: .purchaseDownloadsUpdated, object: downloads )
			}
			
			// if purchase did finish downloading it will have field "contentURL" which is location file in local storage
			// or contentURL is not nil if downloadState == .finished
			let finished = downloads.filter{ $0.contentURL != nil }
			if !finished.isEmpty {
				self?.finishDownloadPurchase(purchases: finished)
			}
		}
	}
	
	
	/// finish purchase downloading
	private func finishDownloadPurchase(purchases: [SKDownload]) {
		purchases.forEach {
			(purchase) in
			let id = purchase.contentIdentifier
			print("download completed for \(id)")
			SwiftyStoreKit.finishTransaction(purchase.transaction)
			_suspended.remove(id)
			if let safeFileLocation = purchase.contentURL {
				FilePathManager.shared.moveFileToDocumentsDir(tempURL: safeFileLocation, newFileName: id)
				//TODO: convert purchase to RealmObj & save, set flag "purchased" with version of content
				removeDownloadFromPool(id: id)
			}
		}
	}
	
	
	private func removeDownloadFromPool(id: String) {
		for (index, item) in downloadsPool.enumerated() {
			if item.contentIdentifier == id {
				queue.async(flags: .barrier) {
					self.downloadsPool.remove(at: index)
					NotificationCenter.default.post(name: .purchaseDownloadingCompleted, object: id)
				}
				return
			}
		}
	}
	
	
	public func getProgressForIdentifier(id: String) -> Double {
		guard let desiredDownload = (downloadsPool.filter{ $0.contentIdentifier == id }).first else { return -1 }
		let progress = Double(desiredDownload.progress)
		return progress
	}
	
	
	
	
}
