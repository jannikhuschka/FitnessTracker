import SwiftUI

struct OptionalPossibleWeightsEditView: View {
	@Binding var possibleWeights: PossibleWeights?
	var overrideChain: ExerciseOverrideChain
	
	var body: some View {
		if let possibleWeightsBinding = getBinding($possibleWeights) {
			PossibleWeightsEditView(possibleWeights: possibleWeightsBinding)
				.swipeActions(edge: .trailing, allowsFullSwipe: true) {
					Button("Remove", role: .destructive) {
						withAnimation {
							possibleWeights = nil
						}
					}
				}
		} else {
			HStack {
				Button("Weight Steps", systemImage: "plus.circle", action: {
					withAnimation {
						possibleWeights = PossibleWeights(baseWeight: 20, weightStep: 2.5)
					}
				})
				Spacer()
				Text("\(overrideChain.levelFor(.possibleWeights)): \(overrideChain.possibleWeights.baseWeight.formatted(.number))kg + \(overrideChain.possibleWeights.weightStep.formatted(.number))kg")
					.foregroundStyle(.gray)
			}
		}
	}
	
	func getBinding(_ binding: Binding<PossibleWeights?>) -> Binding<PossibleWeights>? {
		guard let wrappedValue = binding.wrappedValue else { return nil }
		return Binding(
			get: { wrappedValue },
			set: { binding.wrappedValue = $0 }
		)
	}
}

#Preview {
	OptionalPossibleWeightsEditView(possibleWeights: .constant(.sample1), overrideChain: .sample)
}
