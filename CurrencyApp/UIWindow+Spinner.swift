//
//  UIWindow+Spinner.swift
//  CurrencyApp
//
//  Created by Pyretttt on 12.09.2021.
//

import UIKit

extension UIWindow {
	static func startLoading() {
		guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else {
			return
		}
		let tag = 1
		stopLoading()
		
		let spinner = UIActivityIndicatorView(style: .large)
		spinner.tag = tag
		window.addSubview(spinner)
		spinner.startAnimating()
		spinner.center = window.center
	}
	
	static func stopLoading() {
		guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else {
			return
		}
		let tag = 1
		window.subviews
			.filter { $0.tag == tag }
			.forEach { $0.removeFromSuperview() }
	}
}
