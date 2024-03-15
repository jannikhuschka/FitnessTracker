import Foundation
import SwiftData

extension DataSchemaV1 {
	@Model
	class PossibleWeights {
		var baseWeight: Double
		var weightStep: Double
		
		init(baseWeight: Double, weightStep: Double) {
			self.baseWeight = baseWeight
			self.weightStep = weightStep
		}
	}
}

extension PossibleWeights {
	public static var sample1: PossibleWeights { .init(baseWeight: 0, weightStep: 5) }
}
