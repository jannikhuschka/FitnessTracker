import SwiftUI

struct OptionalPossibleWeightsEditView: View {
	@Binding var possibleWeights: PossibleWeights?
	
	var body: some View {
		if let possibleWeightsBinding = Binding<PossibleWeights>($possibleWeights) {
			PossibleWeightsEditView(possibleWeights: possibleWeightsBinding)
				.swipeActions(edge: .trailing, allowsFullSwipe: true) {
					Button("Delete Weights Override", role: .destructive) {
						withAnimation {
							possibleWeights = nil
						}
					}
				}
		} else {
			Button("Add Weights Override", systemImage: "plus.circle", action: {
				withAnimation {
					possibleWeights = PossibleWeights(baseWeight: 20, weightStep: 2.5)
				}
			})
		}
	}
}

#Preview {
	OptionalPossibleWeightsEditView(possibleWeights: .constant(.sample1))
}
