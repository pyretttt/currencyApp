//
//  NetworkService.swift
//  CurrencyApp
//
//  Created by Pyretttt on 09.09.2021.
//

import Moya
import RxSwift

protocol NetworkServiceProtocol {
		
	/// Запросить удаленную информацию
	/// - Parameters:
	///   - parser: Маппер ответа в модель
	func requestInfo<JSONParser: ParserProtocol>(parser: JSONParser.Type,
												 target: BaseTarget) -> Observable<JSONParser.Model>
}

final class NetworkService: NetworkServiceProtocol {
	func requestInfo<JSONParser: ParserProtocol>(parser: JSONParser.Type,
												 target: BaseTarget) -> Observable<JSONParser.Model> {
		let observable = Observable<JSONParser.Model>.create { observer in
			let provider = MoyaProvider<BaseTarget>().request(target) { result in
				switch result {
				case let .success(response):
					let data = response.data
					do {
						let info = try parser.parseInfo(data: data)
						observer.onNext(info)
					} catch {
						observer.onError(NetworkError.ParseError)
					}
				case .failure(_):
					observer.onError(NetworkError.BadResponse)
				}
			}
			
			return Disposables.create {
				provider.cancel()
			}
		}
		return observable
	}
}
