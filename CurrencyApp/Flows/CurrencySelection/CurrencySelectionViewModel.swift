//
//  CurrencySelectionViewModel.swift
//  CurrencyApp
//
//  Created by Pyretttt on 09.09.2021.
//

import RxSwift
import RxCocoa

protocol CurrencySelectionViewModelProtocol {
	associatedtype Input
	associatedtype Output
	
	func transform(input: Input) -> Output
}

final class CurrencySelectionViewModel: CurrencySelectionViewModelProtocol {
	
	struct Input {
		let searchDidRequested: Observable<String>
		let currencyBeenSelected: Observable<CurrencyModel>
	}
	
	struct Output {
		let currencies: Driver<[CurrencyModel]>
		let state: Driver<AppRouter.ViewState>
	}
	
	private let disposeBag = DisposeBag()
	private let networkService: NetworkServiceProtocol
	private var selectionObserver: AnyObserver<CurrencyModel>
	private var cache: [CurrencyModel] = []
	
	// MARK: - Lifecycle
	
	init(networkService: NetworkServiceProtocol,
		 selectionObserver: AnyObserver<CurrencyModel>) {
		self.networkService = networkService
		self.selectionObserver = selectionObserver
	}
	
	// MARK: - CurrencySelectionViewModelProtocol
	
	func transform(input: Input) -> Output {
		input.searchDidRequested.subscribe(onNext: { [weak self] keyWords in
			guard let self = self else { return }
			
			// Берем данные из кеша, если они там есть
			if !self.cache.isEmpty {
				let filteredCurrencies = self.cache.filter {
					if keyWords.isEmpty { return true }
					
					let keyWordUppercased = keyWords.uppercased()
					return $0.name.uppercased().contains(keyWordUppercased) || $0.code.uppercased().contains(keyWordUppercased)
				}
				self.currencies.onNext(filteredCurrencies)
				return
			}
			
			let target = CurrenciesTarget()
			self.networkService.requestInfo(parser: CurrencyEntityParser.self, target: target)
				.share(replay: 1, scope: .whileConnected)
				.do(onNext: { currencies in
					self.cache = currencies
					self.state.onNext(.ready)
				}, onError: { _ in
					self.state.onNext(.error)
				})
				.subscribe(self.currencies)
				.disposed(by: self.disposeBag)
		})
		.disposed(by: disposeBag)
		
		input.currencyBeenSelected
			.bind(to: selectionObserver)
			.disposed(by: disposeBag)
		
		let output = Output(currencies: currencies.asDriver(onErrorJustReturn: []),
							state: state.asDriver(onErrorJustReturn: .error))
		return output
	}
	
	// MARK: - Output
	
	let currencies = PublishSubject<[CurrencyModel]>()
	let state = BehaviorSubject<AppRouter.ViewState>(value: .loading)
}
