//
//  Calculations.swift
//  ChatApp
//
//  Created by Zinko Vyacheslav on 02.12.2018.
//  Copyright © 2018 Zinko Vyacheslav. All rights reserved.
//

import Foundation
import UIKit

struct SUtils {
	
	/// получаем класс со строки
	static func stringClassFromString(className: String) -> AnyClass!{
		/// get namespace
		let namespace = Bundle.main.infoDictionary!["CFBundleExecutable"] as! String
		let cls: AnyClass = NSClassFromString("\(namespace).\(className)")!
		return cls
	}
	
	
	/// преобразует секунды в формат ММ:СС
	static func convertTime(seconds: Double, needHours: Bool = false) -> String {
		let intValue = Int(seconds)
		let hou = intValue / 3600
		let min = (intValue / 60) % 60
		let sec = intValue % 60
		var time = String(format:"%02i:%02i", min, sec)
		if needHours && hou > 0 {
			time = String(format:"%02i:%02i:%02i", hou, min, sec)
		}
		return time
	}
	
	public static func convertDate(date: Date) -> String {
		let dateFormater = DateFormatter()
		dateFormater.locale = Locale(identifier: "RU")
		dateFormater.dateFormat = "dd"
		let numDay = dateFormater.string(from: date)
		var month = dateFormater.shortMonthSymbols[Calendar.current.component(.month, from: date) - 1]
		if month.last == "." {
			month = String(month.dropLast())
		}
		dateFormater.dateFormat = "yyyy"
		let year = dateFormater.string(from: date)
		return "\(numDay) \(month) \(year)"
	}
	
	
	/// подсчет ожидаемых размеров текстового поля
	static func estimatedFrameForText(text: String) -> CGRect{
		let siz = CGSize(width: UIScreen.main.bounds.width * 2/3, height: .infinity)
		let opt = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
		
		return NSString(string: text).boundingRect(with: siz, options: opt, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)], context: nil)
	}
	
	
	static func getImageWithColor(color: UIColor, size: CGSize) -> UIImage {
		let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
		UIGraphicsBeginImageContextWithOptions(size, false, 0)
		color.setFill()
		UIRectFill(rect)
		let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
		UIGraphicsEndImageContext()
		return image
	}
	
	
	static func alert(message: String, title: String = "", completion: (() -> ())?) -> UIAlertController {
		let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
		let OK_action = UIAlertAction(title: "OK", style: .default, handler: {
			(action) in
			if let completion = completion {
				completion()
			}
		})
		alertController.addAction(OK_action)
		return alertController
	}
	
	
	// анимированное появление таблицы без секций (ячейки подтягиваются снизу)
	static func animateTableWithRows(tableView:UITableView, duration: Double){
		let cells = tableView.visibleCells
		for cell in cells {
			cell.transform = CGAffineTransform(translationX: 0, y: tableView.bounds.size.height)
		}
		for (i, cell) in cells.enumerated() {
			let delay = Double(i) * 0.05
			UIView.animate(withDuration: duration, delay: delay, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
				cell.transform = CGAffineTransform.identity
			}, completion: nil)
		}
	}
	
	
	/// анимированное появление таблицы с секциями
	static func animateTableWithSections(tableView:UITableView){
		let range = NSMakeRange(0, tableView.numberOfSections)
		let sections = NSIndexSet(indexesIn: range)
		tableView.reloadSections(sections as IndexSet, with: .bottom)
	}
	
	
	// измерение скорости выполнения методов
	static func timeMeasuringCodeRunning(title:String, operationBlock: () -> ()) {
		let start = CFAbsoluteTimeGetCurrent()
		operationBlock()
		let finish = CFAbsoluteTimeGetCurrent()
		let timeElapsed = finish - start
		print ("Время выполнения \(title) = \(timeElapsed) секунд")
	}
	
	
	// откроется в другом потоке т.к. URLSession
	static func getJSON(link: String, completion: @escaping (Data) -> Void){
		var url: URL
		// проверяем валидность урл
		if let validLink = URL(string: link){
			url = validLink
		}
		else {
			print("Invalid link!")
			return
		}
		URLSession.shared.dataTask(with: url) {
			(data, response, error) in
			
			if let error = error {
				print(error.localizedDescription)
			}
			else if let data = data {
				print("Got new JSON")
				completion(data)
			}
		}.resume()
	}
	
	
	public static func linkParser (url: URL) -> [String:String] {
		var dict = [String:String]()
		let components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
		if let queryItems = components.queryItems {
			for item in queryItems {
				dict[item.name] = item.value!
			}
		}
		return dict
	}
	
	
	public static func printDictionary(dict:[String:Any]) {
		dict.forEach { print("\($0.key) = \($0.value)")}
	}
	
	
	/// Возвращает рандомный элемент массива
	///
	/// - Parameter arr: массив
	public static func randArrElemen<T>(array arr:Array<T>) -> T{
		
		let randomIndex = Int(arc4random_uniform(UInt32(arr.count)))
		return arr[randomIndex]
	}
	
	/// Возвращает рандомное число между min и max
	public static func random(_ min: Int, _ max: Int) -> Int {
		guard min < max else {return min}
		return Int(arc4random_uniform(UInt32(1 + max - min))) + min
	}
	
	
	// расстояние между дкумя точками
	public func distanceCalc(a:CGPoint, b:CGPoint) -> CGFloat{
		return sqrt(pow((b.x - a.x), 2) + pow((b.y - a.y), 2))
	}
	
	// пересчет времени передвижения при различных расстояниях
	public func timeToTravelDistance(distance:CGFloat, speed:CGFloat) -> TimeInterval{
		let time = distance / speed
		return TimeInterval(time)
	}
	
	
	// получение текущего DateComponents
	public static func getDateComponent(fromDate:Date = Date()) -> DateComponents{
		let calendar = Calendar(identifier: .gregorian)
		let components = calendar.dateComponents([.month, .day, .hour, .minute, .second], from: fromDate)
		return components
	}
	
	
	/// Play taptic feedback
	///
	/// - Parameter state: touch-state for avoid re-triggering
	public static func tapticFeedback(state: UIGestureRecognizer.State? = nil) {
		if state != nil {
			guard state == .began else { return }
		}
		let impactFeedbackgenerator = UIImpactFeedbackGenerator(style: .heavy)
		impactFeedbackgenerator.prepare()
		impactFeedbackgenerator.impactOccurred()
		// more sensetive feedback with 3 cases:
		//let generator = UINotificationFeedbackGenerator()
		//generator.notificationOccurred(.success)
	}
	
}


