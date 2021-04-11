//
//  DateConverter.swift
//  mts_test_task
//
//  Created by  Matvey on 11.04.2021.
//

import Foundation

class DateConverter {
   static func dateToString(_ date: Date?) -> String {
        guard let date = date else { return "A long time ago" }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMMM yyyy"
    
        let dateText = dateFormatter.string(from: date)
        return dateText
    }
}
