//
//  EventTableViewCell.swift
//  Prototype
//
//  Created by Kobe Sam on 10/31/24.
//

import UIKit

final class EventTableViewCell: UITableViewCell {
    static let reuseIdentifier = "EventCell"
    
    // MARK: - UI Elements
    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        
        // Add shadow
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 1)
        view.layer.shadowOpacity = 0.1
        view.layer.shadowRadius = 2
        return view
    }()
    
    private let containerStackView: UIStackView = {
        let stackview = UIStackView()
        let layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        stackview.axis = .vertical
        stackview.spacing = 12
        stackview.layoutMargins = layoutMargins
        stackview.isLayoutMarginsRelativeArrangement = true
        stackview.translatesAutoresizingMaskIntoConstraints = false
        return stackview
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.textColor = .systemGray
        return label
    }()
    
    private let dateDivider: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray5
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .regular)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.setContentHuggingPriority(.required, for: .vertical)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }()
    
    private let locationStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .center
        return stackView
    }()
    
    private let locationIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "pin")
        imageView.tintColor = .gray
        imageView.contentMode = .scaleAspectFit
        imageView.widthAnchor.constraint(equalToConstant: 20).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        return imageView
    }()
    
    private let locationLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.textColor = .systemGray
        label.numberOfLines = 0
        return label
    }()
    
    private let colorBarView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.widthAnchor.constraint(equalToConstant: 4).isActive = true
        return view
    }()
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    // MARK: - Setup
    private func setupViews() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none
        
        // Add card view
        contentView.addSubview(cardView)
        
        // Add color bar
        cardView.addSubview(colorBarView)
        
        // Setup location stack view
        locationStackView.addArrangedSubview(locationIcon)
        locationStackView.addArrangedSubview(locationLabel)
        
        // Setup main container stack view
        containerStackView.addArrangedSubview(dateLabel)
        containerStackView.addArrangedSubview(dateDivider)
        containerStackView.addArrangedSubview(titleLabel)
        containerStackView.addArrangedSubview(locationStackView)
        
        // Add container stack view to card
        cardView.addSubview(containerStackView)
        
        NSLayoutConstraint.activate([
            // Card view constraints
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            // Color bar constraints
            colorBarView.topAnchor.constraint(equalTo: cardView.topAnchor),
            colorBarView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor),
            colorBarView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            
            // Container stack view constraints
            containerStackView.topAnchor.constraint(equalTo: cardView.topAnchor),
            containerStackView.leadingAnchor.constraint(equalTo: colorBarView.trailingAnchor),
            containerStackView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            containerStackView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor)
        ])
    }
    
    // MARK: - Configuration
    func configure(with event: EventViewModel) {
        dateLabel.text = event.dateRange
        titleLabel.text = event.title
        locationLabel.text = event.location
        colorBarView.backgroundColor = event.color
    }
}
