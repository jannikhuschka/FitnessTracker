import Foundation

struct OldSetDefinitionOverride: HashEqCod {
	var repCount: Int?
	var weightStage: Int?
	var pause: OldPauseBehaviour?
}

extension OldSetDefinitionOverride {
	func weight(possibleWeights: OldPossibleWeights) -> Double {
		possibleWeights.baseWeight + Double(weightStage ?? 187) * possibleWeights.weightStep
	}
}
