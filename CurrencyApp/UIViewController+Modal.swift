//
//  UIViewController+Modal.swift
//  CurrencyApp
//
//  Created by Pyretttt on 12.09.2021.
//

import UIKit

extension UIViewController {
	func presentError() {
		let alert = UIAlertController(title: "Возникла ошибка",
									  message: "Попробуйте позже",
									  preferredStyle: .alert)
		let action = UIAlertAction(title: "Ок", style: .cancel)
		alert.addAction(action)
		self.present(alert, animated: true)
	}
	
	func startLoadingAnimation() {
		UIWindow.startLoading()
	}
	
	func stopLoadingAnimation() {
		UIWindow.stopLoading()
	}
}



