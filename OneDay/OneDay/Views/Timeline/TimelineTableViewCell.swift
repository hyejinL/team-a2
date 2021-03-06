//
//  TimelineTableViewCell.swift
//  OneDay
//
//  Created by juhee on 31/01/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//

import UIKit

class TimelineTableViewCell: UITableViewCell {
    private let dayLabel: UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.textAlignment = .right
        label.font = UIFont.boldSystemFont(ofSize: 47)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let weekDayLabel: UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.textColor = .lightGray
        label.textAlignment = .right
        label.font = UIFont.systemFont(ofSize: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let contentTextView: UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        textView.isSelectable = false
        textView.isScrollEnabled = false
        textView.isUserInteractionEnabled = false
        textView.textContainer.maximumNumberOfLines = 3
        textView.font = UIFont.preferredFont(forTextStyle: .caption1)
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    private let favoriteImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .doDark
        label.font = UIFont.preferredFont(forTextStyle: .caption2)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let addressLabel: UILabel = {
        let label = UILabel()
        label.textColor = .doDark
        label.font = UIFont.preferredFont(forTextStyle: .caption2)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let weatherIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let weatherLabel: UILabel = {
        let label = UILabel()
        label.textColor = .doDark
        label.font = UIFont.preferredFont(forTextStyle: .caption2)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var contentTextViewLeftAnchorConstraint: NSLayoutConstraint!
    private var timeLabelLeftAnchorConstraint: NSLayoutConstraint!
    private var cellHeightAnchorConstraint: NSLayoutConstraint!
    private var imageCellHeightAnchorConstraint: NSLayoutConstraint!

    private let imageCellConstant = Constants.timelineThumbnailImageCellHeight //96
    private let nonImageCellConstant = Constants.timelineThumbnailImageCellHeight-16 //80
    private let infoLabelImageViewConstant = Constants.timelineInfoImageLabelViewsHeight //12
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupAnchorConstraint()
        setupThumbnailImageView()

        setupDayLabels()
        setupContentTextView()
        setupEntryInfoViews()
    }
    
    override func prepareForReuse() {
        dayLabel.text = ""
        timeLabel.text = ""
        addressLabel.text = ""
        weatherLabel.text = ""
        weekDayLabel.text = ""
        contentTextView.text = ""
        contentTextView.textContainer.maximumNumberOfLines = 3
        
        favoriteImageView.image = nil
        thumbnailImageView.image = nil
        weatherIconImageView.image = nil
        
        contentTextViewLeftAnchorConstraint.constant = -nonImageCellConstant
        timeLabelLeftAnchorConstraint.constant = 0
        cellHeightAnchorConstraint.isActive = false
        imageCellHeightAnchorConstraint.isActive = false
        
        dayLabel.isHidden = true
        weekDayLabel.isHidden = true
    }
    
    private func setupAnchorConstraint() {
        cellHeightAnchorConstraint =
            heightAnchor.constraint(
            greaterThanOrEqualToConstant: nonImageCellConstant
        )
        cellHeightAnchorConstraint.isActive = true
        
        imageCellHeightAnchorConstraint =
            heightAnchor.constraint(
            equalToConstant: imageCellConstant
        )
    }
    
    func bind(entry: Entry, indexPath: IndexPath, hideDayLabel: Bool) {
        contentTextView.text = entry.contents?.string
        bindDate(from: entry.date, hideDayLabel: hideDayLabel)
        bindFavorite(from: entry)
        bindAddress(from: entry)
        bindWeather(from: entry)
        bindThumbnailImage(from: entry)
    }
    
    private func bindDate(from date: Date, hideDayLabel: Bool) {
        let dateSet = DateStringSet(date: date)
        dayLabel.text = dateSet.day
        weekDayLabel.text = dateSet.weekDay
        timeLabel.text = dateSet.time
        
        dayLabel.isHidden = hideDayLabel
        weekDayLabel.isHidden = hideDayLabel
    }
    
    private func bindFavorite(from entry: Entry) {
        if entry.favorite {
            favoriteImageView.image = UIImage(named: "filterHeart")
            timeLabelLeftAnchorConstraint.constant = infoLabelImageViewConstant+4
        } else {
            favoriteImageView.image = nil
        }
    }
    
    private func bindWeather(from entry: Entry) {
        guard let weather = entry.weather, let type = weather.type
        else {
            return
        }
        
        if let weatherType = WeatherType(rawValue: type) {
            weatherIconImageView.tintColor = .black
            weatherIconImageView.image = UIImage(
                named: weatherType.rawValue)?
                .withRenderingMode(.alwaysTemplate)
            
            weatherLabel.text = "\(weather.temperature)℃ \(weatherType.summary)"
        }
    }
    
    private func bindAddress(from entry: Entry) {
        if let address = entry.location?.address {
            addressLabel.text = address
        }
    }
    
    private func bindThumbnailImage(from entry: Entry) {
        if let thumbImage = entry.thumbnail {
            guard let imageURL = thumbImage.urlForDataStorage
            else {
                preconditionFailure("No thumbnail image")
            }
            do {
                let imageData = try Data(contentsOf: imageURL)
                thumbnailImageView.image = UIImage(data: imageData)
            } catch {
                preconditionFailure("ImageData error")
            }
            
            cellHeightAnchorConstraint.isActive = false

            contentTextView.textContainer.maximumNumberOfLines = 4
            contentTextViewLeftAnchorConstraint.constant =
                (imageCellConstant-nonImageCellConstant)/2
            
            imageCellHeightAnchorConstraint.isActive = true
        } else {
            imageCellHeightAnchorConstraint.isActive = false
            cellHeightAnchorConstraint.isActive = true
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TimelineTableViewCell {
    private func setupDayLabels() {
        addSubview(dayLabel)
        dayLabel.rightAnchor.constraint(
            equalTo: rightAnchor
            , constant: -8)
            .isActive = true
        dayLabel.widthAnchor.constraint(
            equalToConstant: 60)
            .isActive = true
        dayLabel.centerYAnchor.constraint(
            equalTo: centerYAnchor)
            .isActive = true
        
        addSubview(weekDayLabel)
        weekDayLabel.bottomAnchor.constraint(
            equalTo: dayLabel.topAnchor,
            constant: 8)
            .isActive = true
        weekDayLabel.rightAnchor.constraint(
            equalTo: dayLabel.rightAnchor,
            constant: -4)
            .isActive = true
    }
    
    private func setupThumbnailImageView() {
        addSubview(thumbnailImageView)
        let imageHeight = imageCellConstant-8
        thumbnailImageView.leftAnchor.constraint(
            equalTo: leftAnchor
            , constant: 4)
            .isActive = true
        thumbnailImageView.widthAnchor.constraint(
            equalToConstant: imageHeight)
            .isActive = true
        thumbnailImageView.heightAnchor.constraint(
            equalToConstant: imageHeight)
            .isActive = true
        thumbnailImageView.centerYAnchor.constraint(
            equalTo: centerYAnchor)
            .isActive = true
    }
    
    private func setupContentTextView() {
        addSubview(contentTextView)
        contentTextViewLeftAnchorConstraint =
            contentTextView.leftAnchor.constraint(
                equalTo: thumbnailImageView.rightAnchor,
                constant: -nonImageCellConstant)
        contentTextViewLeftAnchorConstraint.isActive = true
        
        contentTextView.topAnchor.constraint(
            equalTo: topAnchor,
            constant: 4)
            .isActive = true
        contentTextView.rightAnchor.constraint(
            equalTo: dayLabel.leftAnchor,
            constant: -8)
            .isActive = true
        contentTextView.heightAnchor.constraint(
            lessThanOrEqualToConstant: 90)
            .isActive = true
    }

    private func setupEntryInfoViews() {
        timeLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        addressLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        weatherLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        setupTimeLabel()
        setupFavoriteImageView()
        setupAddressLabel()
        setupWeatherLabel()
        setupWeatherIconImageView()
    }
    
    private func setupTimeLabel() {
        addSubview(timeLabel)
        timeLabelLeftAnchorConstraint =
            timeLabel.leftAnchor.constraint(
                equalTo: contentTextView.leftAnchor)
        timeLabelLeftAnchorConstraint
            .isActive = true
        timeLabel.bottomAnchor.constraint(
            equalTo: bottomAnchor,
            constant: -2)
            .isActive = true
        timeLabel.widthAnchor.constraint(
            greaterThanOrEqualToConstant: 50)
            .isActive = true
    }
    
    private func setupFavoriteImageView() {
        addSubview(favoriteImageView)
        favoriteImageView.rightAnchor.constraint(
            equalTo: timeLabel.leftAnchor,
            constant: -4)
            .isActive = true
        favoriteImageView.widthAnchor.constraint(
            equalToConstant: infoLabelImageViewConstant)
            .isActive = true
        favoriteImageView.heightAnchor.constraint(
            equalToConstant: infoLabelImageViewConstant)
            .isActive = true
        favoriteImageView.centerYAnchor.constraint(
            equalTo: timeLabel.centerYAnchor)
            .isActive = true
    }
    
    private func setupAddressLabel() {
        addSubview(addressLabel)
        addressLabel.leftAnchor.constraint(
            equalTo: timeLabel.rightAnchor,
            constant: 4)
            .isActive = true
        addressLabel.widthAnchor.constraint(
            greaterThanOrEqualToConstant: 8)
            .isActive = true
        addressLabel.centerYAnchor.constraint(
            equalTo: timeLabel.centerYAnchor)
            .isActive = true
    }
    
    private func setupWeatherLabel() {
        addSubview(weatherLabel)
        weatherLabel.leftAnchor.constraint(
            equalTo: addressLabel.rightAnchor,
            constant: 20)
            .isActive = true
        weatherLabel.rightAnchor.constraint(
            lessThanOrEqualTo: dayLabel.leftAnchor,
            constant: 4)
            .isActive = true
        weatherLabel.widthAnchor.constraint(
            greaterThanOrEqualToConstant: 50)
            .isActive = true
        weatherLabel.centerYAnchor.constraint(
            equalTo: timeLabel.centerYAnchor)
            .isActive = true
    }
    
    private func setupWeatherIconImageView() {
        weatherLabel.addSubview(weatherIconImageView)
        weatherIconImageView.rightAnchor.constraint(
            equalTo: weatherLabel.leftAnchor,
            constant: -4)
            .isActive = true
        weatherIconImageView.widthAnchor.constraint(
            equalToConstant: infoLabelImageViewConstant)
            .isActive = true
        weatherIconImageView.heightAnchor.constraint(
            equalToConstant: infoLabelImageViewConstant)
            .isActive = true
        weatherIconImageView.centerYAnchor.constraint(
            equalTo: timeLabel.centerYAnchor)
            .isActive = true
    }
}
