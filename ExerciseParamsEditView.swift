import SwiftUI

struct ExerciseParamsEditView: View {
	@Binding var params: ExerciseParams
	
    var body: some View {
		Form {
			Section(header: Text("Possible Weights")) {
				PossibleWeightsEditView(possibleWeights: $params.possibleWeights)
			}
			
			Section(header: Text("Set Targets")) {
				IntPickerView(description: "Sets", image: "list.bullet.indent", value: $params.setCount, range: 1...10)
				SetDefinitionEditView(definition: $params.setDefinition, possibleWeights: .sample1)
			}
		}
    }
}

#Preview {
	ExerciseParamsEditView(params: .constant(.sample))
}
