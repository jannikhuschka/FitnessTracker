import Foundation

struct OldPossibleWeights : HashEqCod {
	var baseWeight: Double
	var weightStep: Double
}

extension OldPossibleWeights {
	public static var sample1: OldPossibleWeights { .init(baseWeight: 0, weightStep: 5) }
}
