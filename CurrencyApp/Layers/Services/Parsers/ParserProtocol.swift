//
//  Parser.swift
//  CurrencyApp
//
//  Created by Pyretttt on 09.09.2021.
//

import Foundation

protocol ParserProtocol {
	associatedtype Model
	
	static func parseInfo(data: Data) throws -> Model
}
