import Foundation

struct OldExerciseOverrideChain: HashEqCod {
	var root: OldExerciseParams
	var overrides: [OldExerciseParamsOverride] = []
	
	init(root: OldExerciseParams, overrides: [OldExerciseParamsOverride?] = []) {
		self.root = root
		self.overrides = []
		for override in overrides {
			guard let override else { continue }
			self.overrides.append(override)
		}
	}

	var possibleWeights: OldPossibleWeights {
		overrides.last(where: { $0.possibleWeights != nil })?.possibleWeights ?? root.possibleWeights
	}
	
	var setCount: Int {
		overrides.last(where: { $0.setCount != nil })?.setCount ?? root.setCount
	}
	
	var setDefinition: OldSetDefinition {
		let repCount = overrides.last(where: { $0.setDefinition.repCount != nil })?.setDefinition.repCount ?? root.setDefinition.repCount
		let weightStage = overrides.last(where: { $0.setDefinition.weightStage != nil })?.setDefinition.weightStage ?? root.setDefinition.weightStage
		let pause = overrides.last(where: { $0.setDefinition.pause != nil })?.setDefinition.pause ?? root.setDefinition.pause
		return .init(repCount: repCount, weightStage: weightStage, pause: pause)
	}
	
	func levelFor(_ field: ParamField) -> String {
		var level: Int = 0
		switch(field) {
		case .possibleWeights:
			level = (overrides.lastIndex(where: { $0.possibleWeights != nil }) ?? -1) + 1
			break
		case .setCount:
			level = (overrides.lastIndex(where: { $0.setCount != nil }) ?? -1) + 1
			break
		case .repCount:
			level = (overrides.lastIndex(where: { $0.setDefinition.repCount != nil }) ?? -1) + 1
			break
		case .weightStage:
			level = (overrides.lastIndex(where: { $0.setDefinition.weightStage != nil }) ?? -1) + 1
			break
		case .pauseBehaviour:
			level = (overrides.lastIndex(where: { $0.setDefinition.pause != nil }) ?? -1) + 1
			break
		}
		return levelString(level)
	}
	
	func levelString(_ level: Int) -> String {
		switch(level) {
		case 0:
			return "Training"
		case 1:
			return overrides.count > 1 ? "Superset" : "Exercise"
		case 2:
			return "Exercise"
		default:
			return "Unknown"
		}
	}
}

extension OldExerciseOverrideChain {
	func with(_ override: OldExerciseParamsOverride?) -> OldExerciseOverrideChain {
		var result = OldExerciseOverrideChain(root: self.root, overrides: self.overrides)
		if let override {
			result.overrides.append(override)
		}
		return result
	}
	
	func withSet(_ set: OldSetDefinitionOverride) -> OldExerciseOverrideChain {
		var result = OldExerciseOverrideChain(root: self.root, overrides: self.overrides)
		result.overrides.append(.init(setDefinition: set))
		return result
	}
}

extension OldExerciseOverrideChain {
	public static var sample: OldExerciseOverrideChain { .init(root: .sample) }
}
