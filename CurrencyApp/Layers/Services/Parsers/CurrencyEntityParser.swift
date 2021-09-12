//
//  CurrencyEntityParser.swift
//  CurrencyApp
//
//  Created by Pyretttt on 09.09.2021.
//

import Foundation

enum CurrencyEntityParser: ParserProtocol {
	static func parseInfo(data: Data) throws -> [CurrencyModel] {
		let info = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
		guard let currencies = info?["currencies"] as? [String: String] else {
			return []
		}
		
		var currencyModels: [CurrencyModel] = []
		for (key, value) in currencies {
			currencyModels.append(CurrencyModel(code: key, name: value))
		}
		
		return currencyModels
	}
}
