import Foundation

struct SetDefinition: HashEqCod {
	var repCount: Int
	var weightStage: Int
	var pause: PauseBehaviour
}

extension SetDefinition {
	func weight(possibleWeights: PossibleWeights) -> Double {
		possibleWeights.baseWeight + Double(weightStage) * possibleWeights.weightStep
	}
}
