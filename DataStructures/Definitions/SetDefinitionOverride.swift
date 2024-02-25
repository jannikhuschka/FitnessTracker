import Foundation
import SwiftData

@Model
class SetDefinitionOverride {
	var repCount: Int?
	var weightStage: Int?
	@Relationship var pause: PauseBehaviour?
	
	init(repCount: Int? = nil, weightStage: Int? = nil, pause: PauseBehaviour? = nil) {
		self.repCount = repCount
		self.weightStage = weightStage
		self.pause = pause
	}
}

extension SetDefinitionOverride {
	func weight(possibleWeights: PossibleWeights) -> Double {
		possibleWeights.baseWeight + Double(weightStage ?? 187) * possibleWeights.weightStep
	}
}
