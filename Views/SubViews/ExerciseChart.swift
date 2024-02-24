//
//  ExerciseChart.swift
//  FitnessTracker
//
//  Created by Jannik Huschka on 04/11/23.
//

import SwiftUI
import Charts

struct ExerciseChart: View {
	var exDef: OldExerciseDefinition
	var sessions: [OldTrainingSession]
	
	var body: some View {
		Chart {
			ForEach(sessions, id: \.self) { session in
				if let sets = session.getExerciseFrom(exDef)?.sets {
					ForEach(sets.indices, id: \.self) { i in
						LinePointMark(x: .value("Session", session.number), y: .value("Reps", sets[i].reps))
							.symbol(by: .value("Set Number", "Set \(i + 1)"))
//							.foregroundStyle(by: .value("Set Number", "Set \(i + 1)"))
					}
				}
			}
		}
//		.chartForegroundStyleScale(ChartColors.legend(exDef.maxSetCount(sessions: sessions)))
//		.chartForegroundStyleScale([
//			"Set 1": .green, "Set 2": .blue, "Set 3": .pink, "Set 4": .red, "Set 5": .yellow
//		])
		.chartXScale(domain: 1...sessions.count)
		.chartXAxis {
			AxisMarks(values: sessions.map({ $0.number })) { value in
				AxisValueLabel() {
					if let i = value.as(Int.self) {
						Text("\(sessions[i-1].date.formatted(.dateTime.day().month()))")
					}
				}
				
				AxisGridLine()
				AxisTick()
			}
		}
		.chartYScale(domain: .automatic(includesZero: false))
//		.chartYAxis {
//			AxisMarks(values: [0.0, 500.0, 1000.0]) { value in //[0.0, 500.0, 1000.0]
//				AxisValueLabel() {
//					if let d = value.as(Double.self) {
//						Text("\(d.formatted(.number)) kg")
//					}
//				}
//				
//				AxisGridLine()
//				AxisTick()
//			}
//		}
	}
}

#Preview {
	ExerciseChart(exDef: .sample1, sessions: [OldTrainingSession.sample1, OldTrainingSession.sample2])
}
