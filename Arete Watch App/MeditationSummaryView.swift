import SwiftUI
import Charts

struct HRDataPoint: Identifiable {
    let time: Double
    let bpm: Double
    var id: Double { time }
}

struct MeditationSummaryView: View {
    let points: [HRDataPoint]
    let onComplete: () -> Void

    private var minBPM: Double? { points.map { $0.bpm }.min() }
    private var avgPoints: [HRDataPoint] {
        var running: [HRDataPoint] = []
        var total = 0.0
        for (i, p) in points.enumerated() {
            total += p.bpm
            let avg = total / Double(i + 1)
            running.append(HRDataPoint(time: p.time, bpm: avg))
        }
        return running
    }

    var body: some View {
        VStack(spacing: 12) {
            Chart {
                if let min = minBPM {
                    RuleMark(y: .value("Min", min))
                        .foregroundStyle(.blue)
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [4]))
                        .annotation(position: .leading) {
                            Text("min \(Int(min))")
                                .font(.caption2)
                                .foregroundColor(.blue)
                        }
                }

                ForEach(points) { point in
                    PointMark(
                        x: .value("Time", point.time),
                        y: .value("BPM", point.bpm)
                    )
                    .foregroundStyle(.red)
                }

                ForEach(avgPoints) { point in
                    LineMark(
                        x: .value("Time", point.time),
                        y: .value("Avg", point.bpm)
                    )
                    .foregroundStyle(.green)
                    .lineStyle(StrokeStyle(lineWidth: 1))
                }
            }
            .chartXAxisLabel("Time (s)")
            .chartYAxisLabel("BPM")
            .frame(height: 100)

            Button("Complete") {
                onComplete()
            }
        }
        .padding()
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    MeditationSummaryView(points: [
        HRDataPoint(time: 0, bpm: 80),
        HRDataPoint(time: 10, bpm: 78),
        HRDataPoint(time: 20, bpm: 70)
    ]) {}
}
