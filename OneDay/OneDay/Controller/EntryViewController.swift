//
//  EntryViewController.swift
//  OneDay
//
//  Created by juhee on 31/01/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//

import CoreData
import MobileCoreServices
import UIKit

class EntryViewController: UIViewController {
    
    // MARK: - Properties
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var weatherImageView: UIImageView!
    @IBOutlet weak var weatherLabel: UILabel!
    
    @IBOutlet weak var bottomTableView: UITableView!
    @IBOutlet weak var mapView:UIView!
    
    var coreDataStack: CoreDataStack!
    var entry: Entry!
    
    ///드레그시 사용되는 미리보기 뷰
    let imagePreview = UIImageView()
    let textPreview = UIView()
    let previewLabel = UILabel()
    
    lazy var isImageSelected = false
    
    ///하단 뷰 드래그시 사용되는 프로퍼티
    var topY = CGFloat()            ///드래그 범위의 상단 기준
    var bottomY = CGFloat()         ///드래그 범위의 하단 기준
    var dragUpChangePointY = CGFloat()    ///하단 뷰 위로 드래그시 위로 붙는 기준 Y
    var dragDownChangePointY = CGFloat()  ///하단 뷰 아래로 드래그시 아래로 붙는 기준 Y
    var isBottom = true //하단 뷰의 위치 true: 하단, false: 하단
    var willPositionChange = false //드래그 도중 기준을 넘었는지 판단
    
    let generator = UIImpactFeedbackGenerator(style: UIImpactFeedbackGenerator.FeedbackStyle.heavy)
    
