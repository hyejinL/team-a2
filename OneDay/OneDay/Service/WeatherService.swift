//
//  WeatherService.swift
//  OneDayProto
//
//  Created by Wongeun Song on 2019. 1. 31..
//  Copyright © 2019년 teamA2. All rights reserved.
//

import Foundation

class WeatherService {
    
    // MARK: - Properties
    static let service = WeatherService()
    private let baseURL = "https://api.darksky.net/forecast"
    private let APIKey = "9deaa3b4d2ba8a4a3772c6d6015dba6b"
    
    // MARK: - Methods
    
    /**
     Darksky API를 활용하여 매개변수에 따른 날씨정보 요청
     
     - Parameters:
        - latitude: 날씨를 가져오려는 위치의 위도
        - longitude: 날씨를 가져오려는 위치의 경도
        - date: 날씨를 가져오려는 날짜
     */
    func weather(
        latitude: Double,
        longitude: Double,
        date: Date,
        success: @escaping (APIWeather) -> Void,
        errorHandler: @escaping () -> Void
        ) {
        let unixTimeStamp = Int(date.timeIntervalSince1970)
        let urlString  = "\(baseURL)/\(APIKey)/\(latitude),\(longitude),\(unixTimeStamp)"
        guard let url: URL = URL(string: urlString) else { return }
        NetworkProvider.request(url: url, success: success, errorHandler: errorHandler)
    }
}
