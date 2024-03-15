import Foundation

struct OldSetDefinition: HashEqCod {
	var repCount: Int
	var weightStage: Int
	var pause: OldPauseBehaviour
}

extension OldSetDefinition {
	func weight(possibleWeights: OldPossibleWeights) -> Double {
		possibleWeights.baseWeight + Double(weightStage) * possibleWeights.weightStep
	}
	
	public func toSetDefinition() -> SetDefinition {
		.init(repCount: repCount, weightStage: weightStage, pause: pause.toPauseBehaviour())
	}
}