    let settingIdentifier = "settingCellIdentifier"
    var settingTableData: [[Setting]] = [[],[],[]]  /// [section][row]
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpDate()
//        setUpWeather()
        setUpPreview()
        setUpBottomView()
        setUpSettingTableViewData()
    }
    
    // MARK: - Setup
    
    func setUpDate() {
        var dateSet: DateStringSet = DateStringSet(date: Date())
        if let entry = entry {
            dateSet = DateStringSet(date: entry.date)
            textView.attributedText = entry.contents
        }
        dateLabel.text = dateSet.full
        textView.textDragDelegate = self
    }
    
    func setUpPreview() {
        imagePreview.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        
        textPreview.backgroundColor = UIColor(white: 1, alpha: 0.7)
        textPreview.layer.cornerRadius = 20
        textPreview.translatesAutoresizingMaskIntoConstraints = false
        textPreview.widthAnchor.constraint(
            lessThanOrEqualToConstant: UIScreen.main.bounds.width/2
        ).isActive = true
        textPreview.heightAnchor.constraint(lessThanOrEqualToConstant: 200).isActive = true
        textPreview.addSubview(previewLabel)
        
        previewLabel.textAlignment = .left
        previewLabel.numberOfLines = 0
        previewLabel.translatesAutoresizingMaskIntoConstraints = false
        previewLabel.topAnchor.constraint(
            equalTo: textPreview.topAnchor,
            constant: 8
        ).isActive = true
        previewLabel.bottomAnchor.constraint(
            equalTo: textPreview.bottomAnchor,
            constant: -8
        ).isActive = true
        previewLabel.leftAnchor.constraint(
            equalTo: textPreview.leftAnchor,
            constant: 8
        ).isActive = true
        previewLabel.rightAnchor.constraint(
            equalTo: textPreview.rightAnchor,
            constant: -8
        ).isActive = true
    }
    
    func setUpWeather() {
        if let weather = entry.weather {
            temperatureLabel.text = "\(weather.tempature)℃"
            guard let type = weather.type else { return }
            weatherImageView.image = UIImage(named: type)
            weatherLabel.text = WeatherType(rawValue: type)?.summary
        } else {
            let weather = Weather(context: coreDataStack.managedContext)
            entry.weather = weather
            
            WeatherService.service.weather(
                latitude: LocationService.service.latitude,
                longitude: LocationService.service.longitude,
                success: {[weak self] data in
                    let degree: Int = Int((data.currently.temperature - 32) * (5/9)) /// ℉를 ℃로 변경
                    weather.tempature = Int16(degree)
                    weather.type = data.currently.icon
                    weather.weatherId = UUID.init()
                    DispatchQueue.main.sync {
                        self?.temperatureLabel.text = "\(weather.tempature)℃"
                        guard let type = weather.type else { return }
                        self?.weatherImageView.image = UIImage(named: type)
                        self?.weatherLabel.text = WeatherType(rawValue: type)?.summary
                    }
                },
                errorHandler: { [weak self] in
                    self?.showAlert(title: "Error", message: "날씨 정보를 불러올 수 없습니다.")
            })
        }
    }
    
    func setUpBottomView() {
        bottomTableView.dataSource = self
        bottomTableView.delegate = self
        bottomTableView.register(
            EditorSettingTableViewCell.self,
            forCellReuseIdentifier: settingIdentifier
        )
        
        let gesture = UIPanGestureRecognizer(
            target: self,
            action: #selector(wasDragged(gestureRecognizer:))
        )
        bottomTableView.addGestureRecognizer(gesture)
        bottomTableView.isUserInteractionEnabled = true
        
        mapView.backgroundColor = UIColor.doBlue
        
        ///하단 뷰 드래그 시 사용되는 값을 하단 뷰의 값에 따라 지정
        let origin = textView.frame.origin
        let bottomOrigin = bottomTableView.frame.origin
        topY = origin.y + bottomTableView.frame.height/2
        bottomY = bottomOrigin.y + bottomTableView.frame.height/2
        dragUpChangePointY = CGFloat(900)
        dragDownChangePointY = CGFloat(450)
        isBottom = true
        willPositionChange = false
    }
    
    func setUpSettingTableViewData() {
        let location = Setting("위치", "location_detail", UIImage(named: "setting_location"))
        settingTableData[0].append(location)
        let tag = Setting("테그", "tag_detail", UIImage(named: "setting_tag"))
        settingTableData[0].append(tag)
        let journal = Setting("저널", "journal_detail", UIImage(named: "setting_journal"))
        settingTableData[0].append(journal)
        let date = Setting("날짜", "date_detail", UIImage(named: "setting_date"))
        settingTableData[0].append(date)
        if entry.favorite {
            let favorite = Setting("즐겨찾기", "즐겨찾기 해제", UIImage(named: "setting_like"))
            settingTableData[0].append(favorite)
        } else {
            let favorite = Setting("즐겨찾기", "즐겨찾기 설정", UIImage(named: "setting_dislike"))
            settingTableData[0].append(favorite)
        }
        
        let thisDay = Setting("이 날에", "thisday", UIImage(named: "setting_thisday"))
        settingTableData[1].append(thisDay)
        let today = Setting("이 날", "today", UIImage(named: "setting_today"))
        settingTableData[1].append(today)
        
        let weather = Setting("날씨", "~~", UIImage(named: "setting_weather"))
        settingTableData[2].append(weather)
        let device = Setting("일기를 작성한 기기", "iphone", UIImage(named: "setting_device"))
        settingTableData[2].append(device)
    }
    
    // MARK: - Actions
    
    @IBAction func showPhoto(_ sender: UIButton) {
        let pickerViewController = UIImagePickerController()
        pickerViewController.delegate = self
        pickerViewController.sourceType = .photoLibrary
        pickerViewController.allowsEditing = true
        present(pickerViewController, animated: true, completion: nil)
    }
    
    @IBAction func saveAndDismiss(_ sender: UIButton) {
        guard let content = textView.attributedText else {
            return
        }
        entry.contents = content
        
        let title: String
        let stringContent = content.string
        if stringContent.count > 1 {
            let start = stringContent.startIndex
            let end = stringContent.index(start, offsetBy: min(stringContent.count - 1, 40))
            title = String(stringContent[start...end])
        } else {
            title = "새로운 엔트리"
        }
        
        entry.title = title
        entry.favorite = false
        coreDataStack.saveContext()
        self.dismiss(animated: true, completion: nil)
    }
    
    func showAlert(title: String = "", message: String = "") {
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert)
        alertController.addAction(UIAlertAction(
            title: "확인",
            style: .default,
            handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Gesture action
    
    @objc func wasDragged(gestureRecognizer: UIPanGestureRecognizer) {
        if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
            let translation = gestureRecognizer.translation(in: self.view)
    
            if let targetView = gestureRecognizer.view {
                if targetView.center.y < topY {
                    targetView.center = CGPoint(x: targetView.center.x, y: topY)
                } else if targetView.center.y > bottomY {
                    targetView.center = CGPoint(x: targetView.center.x, y: bottomY)
                } else {
                    checkPosition(targetView: targetView)
                    targetView.center = CGPoint(
                        x: targetView.center.x,
                        y: targetView.center.y + translation.y
                    )
                }
            }
            gestureRecognizer.setTranslation(CGPoint(x: 0, y: 0), in: self.view)
        } else if gestureRecognizer.state == .ended {
            if let targetView = gestureRecognizer.view {
                changePosition(targetView: targetView)
            }
            gestureRecognizer.setTranslation(CGPoint(x: 0, y: 0), in: self.view)
        }
    }
    
    /// targetView가 기준을 넘었는지 판단
    func checkPosition(targetView: UIView) {
        if isBottom {
            if targetView.center.y > dragUpChangePointY {
                if willPositionChange {
                    willPositionChange = false
                    generator.impactOccurred()
                }
            } else {
                if willPositionChange == false {
                    willPositionChange = true
                    generator.impactOccurred()
                }
            }
        } else {
            if targetView.center.y < dragDownChangePointY {
                if willPositionChange {
                    willPositionChange = false
                    generator.impactOccurred()
                }
            } else {
                if willPositionChange == false {
                    willPositionChange = true
                    generator.impactOccurred()
                }
            }
        }
    }
    
    /// 조건에 따라 targetView의 위치 변경
    func changePosition(targetView: UIView) {
        if isBottom {
            if willPositionChange {
                UIView.animate(withDuration: 0.5) {
                    targetView.center = CGPoint(x: targetView.center.x, y: self.topY)
                }
                isBottom = false
            } else {
                UIView.animate(withDuration: 0.5) {
                    targetView.center = CGPoint(x: targetView.center.x, y: self.bottomY)
                }
            }
        } else {
            if willPositionChange {
                UIView.animate(withDuration: 0.5) {
                    targetView.center = CGPoint(x: targetView.center.x, y: self.bottomY)
                }
                isBottom = true
            } else {
                UIView.animate(withDuration: 0.5) {
                    targetView.center = CGPoint(x: targetView.center.x, y: self.topY)
                }
            }
        }
        willPositionChange = false
    }
}

