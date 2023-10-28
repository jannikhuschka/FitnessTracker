import SwiftUI

struct ExerciseParamsOverrideEditView: View {
	@Binding var override: ExerciseParamsOverride
	@Binding var exercise: ExerciseDefinition
	var overrideChain: ExerciseOverrideChain
	
	var body: some View {
		Form {
			Section(header: Text("Possible Weights")) {
				OptionalPossibleWeightsEditView(possibleWeights: $override.possibleWeights)
			}
			
			Section(header: Text("Set Targets")) {
				if(exercise.isSimple) {
					if let setCountBinding = Binding<Int>($override.setCount) {
						IntPickerView(description: "Sets", image: "list.bullet.indent", value: setCountBinding, range: 1...10)
							.swipeActions(edge: .trailing, allowsFullSwipe: true) {
								Button("Reset", role: .destructive) {
									override.setCount = nil
								}
							}
					} else {
						Button("Add Set Count Override", systemImage: "plus.circle") {
							override.setCount = overrideChain.setCount
						}
					}
				} else {
					Button("Remove Individual Sets", systemImage: "arrow.counterclockwise", role: .destructive) {
						exercise.setDefinitions = []
						override.setCount = overrideChain.setCount
					}
				}
				SetDefinitionOverrideEditView(override: $override.setDefinition, overrideChain: overrideChain)
			}
		}
	}
}

#Preview {
	ExerciseParamsOverrideEditView(override: .constant(.empty), exercise: .constant(.empty), overrideChain: .sample)
}
