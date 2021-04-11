//
//  DetailViewController.swift
//  mts_test_task
//
//  Created by  Matvey on 11.04.2021.
//

import UIKit
import AVKit
import AVFoundation

class DetailViewController: UIViewController {
    
    private var nasaObject: NasaObject
    
    private let networkService = NetworkService()
    private var player: AVPlayer? = nil
    
    private let imageView: UICachedImageView = {
        let imageView = UICachedImageView()
        imageView.layer.borderWidth = 1
        imageView.layer.cornerRadius = 30
        imageView.layer.borderColor = UIColor.black.cgColor
        imageView.backgroundColor = .black
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    private var playButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(AppImage.playImage, for: .normal)
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        label.numberOfLines = 0
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .justified
        label.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        label.numberOfLines = 0
        return label
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.numberOfLines = 1
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = .lightGray
        return label
    }()
    
    init(nasaObject: NasaObject) {
        self.nasaObject = nasaObject
        super.init(nibName: nil, bundle: nil)
        setupLayout()
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        requestOriginalContentSize(by: nasaObject.sizesLink)
        setupActions()
    }
    
    //MARK: Setup UI
    private func setupLayout() {
        if #available(iOS 13.0, *) {
            view.backgroundColor = .systemBackground
        } else {
            view.backgroundColor = .white
        }
        
        var constraint = [NSLayoutConstraint]()
        
        let scrollView = UIScrollView()
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        let scrollViewConstraints = [
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ]
        constraint += scrollViewConstraints
        
        let containerView = UIView()
        scrollView.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        let containerConstraints = [
            containerView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            containerView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ]
        constraint += containerConstraints
        
        containerView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let imageViewConstraints = [
            imageView.topAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.topAnchor, constant: 32),
            imageView.leadingAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            imageView.trailingAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor)
        ]
        constraint += imageViewConstraints
        
        if nasaObject.contentType == .video {
            imageView.addSubview(playButton)
            playButton.translatesAutoresizingMaskIntoConstraints = false
            let playConstraints = [
                playButton.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
                playButton.centerXAnchor.constraint(equalTo: imageView.centerXAnchor)
            ]
            constraint += playConstraints
        }
        
        containerView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        let titleConstraints = [
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 32),
            titleLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: -8)
        ]
        constraint += titleConstraints
        
        containerView.addSubview(descriptionLabel)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        let descriptionConstraints = [
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor)
        ]
        constraint += descriptionConstraints
        
        containerView.addSubview(timeLabel)
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        let timeLabelConstraints = [
            timeLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 16),
            timeLabel.leadingAnchor.constraint(equalTo: descriptionLabel.leadingAnchor),
            timeLabel.trailingAnchor.constraint(equalTo: descriptionLabel.trailingAnchor),
            timeLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -32)
        ]
        constraint += timeLabelConstraints
        
        NSLayoutConstraint.activate(constraint)
    }
    
    private func configure() {
        title = "Detail information"
        titleLabel.text = nasaObject.title
        descriptionLabel.text = nasaObject.description
        timeLabel.text = DateConverter.dateToString(nasaObject.createdDate)
    }
    
    private func setupActions() {
        print(#function)
        playButton.isUserInteractionEnabled = true
        playButton.addTarget(self, action: #selector(startVideo), for: .touchUpInside)
    }
    
    @objc
    private func startVideo() {
        print("start video")
        let playerVC = AVPlayerViewController()
        playerVC.player = player
        self.present(playerVC, animated: true) {
            playerVC.player?.play()
        }
    }
}

// MARK: Actions
extension DetailViewController {
    
}

// MARK: Network
extension DetailViewController {
    func requestOriginalContentSize(by url: String) {
        networkService.getOriginalSizeContent(byURL: url) { [weak self] (result) in
            switch result {
            case .success(let contentLink):
                switch self?.nasaObject.contentType {
                case .image:
                    self?.imageView.loadImage(atUrl: contentLink.photoLink)
                case .video:
                    self?.imageView.loadImage(atUrl: contentLink.photoLink)
                    guard let url = URL(string: contentLink.videoLink ?? "") else {
                        let alert = UIAlertController(title: "Error", message: "Cant play video", preferredStyle: .alert)
                        let returnAction = UIAlertAction(title: "Return back", style: .cancel) { (_) in
                            self?.dismiss(animated: true, completion: nil)
                        }
                        let okAction = UIAlertAction(title: "OK", style: .default)
                        alert.addAction(returnAction)
                        alert.addAction(okAction)
                        self?.present(alert, animated: true)
                        return }
                    self?.player = AVPlayer(url: url)
                case .none:
                    break
                }
            case .failure(let error):
                let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                let returnAction = UIAlertAction(title: "Return back", style: .default) { (_) in
                    self?.navigationController?.popViewController(animated: true)
                }
                alert.addAction(returnAction)
                self?.present(alert, animated: true)
            }
        }
    }
}
