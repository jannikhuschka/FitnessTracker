import Foundation

struct SetDefinitionOverride: HashEqCod {
	var repCount: Int?
	var weightStage: Int?
	var pause: PauseBehaviour?
}

extension SetDefinitionOverride {
	func weight(possibleWeights: PossibleWeights) -> Double {
		possibleWeights.baseWeight + Double(weightStage ?? 187) * possibleWeights.weightStep
	}
}
