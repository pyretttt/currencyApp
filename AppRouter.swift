//
//  AppRouter.swift
//  CurrencyApp
//
//  Created by Pyretttt on 09.09.2021.
//

import UIKit
import RxSwift

protocol AppRouterProtocol: AnyObject {
	func showConvertationScreen()
	func showCurrencyListScreen(currencyObserver: AnyObserver<CurrencyModel>)
}

class AppRouter: AppRouterProtocol {
	
	private(set) weak var navigationController: UINavigationController?
	private let networkService = NetworkService()
	
	// MARK: - Lifecycle
	
	init(navigationController: UINavigationController) {
		self.navigationController = navigationController
	}
	
	// MARK: - AppRouterProtocol
	
	func showConvertationScreen() {
		let viewModel = ConvertationViewModel(router: self,
											  networkService: networkService)
		
		let storyBoard = UIStoryboard(name: "ConvertationView", bundle: nil)
		let view = storyBoard.instantiateViewController(withIdentifier: "ConvertationView")
		(view as? ConvertationViewController)?.viewModel = viewModel
		navigationController?.pushViewController(view, animated: false)
	}
	
	func showCurrencyListScreen(currencyObserver: AnyObserver<CurrencyModel>) {
		let viewModel = CurrencySelectionViewModel(networkService: networkService,
												   selectionObserver: currencyObserver)
		let view = CurrencySelectionViewController(viewModel: viewModel)
		navigationController?.pushViewController(view, animated: true)
	}
}

extension AppRouter {
	enum ViewState {
		case loading
		case ready
		case error
	}
}
