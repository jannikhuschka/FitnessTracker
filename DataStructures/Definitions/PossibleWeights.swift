import Foundation

struct PossibleWeights : HashEqCod {
	var baseWeight: Double
	var weightStep: Double
}

extension PossibleWeights {
	public static var sample1: PossibleWeights { .init(baseWeight: 0, weightStep: 5) }
}
