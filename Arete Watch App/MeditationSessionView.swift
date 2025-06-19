//
//  MeditationSessionView.swift
//  Arete
//
//  Created by Peyton Sherwood on 6/19/25.
//


import SwiftUI
import HealthKit
import Combine

struct MeditationSessionView: View {
    let durationMinutes: Int
    let onComplete: () -> Void

    @State private var timeRemaining: Int
    @State private var isActive = true

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    private let startDate = Date()

    init(durationMinutes: Int, onComplete: @escaping () -> Void) {
        self.durationMinutes = durationMinutes
        self._timeRemaining = State(initialValue: durationMinutes * 60)
        self.onComplete = onComplete
    }

    var body: some View {
        VStack(spacing: 12) {
            Text("Meditating")
                .font(.headline)

            Text(formatTime(timeRemaining))
                .font(.largeTitle)
                .monospacedDigit()

            Spacer()
        }
        .padding()
        .onReceive(timer) { _ in
            guard isActive else { return }
            if timeRemaining > 0 {
                timeRemaining -= 1
                if timeRemaining % 60 == 0 {
                    WKInterfaceDevice.current().play(.click)  // tap every minute
                }
            } else {
                endSession()
            }
        }
        .onDisappear {
            isActive = false
        }
    }

    private func endSession() {
        isActive = false
        WKInterfaceDevice.current().play(.success)
        logMindfulness(to: Date())
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            onComplete()
        }
    }

    private func logMindfulness(to endDate: Date) {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        let store = HKHealthStore()
        let type = HKCategoryType.categoryType(forIdentifier: .mindfulSession)!

        let sample = HKCategorySample(
            type: type,
            value: HKCategoryValue.notApplicable.rawValue,
            start: startDate,
            end: endDate
        )

        store.requestAuthorization(toShare: [type], read: []) { success, _ in
            guard success else { return }
            store.save(sample) { _, _ in }
        }
    }

    private func formatTime(_ seconds: Int) -> String {
        let min = seconds / 60
        let sec = seconds % 60
        return String(format: "%02d:%02d", min, sec)
    }
}
