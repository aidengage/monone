//
//  Analytics.swift
//  spots
//
//  Created by Aiden Gage on 7/6/26.
//

import SwiftUI

enum TrendScope: String, CaseIterable, Identifiable {
    case day = "Day"
    case week = "Week"
    case month = "Month"
    case year = "Year"
    case lifetime = "Lifetime"
    
    var id: String { rawValue }
    
    // Current period's date range for this scope, relative to a reference date
    func dateRange(referenceDate: Date = .now, calendar: Calendar = .current) -> (start: Date, end: Date)? {
        switch self {
        case .day:
            return (calendar.startOfDay(for: referenceDate), referenceDate)
        case .week:
            guard let interval = calendar.dateInterval(of: .weekOfYear, for: referenceDate) else { return nil }
            return (interval.start, min(interval.end, .now))
        case .month:
            guard let interval = calendar.dateInterval(of: .month, for: referenceDate) else { return nil }
            return (interval.start, min(interval.end, .now))
        case .year:
            guard let interval = calendar.dateInterval(of: .year, for: referenceDate) else { return nil }
            return (interval.start, min(interval.end, .now))
        case .lifetime:
            return nil  // unbounded
        }
    }
}

