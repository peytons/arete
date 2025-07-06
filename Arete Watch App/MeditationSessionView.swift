import SwiftUI
import HealthKit
import WatchKit   // for WKInterfaceDevice
import Combine

@MainActor
struct MeditationSessionView<Store: HealthDataProviding>: View {
    @ObservedObject var healthStore: Store
    let durationMinutes: Int
    let useHeartRateMode: Bool
    let onComplete: ([Double]) -> Void

    // Timer mode state
    @State private var timeRemaining: Int
    @State private var isActive = true

    // HR mode state
    @State private var currentHR: Double = 0
    @State private var hrSamples: [Double] = []
    private let stabilityThreshold = 3.0    // ±3 BPM
    private let requiredStableTime = 30     // seconds

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    private let startDate = Date()

    init(healthStore: Store,
         durationMinutes: Int,
         useHeartRateMode: Bool,
         onComplete: @escaping ([Double]) -> Void)
    {
        self._healthStore       = ObservedObject(wrappedValue: healthStore)
        self.durationMinutes    = durationMinutes
        self.useHeartRateMode   = useHeartRateMode
        self.onComplete         = onComplete
        self._timeRemaining     = State(initialValue: durationMinutes * 60)
    }

    var body: some View {
        VStack(spacing: 12) {
            Text(useHeartRateMode ? "Stabilizing…" : "Meditating")
                .font(.headline)

            if useHeartRateMode {
                Text(String(format: "%.0f BPM", currentHR))
                    .font(.largeTitle)
                    .monospacedDigit()
                ProgressView(
                    value: min(Double(hrSamples.count), Double(requiredStableTime)),
                    total: Double(requiredStableTime)
                )
            } else {
                Text(formatTime(timeRemaining))
                    .font(.largeTitle)
                    .monospacedDigit()
            }

            Spacer()
        }
        .padding()
        .onAppear {
            playHaptic(.click)
            if useHeartRateMode { startHRQuery() }
        }
        .onReceive(timer) { _ in
            guard isActive, !useHeartRateMode else { return }
            tickTimer()
        }
        .onDisappear {
            isActive = false
        }
    }

    // MARK: - Timer Mode

    private func tickTimer() {
        if timeRemaining > 0 {
            timeRemaining -= 1
            if timeRemaining % 60 == 0 {
                playHaptic(.click)
            }
        } else {
            endSession()
        }
    }

    // MARK: - Heart-Rate Mode

    private func startHRQuery() {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        let store = HKHealthStore()
        guard let type = HKQuantityType.quantityType(forIdentifier: .heartRate) else { return }

        let predicate = HKQuery.predicateForSamples(
            withStart: startDate, end: nil, options: []
        )
        let query = HKAnchoredObjectQuery(
            type: type, predicate: predicate, anchor: nil, limit: HKObjectQueryNoLimit
        )
        { _, samples, _, _, _ in
            Task { @MainActor in
                self.process(samples)
            }
        }
        query.updateHandler = { _, samples, _, _, _ in
            Task { @MainActor in
                self.process(samples)
            }
        }
        store.execute(query)
    }

    private func process(_ samples: [HKSample]?) {
        guard let qty = samples as? [HKQuantitySample] else { return }
        DispatchQueue.main.async {
            for s in qty {
                let hr = s.quantity
                    .doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
                currentHR = hr
                hrSamples.append(hr)
                if hrSamples.count > requiredStableTime {
                    hrSamples.removeFirst(hrSamples.count - requiredStableTime)
                }
                if hrSamples.count >= requiredStableTime,
                   let minHR = hrSamples.min(),
                   let maxHR = hrSamples.max(),
                   (maxHR - minHR) <= stabilityThreshold
                {
                    endSession()
                    break
                }
            }
        }
    }

    // MARK: - Session Completion

    private func endSession() {
        guard isActive else { return }
        isActive = false
        playHaptic(.success)
        healthStore.logMindfulness(start: startDate, end: Date())
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            onComplete(hrSamples)
        }
    }

    // MARK: - Haptic & Logging

    private func playHaptic(_ type: WKHapticType) {
        print("🔔 Playing haptic: \(type)")
        WKInterfaceDevice.current().play(type)
    }

//    private func logMindfulness(to endDate: Date) {
//        guard HKHealthStore.isHealthDataAvailable(),
//              let store = HKHealthStore(),
//              let type  = HKCategoryType.categoryType(forIdentifier: .mindfulSession)
//        else { return }
//
//        let sample = HKCategorySample(
//            type:  type,
//            value: HKCategoryValue.notApplicable.rawValue,
//            start: startDate,
//            end:   endDate
//        )
//        store.requestAuthorization(toShare: [type], read: []) { _, _ in
//            store.save(sample) { _, _ in }
//        }
//    }

    // MARK: - Utils

    private func formatTime(_ seconds: Int) -> String {
        let m = seconds / 60, s = seconds % 60
        return String(format: "%02d:%02d", m, s)
    }
}

