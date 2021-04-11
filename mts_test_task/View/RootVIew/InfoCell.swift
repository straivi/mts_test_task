//
//  InfoCell.swift
//  mts_test_task
//
//  Created by  Matvey on 09.04.2021.
//

import UIKit

class InfoCell: UITableViewCell {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        label.setContentHuggingPriority(.defaultLow, for: .vertical)
        return label
    }()
    
    private let previewImageView: UICachedImageView = {
        let imageView = UICachedImageView()
        imageView.backgroundColor = .lightGray
        imageView.layer.borderWidth = 1
        imageView.layer.cornerRadius = 10
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = .darkGray
        label.numberOfLines = 0
        label.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        label.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        accessoryType = .disclosureIndicator
        
        var constraints: [NSLayoutConstraint] = []
        
        contentView.addSubview(previewImageView)
        previewImageView.translatesAutoresizingMaskIntoConstraints = false
        let previewConstraints = [
            previewImageView.heightAnchor.constraint(equalToConstant: 100),
            previewImageView.widthAnchor.constraint(equalToConstant: 100),
            previewImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            previewImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            previewImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ]
        constraints += previewConstraints
        
        contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        let titleConstraints = [
            titleLabel.topAnchor.constraint(equalTo: previewImageView.topAnchor, constant: 4),
            titleLabel.leadingAnchor.constraint(equalTo: previewImageView.trailingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ]
        constraints += titleConstraints
        
        contentView.addSubview(descriptionLabel)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        let descriptionConstraints = [
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 3),
            descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            descriptionLabel.bottomAnchor.constraint(lessThanOrEqualTo: previewImageView.bottomAnchor, constant: -4)
        ]
        constraints += descriptionConstraints
        
        NSLayoutConstraint.activate(constraints)
    }
    
    func configure(with model: NasaObject) {
        titleLabel.text = model.title
        descriptionLabel.text = model.description
        previewImageView.loadImage(atUrl: model.previewImageUrl)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        previewImageView.image = nil
        previewImageView.cancelImageLoad()
    }
    
    
}
