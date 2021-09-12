//
//  ConvertTarget.swift
//  CurrencyApp
//
//  Created by Pyretttt on 09.09.2021.
//

import Moya

final class ConvertTarget: BaseTarget {

	struct QueryItem {
		var fromCurrency: String
		var toCurrency: String
		var amount: String
	}
	
	let queryItem: QueryItem
	
	// MARK: - TargetType
	
	override var path: String {
		return "/currency/convert"
	}
	
	override var task: Task {
		let parameters: [String: String] = [
			"from": queryItem.fromCurrency,
			"to": queryItem.toCurrency,
			"amount": queryItem.amount
		]
		return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
	}
	
	// MARK: - Lifecycle
	
	init(queryItem: QueryItem) {
		self.queryItem = queryItem
	}
}
