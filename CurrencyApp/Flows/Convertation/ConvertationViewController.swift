//
//  ConvertationViewController.swift
//  CurrencyApp
//
//  Created by Pyretttt on 09.09.2021.
//

import UIKit
import RxSwift

final class ConvertationViewController: UIViewController {

	var viewModel: ConvertationViewModel?
	private let disposeBag = DisposeBag()
	
	// MARK: - Views
	
	@IBOutlet weak var firstCurrencyLabel: UILabel!
	@IBOutlet weak var firstCurrencyInput: UITextField!
	@IBOutlet weak var firstCurrencyButton: UIButton!
	
	@IBOutlet weak var secondCurrencyLabel: UILabel!
	@IBOutlet weak var secondCurrencyInput: UITextField!
	@IBOutlet weak var secondCurrencyButton: UIButton!
	
	private lazy var keyboardToolBar: UIToolbar = {
		let view = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 40))
		view.items = [
			UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil),
			UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(hideKeyboard(sender:)))
		]
		view.sizeToFit()
		
		return view
	}()
	
	// MARK: - Lifecycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupUI()
		bind()
		bindFieldsResetings()
	}
	
	// MARK: - Setup Data
	
	private func bind() {
		guard let viewModel = viewModel else { return }
		let input = ConvertationViewModel.Input(firstCurrencySelectionDidTapped: firstCurrencyButton.rx.tap.asObservable(),
												secondCurrencySelectionDidTapped: secondCurrencyButton.rx.tap.asObservable(),
												firstFieldValue: firstCurrencyInput.rx.text
													.orEmpty
													.distinctUntilChanged()
													.filter { $0 != "" }
													.debounce(.seconds(1), scheduler: MainScheduler.instance)
													.asObservable(),
												secondFieldValue: secondCurrencyInput.rx.text
													.orEmpty
													.distinctUntilChanged()
													.filter { $0 != "" }
													.debounce(.seconds(1), scheduler: MainScheduler.instance)
													.asObservable())
		
		let output = viewModel.transform(input: input)
		output.firstCurrencyDidChosen
			.map { $0.code }
			.drive(firstCurrencyLabel.rx.text)
			.disposed(by: disposeBag)
		output.secondCurrencyDidChosen
			.map { $0.code }
			.drive(secondCurrencyLabel.rx.text)
			.disposed(by: disposeBag)
		
		output.firstFieldValue
			.drive(firstCurrencyInput.rx.text)
			.disposed(by: disposeBag)
		output.secondFieldValue
			.drive(secondCurrencyInput.rx.text)
			.disposed(by: disposeBag)
		
		output.state.drive(onNext: { [weak self] state in
			guard let self = self else { return }
			switch state {
			case .loading:
				self.startLoadingAnimation()
			case .ready:
				self.stopLoadingAnimation()
			case .error:
				self.presentError()
				self.stopLoadingAnimation()
			}
		})
		.disposed(by: disposeBag)
		
		Observable.combineLatest(output.firstCurrencyDidChosen.asObservable(),
								 output.secondCurrencyDidChosen.asObservable())
		.take(1)
		.subscribe { [weak self] _ in
			self?.firstCurrencyInput.isEnabled = true
			self?.secondCurrencyInput.isEnabled = true
		}
		.disposed(by: disposeBag)
	}
	
	private func bindFieldsResetings() {
		let secondFieldReset = firstCurrencyInput.rx.text
			.orEmpty
			.distinctUntilChanged()
			.filter { $0 != "" }
			.subscribe { [weak self] _ in
				self?.secondCurrencyInput.rx.text.onNext("")
			}
		
		let firstFieldReset = secondCurrencyInput.rx.text
			.orEmpty
			.distinctUntilChanged()
			.filter { $0 != "" }
			.subscribe { [weak self] _ in
				self?.firstCurrencyInput.rx.text.onNext("")
			}
		
		disposeBag.insert(secondFieldReset, firstFieldReset)
	}
	
	// MARK: - Setup UI
	
	private func setupUI() {
		let buttons = [firstCurrencyButton, secondCurrencyButton]
		buttons.forEach { $0?.layer.cornerRadius = 16 }
		
		let fields = [firstCurrencyInput, secondCurrencyInput]
		fields
			.compactMap { $0 }
			.forEach {
				$0.isEnabled = false
				$0.inputAccessoryView = keyboardToolBar
				$0.layer.cornerRadius = 8
				let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: $0.frame.height))
				$0.leftView = leftView
			}
	}
	
	// MARK: - Actions
	
	@objc func hideKeyboard(sender: UIToolbar) {
		let fields = [firstCurrencyInput, secondCurrencyInput]
		fields.forEach { $0?.resignFirstResponder() }
	}
}

