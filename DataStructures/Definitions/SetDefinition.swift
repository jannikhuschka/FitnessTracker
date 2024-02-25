import Foundation
import SwiftData

@Model
class SetDefinition {
	var repCount: Int
	var weightStage: Int
	var pause: PauseBehaviour
	
	init(repCount: Int, weightStage: Int, pause: PauseBehaviour) {
		self.repCount = repCount
		self.weightStage = weightStage
		self.pause = pause
	}
}

extension SetDefinition {
	func weight(possibleWeights: PossibleWeights) -> Double {
		possibleWeights.baseWeight + Double(weightStage) * possibleWeights.weightStep
	}
}
