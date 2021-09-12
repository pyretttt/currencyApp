//
//  ConvertationResponseParser.swift
//  CurrencyApp
//
//  Created by Pyretttt on 09.09.2021.
//

import Foundation

enum ConvertationResponseParser: ParserProtocol {
	static func parseInfo(data: Data) throws -> ConvertationResponseModel {
		let info = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
	
		guard let ratesNode = info?["rates"] as? [String: Any],
			  let currencyKey = ratesNode.keys.first,
			  let convertationResult = ratesNode[currencyKey] as? [String: Any],
			  let rateForAmount = convertationResult["rate_for_amount"] as? String else {
			throw NetworkError.ParseError
		}
		
		return ConvertationResponseModel(rateForAmount: rateForAmount)
	}
}
