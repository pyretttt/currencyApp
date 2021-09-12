//
//  CurrencyTableViewCell.swift
//  CurrencyApp
//
//  Created by Pyretttt on 10.09.2021.
//

import UIKit

class CurrencyTableViewCell: UITableViewCell {

	private enum Values {
		static let defaultOffset: CGFloat = 16
	}
	
	static let reuseID: String = "CurrencyTableViewCellID"
	
	// MARK: - Views
	
	private let codeLabel: UILabel = {
		let view = UILabel()
		view.textColor = .black
		view.textAlignment = .left
		view.font = view.font.withSize(18)
		view.setContentHuggingPriority(.defaultHigh, for: .horizontal)
		view.translatesAutoresizingMaskIntoConstraints = false
		
		return view
	}()
	
	private let nameLabel: UILabel = {
		let view = UILabel()
		view.textColor = .black
		view.textAlignment = .left
		view.font = view.font.withSize(14)
		view.setContentHuggingPriority(.defaultLow, for: .horizontal)
		view.translatesAutoresizingMaskIntoConstraints = false
		
		return view
	}()
	
	// MARK: - Lifecycle
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupUI()
	}
	
	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - Setup Data
	
	func setData(code: String, name: String) {
		codeLabel.text = code
		nameLabel.text = name
	}
	
	// MARK: - Setup UI
	
	private func setupUI() {
		let views = [codeLabel, nameLabel]
		views.forEach { contentView.addSubview($0) }
		
		setupConstraints()
	}
	
	private func setupConstraints() {
		NSLayoutConstraint.activate([
			codeLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Values.defaultOffset),
			codeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Values.defaultOffset),
			codeLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Values.defaultOffset),
			
			nameLabel.centerYAnchor.constraint(equalTo: codeLabel.centerYAnchor),
			nameLabel.leadingAnchor.constraint(equalTo: codeLabel.trailingAnchor, constant: Values.defaultOffset)
		])
	}
}
