//
//  ItemProperties.swift
//  spots
//
//  Created by Aiden Gage on 7/6/26.
//

import SwiftUI
import SwiftData

extension ItemData {
    private var todaySnapshot: DailySnapshot? {
        let today = Calendar.current.startOfDay(for: .now)
        return snapshots.first { $0.date == today }
    }
    
    var todayCount: Double {
        todaySnapshot?.count ?? 0
    }
    
    var lifetimeTotal: Double {
        snapshots.reduce(0) { $0 + $1.count }
    }
    
    var displayCount: Double {
        switch trackingType {
        case .daily: return todayCount
        case .lifetime: return lifetimeTotal
        }
    }
    
    func increment(context: ModelContext) {
        adjustToday(by: incrementStep, context: context)
    }
    
    func decrement(context: ModelContext) {
        adjustToday(by: -incrementStep, context: context)
    }
    
    // For custom amounts (e.g. logging exactly 1.75)
    func addCustomAmount(_ amount: Double, context: ModelContext) {
        adjustToday(by: amount, context: context)
    }
    
    private func adjustToday(by delta: Double, context: ModelContext) {
        if let snapshot = todaySnapshot {
            snapshot.count = max(0, snapshot.count + delta)
            snapshot.isSynced = false
        } else if delta > 0 {
            let snapshot = DailySnapshot(trackedItemId: id, date: .now, count: delta)
            context.insert(snapshot)
            snapshots.append(snapshot)
        }
    }
    
    func snapshots(from startDate: Date, to endDate: Date = .now) -> [DailySnapshot] {
        snapshots
            .filter { $0.date >= Calendar.current.startOfDay(for: startDate) && $0.date <= endDate }
            .sorted { $0.date < $1.date }
    }
    
    func total(for scope: TrendScope, referenceDate: Date = .now) -> Double {
        if scope == .lifetime { return lifetimeTotal }
        guard let range = scope.dateRange(referenceDate: referenceDate) else { return lifetimeTotal }
        return snapshots(from: range.start, to: range.end).reduce(0) { $0 + $1.count }
    }
    
    private func fillDailyWells(from start: Date, to end: Date, calender: Calendar) -> [ChartPoint] {
        var wells: [Date: Double] = [:]
        for snapshot in snapshots(from: start, to: end) {
            wells[snapshot.date, default: 0] += snapshot.count
        }
        
        var result: [ChartPoint] = []
        
        var current = calender.startOfDay(for: start)
        let endOfDay = calender.startOfDay(for: end)
        
        while current >= endOfDay {
            result.append(ChartPoint(date: current, count: wells[current] ?? 0))
            current = calender.date(byAdding: .day, value: 1, to: current)!
        }
        
        return result
    }
    
    private func fillMonthlyWells(from start: Date, to end: Date, calender: Calendar) -> [ChartPoint] {
        var wells: [Date: Double] = [:]
        for snapshot in snapshots(from: start, to: end) {
            wells[snapshot.date, default: 0] += snapshot.count
        }
        
        var result: [ChartPoint] = []
        
        var current = calender.dateInterval(of: .month, for: start)?.start ?? start
        let endOfMonth = calender.dateInterval(of: .month, for: end)?.end ?? end
        
        while current <= endOfMonth {
            result.append(ChartPoint(date: current, count: wells[current] ?? 0))
            current = calender.date(byAdding: .month, value: 1, to: current)!
        }
        
        return result
    }
}

struct ChartPoint: Identifiable {
    let id = UUID()
    let date: Date
    let count: Double
}

extension Double {
    // Formats as "2" instead of "2.0", but "1.5" or "0.25" stay as-is
    var trackerDisplay: String {
        if self.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", self)
        } else {
            // Trim trailing zeros but keep meaningful decimals
            var str = String(format: "%.2f", self)
            while str.hasSuffix("0") { str.removeLast() }
            if str.hasSuffix(".") { str.removeLast() }
            return str
        }
    }
}
