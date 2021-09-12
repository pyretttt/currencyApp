//
//  CurrencySelectionViewController.swift
//  CurrencyApp
//
//  Created by Pyretttt on 09.09.2021.
//

import UIKit
import RxSwift

final class CurrencySelectionViewController: UIViewController {
	
	private let viewModel: CurrencySelectionViewModel
	private let disposeBag = DisposeBag()
	private var currencies: [CurrencyModel] = []
	
	// MARK: - Subjects
	
	private let searchItem = PublishSubject<String>()
	private let currencyItem = PublishSubject<CurrencyModel>()
	
	// MARK: - Views
	
	private lazy var tableView: UITableView = {
		let view = UITableView(frame: .zero, style: .insetGrouped)
		view.rowHeight = UITableView.automaticDimension
		view.translatesAutoresizingMaskIntoConstraints = false
		view.delegate = self
		view.dataSource = self
		view.register(CurrencyTableViewCell.self, forCellReuseIdentifier: CurrencyTableViewCell.reuseID)
		
		return view
	}()
	
	private let searchBar: UISearchBar = {
		let view = UISearchBar()
		view.showsCancelButton = true
		view.keyboardType = .default
		view.searchBarStyle = .minimal
		view.placeholder = "Введите название валюты"
		view.translatesAutoresizingMaskIntoConstraints = false
		
		return view
	}()
	
	// MARK: - Lifecycle
	
	init(viewModel: CurrencySelectionViewModel) {
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
	}
	
	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .white
		
		setupUI()
		bind()
		bindSearchBar()
		
		searchItem.onNext("")
	}
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		stopLoadingAnimation()
	}
	
	// MARK: - Setup Data
	
	private func bind() {
		let input = CurrencySelectionViewModel.Input(searchDidRequested: searchItem.asObservable(),
													 currencyBeenSelected: currencyItem.asObserver())
		let output = viewModel.transform(input: input)
		output.currencies
			.drive(onNext: { [weak self] currencies in
				self?.currencies = currencies
				self?.tableView.reloadData()
			}) 
		.disposed(by: disposeBag)
		
		output.state.drive(onNext: { [weak self] state in
			guard let self = self else { return }
			switch state {
			case .loading:
				self.startLoadingAnimation()
			case .ready:
				self.stopLoadingAnimation()
			case .error:
				self.stopLoadingAnimation()
				self.presentError()
			}
		})
		.disposed(by: disposeBag)
	}
	
	private func bindSearchBar() {
		searchBar.rx.text
			.orEmpty
			.distinctUntilChanged()
			.debounce(.seconds(1), scheduler: MainScheduler.instance)
			.bind(to: searchItem)
			.disposed(by: disposeBag)
	}
	
	// MARK: - Setup UI
	
	private func setupUI() {
		let views = [tableView, searchBar]
		views.forEach { view.addSubview($0) }
		
		setupConstraints()
	}
	
	private func setupConstraints() {
		NSLayoutConstraint.activate([
			searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			searchBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
			searchBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
			
			tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
			tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
			tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
			tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
		])
	}
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension CurrencySelectionViewController: UITableViewDataSource, UITableViewDelegate {
		
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		currencies.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: CurrencyTableViewCell.reuseID,
													   for: indexPath) as? CurrencyTableViewCell else {
			return UITableViewCell()
		}
		
		let model = currencies[indexPath.row]
		cell.setData(code: model.code, name: model.name)
		
		return cell
	}
	
	// MARK: - UITableViewDelegate
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		
		let model = currencies[indexPath.row]
		currencyItem.onNext(model)
		
		navigationController?.popViewController(animated: true)
	}
}
