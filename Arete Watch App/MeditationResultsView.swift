import SwiftUI
import Charts

struct MeditationResultsView: View {
    let hrSamples: [Double]
    let onComplete: () -> Void

    struct DataPoint: Identifiable {
        let id: Int
        let bpm: Double
        let avg: Double
    }

    private var data: [DataPoint] {
        var runningTotal = 0.0
        return hrSamples.enumerated().map { idx, bpm in
            runningTotal += bpm
            let avg = runningTotal / Double(idx + 1)
            return DataPoint(id: idx, bpm: bpm, avg: avg)
        }
    }

    private var minHR: Double { hrSamples.min() ?? 0 }

    var body: some View {
        VStack(spacing: 12) {
            Chart(data) { point in
                PointMark(
                    x: .value("Time", point.id),
                    y: .value("BPM", point.bpm)
                )
                .foregroundStyle(.red)
                .symbolSize(20)

                LineMark(
                    x: .value("Time", point.id),
                    y: .value("Avg", point.avg)
                )
                .interpolationMethod(.monotone)
                .foregroundStyle(.gray)
                .lineStyle(StrokeStyle(lineWidth: 2))
            }
            .chartYAxis {
                AxisMarks(position: .leading)
            }
            .chartYScale(domain: (minHR - 10)...((hrSamples.max() ?? 0) + 10))
            .frame(height: 120)
            .overlay {
                RuleMark(y: .value("Min", minHR))
                    .foregroundStyle(.blue)
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [4]))
                    .annotation(position: .topTrailing) {
                        Text("Min \(Int(minHR))")
                            .font(.footnote)
                            .foregroundStyle(.blue)
                    }
            }

            Button("Complete") {
                onComplete()
            }
        }
        .padding()
    }
}

#Preview {
    MeditationResultsView(hrSamples: [70, 68, 65, 64, 63, 62, 62, 63, 64]) {}
}
