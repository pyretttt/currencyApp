//
//  AppDelegate.swift
//  CurrencyApp
//
//  Created by Pyretttt on 09.09.2021.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?
	private(set) var navigationController: UINavigationController = UINavigationController()
	private(set) var router: AppRouterProtocol?
	
	func application(_ application: UIApplication,
					 didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		window = UIWindow(frame: UIScreen.main.bounds)
		window?.rootViewController = navigationController
		window?.makeKeyAndVisible()
		
		router = AppRouter(navigationController: navigationController)
		router?.showConvertationScreen()
		
		return true
	}
}

