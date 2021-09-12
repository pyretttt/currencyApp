//
//  BaseTarget.swift
//  CurrencyApp
//
//  Created by Pyretttt on 09.09.2021.
//

import Moya

class BaseTarget: TargetType {
	
	// MARK: TargetType
	
	var baseURL: URL
	
	var path: String {
		""
	}
	
	var method: Method = .get
	
	var sampleData: Data = Data()
	
	var task: Task {
		return .requestPlain
	}
	
	var headers: [String : String]? {
		return [
			"x-rapidapi-host": "currency-converter5.p.rapidapi.com",
			"x-rapidapi-key": "f96847c424msh3226f07e3f2ade4p1464a8jsn93f99a3b39e5"
		]
	}
	
	// MARK: Lifecycle
	
	init(baseURL: String = "https://currency-converter5.p.rapidapi.com") {
		guard let url = URL(string: baseURL) else {
			self.baseURL = URL(fileReferenceLiteralResourceName: "")
			return
		}
		self.baseURL = url
	}
}
