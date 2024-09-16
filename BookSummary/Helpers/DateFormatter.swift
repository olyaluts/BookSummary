//
//  DateFormatter.swift
//  BookSummary
//
//  Created by Olya Lutsyk on 16.09.2024.
//

import Foundation

final class DateFormatter {
   static let dateComponentsFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }()

}
