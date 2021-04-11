//
//  UICachedImageView.swift
//  mts_test_task
//
//  Created by  Matvey on 10.04.2021.
//

import UIKit

class UICachedImageView: UIImageView {
    
    private let indicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(frame: .zero)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    init() {
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setupUI() {
        self.addSubview(indicator)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        let indicatorConstraints = [
            indicator.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            indicator.centerXAnchor.constraint(equalTo: self.centerXAnchor)
        ]
        
        NSLayoutConstraint.activate(indicatorConstraints)
    }
    
    func loadImage(atUrl url: String) {
        showLoadIndicator(true)
        UIImageLoader.shared.load(url: url, for: self) { [weak self] in
            self?.showLoadIndicator(false)
        }
    }
    
    func cancelImageLoad() {
        UIImageLoader.shared.cancel(for: self)
    }
    
    private func showLoadIndicator(_ isWillShow: Bool) {
        if isWillShow {
            indicator.startAnimating()
        } else {
            indicator.stopAnimating()
        }
    }
}
