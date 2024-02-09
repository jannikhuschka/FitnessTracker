//
//  SimpleSetRow.swift
//  FitnessTracker
//
//  Created by Jannik Huschka on 30/10/23.
//

import SwiftUI

struct SimpleExerciseRow: View {
	var exercise: Exercise
	
    var body: some View {
		HStack {
			ForEach(exercise.sets.indices, id: \.self) { i in
				ValueDescriptionBelow(description: "\(exercise.sets[i].weight.formatted(.number)) kg", value: "\(exercise.sets[i].reps)", alignment: .center, valFont: .title2 .bold())
					.frame(maxWidth: .infinity)
				if (i != exercise.sets.count - 1) {
					Spacer()
					Divider()
					Spacer()
				}
			}
		}
    }
}

#Preview {
	SimpleExerciseRow(exercise: .sample1)
}
