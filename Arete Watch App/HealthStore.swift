import Foundation
import HealthKit
import Combine

/// Protocol for injecting either real or mock health data
protocol HealthDataProviding: ObservableObject {
    var meditationDays: Int { get }
    var workoutDays:    Int { get }
    var sleepScore:     Int { get }
    func requestAuthorization()
    func logMindfulness(start: Date, end: Date)
}

final class HealthStore: HealthDataProviding {
    private let store = HKHealthStore()
    @Published var meditationDays = 0
    @Published var workoutDays    = 0
    @Published var sleepScore     = 0

    private let calendar = Calendar.current
    private var now: Date { Date() }
    private var weekAgo: Date {
        calendar.date(byAdding: .day, value: -6,
                     to: calendar.startOfDay(for: now))!
    }

    func requestAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        let meditation = HKObjectType.categoryType(forIdentifier: .mindfulSession)!
        let workout    = HKObjectType.workoutType()
        let sleep      = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
        let toRead: Set = [meditation, workout, sleep]

        store.requestAuthorization(toShare: [], read: toRead) { ok, err in
            if ok { self.updateAll() }
            else { print("HK auth failed:", err?.localizedDescription ?? "") }
        }
    }

    private func updateAll() {
        fetchMeditationDays()
        fetchWorkoutDays()
        fetchSleepScore()
    }

    private func fetchMeditationDays() {
        let type = HKObjectType.categoryType(forIdentifier: .mindfulSession)!
        let pred = HKQuery.predicateForSamples(withStart: weekAgo, end: now, options: [])
        let q = HKSampleQuery(sampleType: type, predicate: pred, limit: .max, sortDescriptors: nil) { _, results, _ in
            let days = Set((results as? [HKCategorySample] ?? [])
                            .map { self.calendar.startOfDay(for: $0.startDate) })
            DispatchQueue.main.async { self.meditationDays = days.count }
        }
        store.execute(q)
    }

    private func fetchWorkoutDays() {
        let type = HKObjectType.workoutType()
        let pred = HKQuery.predicateForSamples(withStart: weekAgo, end: now, options: [])
        let q = HKSampleQuery(sampleType: type, predicate: pred, limit: .max, sortDescriptors: nil) { _, results, _ in
            let days = Set((results as? [HKWorkout] ?? [])
                            .map { self.calendar.startOfDay(for: $0.startDate) })
            DispatchQueue.main.async { self.workoutDays = days.count }
        }
        store.execute(q)
    }

    private func fetchSleepScore() {
        let type = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
        let pred = HKQuery.predicateForSamples(withStart: weekAgo, end: now, options: [])
        let q = HKSampleQuery(sampleType: type, predicate: pred, limit: .max, sortDescriptors: nil) { _, results, _ in
            var durations: [Date: TimeInterval] = [:]
            (results as? [HKCategorySample] ?? []).forEach {
                guard $0.value == HKCategoryValueSleepAnalysis.asleepUnspecified.rawValue else { return }
                let day = self.calendar.startOfDay(for: $0.startDate)
                durations[day, default: 0] += $0.endDate.timeIntervalSince($0.startDate)
            }

            var totalScore = 0.0
            for i in 0..<7 {
                let day = self.calendar.startOfDay(
                    for: self.calendar.date(byAdding: .day, value: -i, to: self.now)!
                )
                let hours = (durations[day] ?? 0) / 3600
                let dayScore: Double
                if hours < 5 {
                    dayScore = 0
                } else if hours >= 8 {
                    dayScore = 100
                } else {
                    dayScore = ((hours - 5) / 3) * 100  // linearly scale from 5 to 8 hours
                }

                totalScore += dayScore
            }
            let avg = Int(totalScore / 7)
            DispatchQueue.main.async { self.sleepScore = avg }
        }
        store.execute(q)
    }
    
    func logMindfulness(start: Date, end: Date) {
      guard HKHealthStore.isHealthDataAvailable() else { return }
      let store = HKHealthStore()
      let type = HKCategoryType.categoryType(forIdentifier: .mindfulSession)!
      let sample = HKCategorySample(type: type,
                                    value: HKCategoryValue.notApplicable.rawValue,
                                    start: start,
                                    end:   end)
      store.save(sample) { _, _ in }
    }

}

/// Simple mock for SwiftUI previews
final class MockHealthStore: HealthDataProviding {
    @Published var meditationDays = 3
    @Published var workoutDays    = 5
    @Published var sleepScore     = 90

    func requestAuthorization() {
        // no-op
    }
    
    func logMindfulness(start: Date, end: Date) {
        print("Log to HK: start meditation: \(start), end: \(end)")
    }

}
