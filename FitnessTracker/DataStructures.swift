import Foundation
import SwiftUI

typealias HashEqCod = Hashable & Equatable & Codable

struct Test {
	var name: String
}

struct Training : HashEqCod, Identifiable {
	var id: UUID = UUID()
	var name: String
	var defaults: ExerciseParams
	var exercises: [ExerciseDefinition]
	var sessions: [TrainingSession] = []
}

struct ExerciseParams: HashEqCod {
	var possibleWeights: PossibleWeights
	var setCount: Int
	var setDefinition: SetDefinition
}

struct ExerciseParamsOverride: HashEqCod {
	var possibleWeights: PossibleWeights?
	var setCount: Int?
	var setDefinition: SetDefinitionOverride
}

struct ExerciseOverrideChain {
	var root: ExerciseParams
	var overrides: [ExerciseParamsOverride] = []
	
	init(root: ExerciseParams, overrides: [ExerciseParamsOverride?] = []) {
		self.root = root
		self.overrides = []
		for override in overrides {
			guard let override else { continue }
			self.overrides.append(override)
		}
	}

	var possibleWeights: PossibleWeights {
		overrides.last(where: { $0.possibleWeights != nil })?.possibleWeights ?? root.possibleWeights
	}
	
	var setCount: Int {
		overrides.last(where: { $0.setCount != nil })?.setCount ?? root.setCount
	}
	
	var setDefinition: SetDefinition {
		let repCount = overrides.last(where: { $0.setDefinition.repCount != nil })?.setDefinition.repCount ?? root.setDefinition.repCount
		let weightStage = overrides.last(where: { $0.setDefinition.weightStage != nil })?.setDefinition.weightStage ?? root.setDefinition.weightStage
		let pause = overrides.last(where: { $0.setDefinition.pause != nil })?.setDefinition.pause ?? root.setDefinition.pause
		return .init(repCount: repCount, weightStage: weightStage, pause: pause)
	}
}

struct ExerciseDefinition: HashEqCod, Identifiable {
	var id: UUID
	var name: String
	var setCount: Int { overrides?.setCount ?? (isSuperset ? supersetMembers.count : setDefinitions.count) }
	var overrides: ExerciseParamsOverride?
	
	var setDefinitions: [SetDefinitionOverride] = []
	var isSimple: Bool { setDefinitions.isEmpty && !isSuperset }
	
	var supersetMembers: [ExerciseDefinition] = []
	var isSuperset: Bool { !isSupersetMember && !supersetMembers.isEmpty }
	let isSupersetMember: Bool
	
	init(id: UUID = UUID(), name: String, baseWeight: Double, weightStep: Double, setCount: Int, repCount: Int, weightStage: Int, pauseMode: PauseMode = .fixedPauseDuration, pauseModeDuration: Int = 60, isSupersetMember: Bool = false) {
		self.id = id
		self.name = name
		self.overrides = .init(possibleWeights: .init(baseWeight: baseWeight, weightStep: weightStep), setCount: setCount, setDefinition: .init(repCount: repCount, weightStage: weightStage, pause: .init(mode: pauseMode, duration: pauseModeDuration)))
		self.isSupersetMember = isSupersetMember
	}
	
	init(id: UUID = UUID(), name: String, isSupersetMember: Bool = false) {
		self.id = id
		self.name = name
		self.isSupersetMember = isSupersetMember
	}
}

struct SetDefinition: HashEqCod {
	var repCount: Int
	var weightStage: Int
	var pause: PauseBehaviour
}

struct SetDefinitionOverride: HashEqCod {
	var repCount: Int?
	var weightStage: Int?
	var pause: PauseBehaviour?
}

struct PossibleWeights : HashEqCod {
	var baseWeight: Double
	var weightStep: Double
}

struct PauseBehaviour : HashEqCod {
	var mode: PauseMode = .fixedPauseDuration
	var duration: Int = 60
}

enum PauseMode: String, CaseIterable, HashEqCod {
	case fixedPauseDuration = "Pause Duration"
	case fixedSetDuration = "Set Duration"
	case infinitePause = "Infinite Pause"
}

struct TrainingSession : HashEqCod {
	var trainingName: String
	var number: Int
	var date: Date
	var duration: Duration?
	var exercises: [Exercise]
	
	init(training: Training) {
		self.trainingName = training.name
		self.number = training.sessions.count + 1
		self.date = Date()
		self.exercises = []
	}
}

struct Exercise: HashEqCod, Sendable {
	var name: String
	var sets: [Set] = []
}

struct Set : HashEqCod, Sendable {
	var reps: Int
	var weight: Double
}

struct ExerciseHierarchy : HashEqCod {
	var name: String
	var number: Int = 0
	var setCount: Int = 0
	var repCount: Int = 0
	var weight: Double = 0
	var children: [ExerciseHierarchy]?
	
	init(name: String) {
		self.name = name
	}
	
	init(definition: ExerciseDefinition, number: Int = 0) {
		self.name = definition.name
		self.number = number
		self.setCount = definition.setCount
		self.repCount = definition.overrides?.setDefinition.repCount ?? 187
		self.weight = definition.overrides?.setDefinition.weight(possibleWeights: definition.overrides?.possibleWeights ?? .init(baseWeight: 187, weightStep: 187)) ?? 187
	}
	
	static func fromTraining(_ training: Training) -> ExerciseHierarchy {
		var result = ExerciseHierarchy(name: "Exercises")
		result.children = []
		for i in training.exercises.indices {
			result.children!.append(.init(definition: training.exercises[i], number: i + 1))
		}
		return result
	}
}
