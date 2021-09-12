//
//  ConvertationViewModel.swift
//  CurrencyApp
//
//  Created by Pyretttt on 09.09.2021.
//

import RxSwift
import RxCocoa

protocol ViewModelType: AnyObject {
	associatedtype Input
	associatedtype Output
	
	func transform(input: Input) -> Output
}

final class ConvertationViewModel: ViewModelType {
	
	struct Input {
		let firstCurrencySelectionDidTapped: Observable<Void>
		let secondCurrencySelectionDidTapped: Observable<Void>
		let firstFieldValue: Observable<String>
		let secondFieldValue: Observable<String>
	}
	
	struct Output {
		let firstCurrencyDidChosen: Driver<CurrencyModel>
		let secondCurrencyDidChosen: Driver<CurrencyModel>
		let firstFieldValue: Driver<String>
		let secondFieldValue: Driver<String>
		let state: Driver<AppRouter.ViewState>
	}
	
	private weak var router: AppRouterProtocol?
	private let networkService: NetworkServiceProtocol
	private let disposeBag = DisposeBag()
	
	private var queryItem = ConvertTarget.QueryItem(fromCurrency: "", toCurrency: "", amount: "")
	
	// MARK: - Lifecycle

	init(router: AppRouterProtocol,
		 networkService: NetworkServiceProtocol) {
		self.router = router
		self.networkService = networkService
	}
	
	// MARK: - ViewModelType
	
	func transform(input: Input) -> Output {
		input.firstCurrencySelectionDidTapped.subscribe { [weak self] _ in
			guard let self = self else { return }
			self.router?.showCurrencyListScreen(currencyObserver: self.firstCurrencyChosen.asObserver())
		}
		.disposed(by: disposeBag)
		
		input.secondCurrencySelectionDidTapped.subscribe { [weak self] _ in
			guard let self = self else { return }
			self.router?.showCurrencyListScreen(currencyObserver: self.secondCurrencyChosen.asObserver())
		}
		.disposed(by: disposeBag)
		
		input.firstFieldValue
			.subscribe(onNext: { [weak self] amount in
				guard let self = self,
					  let fromCode = try? self.firstCurrencyChosen.value().code,
					  let toCode = try? self.secondCurrencyChosen.value().code else {
					return
				}
				
				self.state.onNext(.loading)
				
				let target = self.createConvetationTarget(from: fromCode, to: toCode, amount: amount)
				let converationObservable = self.networkService.requestInfo(parser: ConvertationResponseParser.self,
																			target: target)
				converationObservable.subscribe(onNext: { [weak self] convertationResponse in
					self?.secondFieldValue.onNext(convertationResponse.rateForAmount)
					self?.state.onNext(.ready)
				}, onError: { [weak self] _ in
					self?.state.onNext(.error)
				})
				.disposed(by: self.disposeBag)
			})
			.disposed(by: disposeBag)
		
		input.secondFieldValue
			.subscribe(onNext: { [weak self] amount in
				guard let self = self,
					  let fromCode = try? self.secondCurrencyChosen.value().code,
					  let toCode = try? self.firstCurrencyChosen.value().code else {
					return
				}
				
				self.state.onNext(.loading)
				
				let target = self.createConvetationTarget(from: fromCode, to: toCode, amount: amount)
				let converationObservable = self.networkService.requestInfo(parser: ConvertationResponseParser.self,
																			target: target)
				converationObservable
					.subscribe(onNext: { [weak self] convertationResponse in
						self?.firstFieldValue.onNext(convertationResponse.rateForAmount)
						self?.state.onNext(.ready)
					}, onError: { [weak self] _ in
						self?.state.onNext(.error)
					})
					
				.disposed(by: self.disposeBag)
			})
			.disposed(by: disposeBag)

		
		return Output(firstCurrencyDidChosen: firstCurrencyChosen.asDriver(onErrorRecover: { _ in .never() }),
					  secondCurrencyDidChosen: secondCurrencyChosen.asDriver(onErrorRecover: { _ in .never() }),
					  firstFieldValue: firstFieldValue.asDriver(onErrorJustReturn: ""),
					  secondFieldValue: secondFieldValue.asDriver(onErrorJustReturn: ""),
					  state: state.asDriver(onErrorJustReturn: .error))
	}
	
	// MARK: - ConvertationViewModelOutput
	
	let firstCurrencyChosen = BehaviorSubject<CurrencyModel>(value: CurrencyModel(code: "RUB", name: ""))
	let secondCurrencyChosen = BehaviorSubject<CurrencyModel>(value: CurrencyModel(code: "USD", name: ""))
	let firstFieldValue = PublishSubject<String>()
	let secondFieldValue = PublishSubject<String>()
	let state = BehaviorSubject<AppRouter.ViewState>(value: .ready)
	
	// MARK: - Data
	
	private func createConvetationTarget(from: String,
										 to: String,
										 amount: String) -> ConvertTarget {
		let queryItem = ConvertTarget.QueryItem(fromCurrency: from, toCurrency: to, amount: amount)
		return ConvertTarget(queryItem: queryItem)
	}
}
