//
//  StatsView.swift
//  FitnessTracker
//
//  Created by Jannik Huschka on 02/11/23.
//

import SwiftUI

struct StatsView: View {
	@Binding var trainings: [OldTraining]
	
    var body: some View {
		NavigationStack {
			VStack {
				List($trainings) { $training in
					NavigationLink(destination: TrainingStatsView(training: $training)) {
						Text(training.name)
					}
				}
			}
			.navigationTitle("Satistacs")
		}
    }
}

#Preview {
	StatsView(trainings: .constant(OldTraining.sampleData))
}
