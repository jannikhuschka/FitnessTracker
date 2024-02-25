import Foundation
import SwiftData

@Model
class ExerciseDefinition {
	var id: UUID
	var name: String
	func setCount(overrideChain: ExerciseOverrideChain) -> Int {
		if(isSuperset) {
			return supersetMembers!.reduce(0, { $0 + $1.setCount(overrideChain: overrideChain.with($1.overrides)) })
		}
		if(isSimple) {
			return overrideChain.setCount
		}
		return setDefinitions.count
	}
	var overrides: ExerciseParamsOverride?
	
	var setDefinitions: [SetDefinitionOverride] = []
	var isSimple: Bool { setDefinitions.isEmpty && !isSuperset }
	
	var supersetMembers: [ExerciseDefinition]? = nil
	var isSuperset: Bool { !isSupersetMember && supersetMembers != nil }
	let isSupersetMember: Bool
	
	init(id: UUID = UUID(), name: String, baseWeight: Double, weightStep: Double, setCount: Int, repCount: Int, weightStage: Int, pauseMode: PauseMode = .fixedPauseDuration, pauseModeDuration: Int = 60, isSupersetMember: Bool = false) {
		self.id = id
		self.name = name
		self.overrides = .init(possibleWeights: .init(baseWeight: baseWeight, weightStep: weightStep), setCount: setCount, setDefinition: .init(repCount: repCount, weightStage: weightStage, pause: .init(mode: pauseMode, duration: pauseModeDuration)))
		self.isSupersetMember = isSupersetMember
	}
	
	init(id: UUID = UUID(), name: String, overrides: ExerciseParamsOverride? = nil, isSupersetMember: Bool = false) {
		self.id = id
		self.name = name
		self.overrides = overrides
		self.isSupersetMember = isSupersetMember
	}
}

extension ExerciseDefinition {
	static func forTraining(training: Training, name: String, isSuperset: Bool = false) -> ExerciseDefinition {
		let defaults = training.defaults
		return .init(name: name, baseWeight: defaults.possibleWeights.baseWeight, weightStep: defaults.possibleWeights.weightStep, setCount: 3, repCount: defaults.setDefinition.repCount, weightStage: defaults.setDefinition.weightStage)
	}
	
	func setDefinition(number: Int, overrideChain: ExerciseOverrideChain) -> SetDefinition {
		if(isSimple || number >= setCount(overrideChain: overrideChain)) { return overrideChain.setDefinition }
		return overrideChain.withSet(setDefinitions[number]).setDefinition
	}
	
	func isCompletedBy(_ exercise: Exercise?, overrideChain: ExerciseOverrideChain) -> Bool {
		guard let exercise else { return false }
		if(isSimple) {
			return setCount(overrideChain: overrideChain) <= exercise.sets.count
		}
		if(isSuperset) {
			return supersetMembers!.allSatisfy( { member in
				member.isCompletedBy(exercise.subExercises.first(where: { $0.name == member.name }), overrideChain: overrideChain.with(member.overrides))
			})
		}
		return setDefinitions.count <= exercise.sets.count
	}
	
	var typeSymbol: String {
		if isSuperset { return "square.stack.3d.up" }
		if isSimple { return "line.3.horizontal" }
		return "lineweight"
	}
	
	public func maxSetCount(sessions: [TrainingSession]) -> Int {
		sessions.map({
			$0.getExerciseFrom(self)?.sets.count ?? 0
		}).max() ?? 0
	}
}

extension [ExerciseDefinition] {
	func completedBy(_ exercises: [Exercise], overrideChain: ExerciseOverrideChain) -> [ExerciseDefinition] {
		return self.filter({ def in
			def.isCompletedBy(exercises.first(where: { $0.name == def.name }), overrideChain: overrideChain.with(def.overrides)) })
	}
	
	func notCompletedBy(_ exercises: [Exercise], overrideChain: ExerciseOverrideChain) -> [ExerciseDefinition] {
		return self.filter({ def in
			!def.isCompletedBy(exercises.first(where: { $0.name == def.name }), overrideChain: overrideChain.with(def.overrides)) })
	}
}

extension ExerciseDefinition {
	public static var empty: ExerciseDefinition { .init(name: "") }
	
	public static var sample1: ExerciseDefinition { .init(name: "Brustpresse", baseWeight: 0, weightStep: 5, setCount: 3, repCount: 15, weightStage: 5) }
	public static var sample2: ExerciseDefinition { .init(name: "Butterfly", baseWeight: 0, weightStep: 5, setCount: 4, repCount: 2, weightStage: 5) }
	public static var sample3: ExerciseDefinition { .init(name: "Beinpresse", baseWeight: 0, weightStep: 5, setCount: 5, repCount: 8, weightStage: 5) }
	public static var sample4: ExerciseDefinition { .init(name: "Klimmzüge", baseWeight: 0, weightStep: 5, setCount: 2, repCount: 12, weightStage: 5) }
	public static var sample5: ExerciseDefinition { .init(name: "Dips", baseWeight: 0, weightStep: 5, setCount: 1, repCount: 6, weightStage: 5) }
}
