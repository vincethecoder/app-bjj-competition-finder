//
//  Date+Extensions.swift
//  PeteBJJCompFeed
//
//  Created by Kobe Sam on 10/20/24.
//

import Foundation

public extension Date {
    static func dateFromString(_ dateString: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        guard let date = dateFormatter.date(from: dateString) else {
            fatalError("invalid date from dateString: \(dateString)")
        }
        
        let components = Calendar.current.dateComponents([.year, .month, .day], from: date)
        guard let _year = components.year,
              let _month = components.month,
              let _day = components.day else {
            fatalError("invalid components dateString: \(dateString)")
        }
        
        return Calendar.current.date(from: DateComponents(year: _year, month: _month, day: _day))!
    }
}
