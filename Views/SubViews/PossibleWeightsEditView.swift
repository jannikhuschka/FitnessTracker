import SwiftUI

struct PossibleWeightsEditView: View {
	@Binding var possibleWeights: PossibleWeights
	
    var body: some View {
		VStack {
			NumberTextField(description: "Base Weight", image: "scalemass", value: $possibleWeights.baseWeight, additionalText: "kg")
			Divider()
			NumberTextField(description: "Weight Steps", image: "stairs", value: $possibleWeights.weightStep, additionalText: "kg")
		}
    }
}

#Preview {
	PossibleWeightsEditView(possibleWeights: .constant(.sample1))
}
