//
//  NewExerciseView.swift
//  FitnessTracker
//
//  Created by Jannik Huschka on 26/10/23.
//

import SwiftUI

struct NewExerciseView: View {
	@State private var newExercise = ExerciseDefinition.empty
	@Binding var exerciseArray: [ExerciseDefinition]
	@Binding var isPresentingNewExerciseView: Bool
	@State var overrideChain: ExerciseOverrideChain
	@State var showAlert: Bool = false
	
    var body: some View {
		NavigationStack {
			ExerciseEditView(exercise: $newExercise, overrideChain: overrideChain)
				.navigationTitle("Add Training")
				.toolbar {
					ToolbarItem(placement: .cancellationAction) {
						Button("Dismiss") {
							isPresentingNewExerciseView = false
						}
					}
					ToolbarItem(placement: .confirmationAction) {
						Button("Add") {
							isPresentingNewExerciseView = false
							exerciseArray.append(newExercise)
						}
					}
				}
		}
    }
}

#Preview {
	NewExerciseView(exerciseArray: .constant([]), isPresentingNewExerciseView: .constant(true), overrideChain: .init(root: .sample))
}