extension String {
	
	public func toSecureHTTPS() -> String {
		return self.contains("https") ? self : self.replacingOccurrences(of: "http", with: "https")
	}
	
}

extension UserDefaults {
	
	static let dowloadKey = "dowloadKey"
	
	/// load favorites (albums) from persistance storage
	func fetchFavorites() -> [Podcast] {
		guard let data = UserDefaults.standard.data(forKey: "favPodKey") else { return [] }
		guard let extractedData = NSKeyedUnarchiver.unarchiveObject(with: data) as? [Podcast] else { return [] }
		return extractedData
	}
	
	/// add 1 episode to saved episodes
	func saveEpisode(episodes: [Episode], addOperation: Bool) {
		var allDownloadedEpisodes = getDownloadedEpisodes()
		if episodes.count == 1 && addOperation{
			allDownloadedEpisodes.insert(episodes.first!, at: 0)
		}
		else {
			allDownloadedEpisodes = episodes
		}
		do {
			let data = try JSONEncoder().encode(allDownloadedEpisodes)
			UserDefaults.standard.set(data, forKey: UserDefaults.dowloadKey)
		}
		catch let error {
			print("Failed to encode episode", error.localizedDescription)
		}
	}
	
	/// get all episodes which you saved
	func getDownloadedEpisodes() -> [Episode] {
		guard let episodesData = UserDefaults.standard.data(forKey: UserDefaults.dowloadKey) else { return [] }
		
		do {
			let episodesArr = try JSONDecoder().decode([Episode].self, from: episodesData)
			return episodesArr
		}
		catch let err {
			print("Failed to decode episode", err.localizedDescription)
			return []
		}
	}

}

extension UIApplication {
	
	static func tabBarVC() -> TabBarController? {
		return UIApplication.shared.keyWindow?.rootViewController as? TabBarController
	}
	
}






















