//
//  Constants.swift
//  OneDay
//
//  Created by juhee on 15/02/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//

import UIKit

struct Constants {
    // EntryViewController
    static let maximumNumberOfEntryTitle: Int = 200
    static let imageScaleConstantForTextView: CGFloat = 20
    static let timelineThumbnailImageCellHeight: CGFloat = 96
    static let timelineInfoImageLabelViewsHeight: CGFloat = 12
    static let screenSize: CGFloat = UIScreen.main.bounds.width
    static let sideMenuWidth: CGFloat = screenSize * 0.8
    static let minimumRecentKeywordsCount: Int = 3
    static let automaticNextJournalIndex: Int = -1
    static let sideWidth = UIScreen.main.bounds.width*0.75
    
    // Notification
    static let tabBarItemTouchCountsNotification = NSNotification.Name("scrollToTodayCalendar")
}