// MARK: - Extention

extension EntryViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        insertAtTextViewCursor(attributedString: createAttributedString(with: image))
        picker.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func tapAndHideKeyboard(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    fileprivate func createAttributedString(with image: UIImage) -> NSAttributedString {
        let textAttachment = NSTextAttachment()
        textAttachment.image = image
        let oldWidth = textAttachment.image!.size.width
        let scaleFactor = oldWidth / (textView.frame.size.width - 10)
        textAttachment.image = UIImage(cgImage: textAttachment.image!.cgImage!, scale: scaleFactor, orientation: .up)
        let attrStringWithImage = NSAttributedString(attachment: textAttachment)
        return attrStringWithImage
    }
    
    fileprivate func insertAtTextViewCursor(attributedString: NSAttributedString) {
        guard let selectedRange = textView.selectedTextRange else {
            return
        }
        
        /// attributedString을 cursor위치에 넣는다.
        let cursorIndex = textView.offset(
            from: textView.beginningOfDocument,
            to: selectedRange.start
        )
        let mutableAttributedText = NSMutableAttributedString(
            attributedString: textView.attributedText
        )
        mutableAttributedText.insert(attributedString, at: cursorIndex)
        textView.attributedText = mutableAttributedText
    }
}

extension EntryViewController: UITextDragDelegate {
    
    func textDraggableView(
        _ textDraggableView: UIView & UITextDraggable,
        dragPreviewForLiftingItem item: UIDragItem,
        session: UIDragSession
    ) -> UITargetedDragPreview? {
        
        /// 드래그 프리뷰가 시작될 위치
        let target = UIDragPreviewTarget(
            container: textView,
            center: session.location(in: textDraggableView)
        )
        
        if isImageSelected {
            isImageSelected = false
            return UITargetedDragPreview(
                view: imagePreview,
                parameters: UIDragPreviewParameters(),
                target: target
            )
        } else {
            return UITargetedDragPreview(
                view: textPreview,
                parameters: UIDragPreviewParameters(),
                target: target
            )
        }
    }
    
    func textDraggableView(_ textDraggableView: UIView & UITextDraggable, itemsForDrag dragRequest: UITextDragRequest) -> [UIDragItem] {
        
        if let selectedText = textView.text(in: dragRequest.dragRange) {
            /// UITextRange를 NSRange로 변경
            let startOffset: Int = textView.offset(
                from: textView.beginningOfDocument,
                to: dragRequest.dragRange.start
            )
            let endOffset: Int = textView.offset(
                from: textDraggableView.beginningOfDocument,
                to: dragRequest.dragRange.end
            )
            let offsetRange = NSRange(location: startOffset, length: endOffset - startOffset)
            let substring = textView.attributedText.attributedSubstring(from: offsetRange)
            
            if let attachment = substring.attributes(
                at: 0,
                effectiveRange: nil
            )[NSAttributedString.Key.attachment] as? NSTextAttachment {
                ///선택된 것이 이미지인 경우
                imagePreview.image = attachment.image
                isImageSelected = true
            } else {
                ///선택된 것이 텍스트인 경우
                previewLabel.text = selectedText
            }
            
            let itemProvider = NSItemProvider(object: selectedText as NSString)
            return [UIDragItem(itemProvider: itemProvider)]
        } else {
            return []
        }
    }
}

extension EntryViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 5
        case 1:
            return 2
        case 2:
            return 2
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: settingIdentifier,
            for: indexPath
        ) as? EditorSettingTableViewCell else {
            preconditionFailure("EditorSettingTableViewCell reuse error!")
        }
        cell.setting = settingTableData[indexPath.section][indexPath.row]
        return cell
    }
}
