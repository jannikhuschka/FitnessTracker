import Foundation

extension Training {
	public static var empty: Training {
		Training(name: "", defaults: .sample, exercises: [])
	}
	
	public static var sampleData: [Training] {
		var result = [
			Training.init(name: "Schwanztraining", defaults: .sample, exercises: [ .sample1, .sample2, .sample3, .sample4, .sample5 ]),
			Training.init(name: "Kraft", defaults: .sample, exercises: [ .sample2, .sample5, .sample1 ]),
			Training.init(name: "Oberkörper", defaults: .sample, exercises: [ .sample4 ]),
			Training.init(name: "Ausdauer", defaults: .sample, exercises: [ .sample3, .sample1, .sample4, .sample2 ]),
			Training.init(name: "Joggen", defaults: .sample, exercises: [ .sample4, .sample2 ]),
			Training.init(name: "Ganzkörper", defaults: .sample, exercises: [ .sample5, .sample3 ])
		]
		
		for i in 0...5 {
			result[i].sessions = TrainingSession.sampleData
		}
		
		return result
	}
	
	public static var sample1: Training { .init(name: "Massiv", defaults: .sample, exercises: [.sample1, .sample2, .sample3, .sample4, .sample5]) }
}

extension ExerciseParams {
	public static var sample: ExerciseParams { .init(possibleWeights: .init(baseWeight: 0, weightStep: 5), setCount: 3, setDefinition: .init(repCount: 15, weightStage: 5, pause: .init())) }
}

extension ExerciseParamsOverride {
	public static var empty: ExerciseParamsOverride { .init(setDefinition: .init()) }
}

extension ExerciseOverrideChain {
	public static var sample: ExerciseOverrideChain { .init(root: .sample) }
}

protocol TrainingComparator: SortComparator {
	func compare(_ lhs: Training, _ rhs: Training) -> ComparisonResult
	var description: String { get }
	var representingSymbol: String { get }
}

extension TrainingComparator {
	public static var all: [any TrainingComparator] {
		[TrainingDateComparator(), TrainingFrequencyComparator()]
	}
}

struct TrainingDateComparator: TrainingComparator {
	typealias Compared = Training
	var order: SortOrder = .forward
	func compare(_ lhs: Training, _ rhs: Training) -> ComparisonResult {
		if (lhs.lastTrainedDate < rhs.lastTrainedDate) {
			return order == .forward ? .orderedAscending : .orderedDescending
		}
		if (lhs.lastTrainedDate > rhs.lastTrainedDate) {
			return order == .forward ? .orderedDescending : .orderedAscending
		}
		return .orderedSame
	}
	
	var description: String = "By date"
	var representingSymbol: String { "clock" }
}

struct TrainingFrequencyComparator: TrainingComparator {
	typealias Compared = Training
	var order: SortOrder = .forward
	func compare(_ lhs: Training, _ rhs: Training) -> ComparisonResult {
		if(lhs.sessions.count < rhs.sessions.count) {
			return order == .forward ? .orderedAscending : .orderedDescending
		}
		if(lhs.sessions.count > rhs.sessions.count) {
			return order == .forward ? .orderedDescending : .orderedAscending
		}
		return .orderedSame
	}
	
	var description: String = "By frequency"
	var representingSymbol: String { "number" }
}

extension TrainingSession {
	func isCompatibleTo(_ definition: ExerciseDefinition) -> Bool {
		guard let exercise = exercises.fromDefinition(definition) else { return false }
		return exercise.sets.count == definition.setDefinitions.count
	}
	
	func isCompatibleToAndDoesntDivertFrom(_ definition: ExerciseDefinition) -> Bool {
//		if(!isCompatibleTo(definition)) { return false }
//		let exercise = exercises.fromDefinition(definition)!
//		let avgWeight = exercise.sets.reduce(0, {tmp, new in
//			tmp + new.weight
//		}) / Double(exercise.sets.count)
//		return abs((definition.params?.setDefinition.weight(possibleWeights: definition.params?.possibleWeights ?? .init(baseWeight: 0, weightStep: 5)) ?? 187) - avgWeight) < (definition.params?.possibleWeights.weightStep ?? 5)
		return false
	}
	
	public static var empty: TrainingSession {
		.init(training: .empty)
	}
	
	public static var sample1: TrainingSession {
		var result = TrainingSession(training: .sample1)
		for i in 0...max(Training.sample1.exercises.count - 1, 0) {
			result.exercises.append(.fromDefinition(definition: Training.sample1.exercises[i]))
			result.exercises[i].sets.append(.sample1)
			result.exercises[i].sets.append(.sample2)
		}
		result.date = Date(timeIntervalSinceNow: -10000)
		result.duration = .seconds(3600)
		return result
	}
	public static var sample2: TrainingSession {
		var result = TrainingSession(training: .sample1)
		for i in 0...max(Training.sample1.exercises.count - 1, 0) {
			result.exercises.append(.fromDefinition(definition: Training.sample1.exercises[i]))
			result.exercises[i].sets.append(.sample3)
			result.exercises[i].sets.append(.sample2)
			result.exercises[i].sets.append(.sample3)
			result.exercises[i].sets.append(.sample4)
			result.exercises[i].sets.append(.sample1)
		}
		result.date = Date(timeIntervalSinceNow: -100000)
		result.duration = .seconds(7200)
		return result
	}
	public static var sample3: TrainingSession {
		var result = TrainingSession(training: .sample1)
		for i in 0...max(Training.sample1.exercises.count - 1, 0) {
			result.exercises.append(.fromDefinition(definition: Training.sample1.exercises[i]))
			result.exercises[i].sets.append(.sample5)
		}
		result.date = Date(timeIntervalSinceNow: 100000)
		result.duration = .seconds(187)
		return result
	}
	
	public static var sampleData: [TrainingSession] {
		[ .sample1, .sample2, .sample3 ]
	}
}

extension Exercise {
	public static var empty: Exercise {
		Exercise(name: "Emptyexercise")
	}
	
	public static var sample1: Exercise {
		var result = Exercise(name: "Brustpresse")
		result.sets = [.sample1, .sample2, .sample3]
		return result
	}
	public static var sample2: Exercise {
		var result = Exercise(name: "Butterfly")
		result.sets = [.sample2, .sample4, .sample5, .sample1, .sample3]
		return result
	}
	public static var sample3: Exercise {
		var result = Exercise(name: "Beinpresse")
		result.sets = [.sample3, .sample5]
		return result
	}
	public static var sample4: Exercise {
		var result = Exercise(name: "Klimmzüge")
		result.sets = [.sample5]
		return result
	}
	public static var sample5: Exercise {
		var result = Exercise(name: "Dips")
		result.sets = [.sample4, .sample3, .sample2, .sample4]
		return result
	}
}

extension [Exercise] {
	func fromDefinition(_ definition: ExerciseDefinition) -> Exercise? {
		first(where: {$0.name == definition.name})
	}
}

extension ExerciseDefinition {
	public static var empty: ExerciseDefinition { .init(name: "", baseWeight: 0, weightStep: 5, setCount: 3, repCount: 15, weightStage: 5) }
	
	public static var sample1: ExerciseDefinition { .init(name: "Brustpresse", baseWeight: 0, weightStep: 5, setCount: 3, repCount: 15, weightStage: 5) }
	public static var sample2: ExerciseDefinition { .init(name: "Butterfly", baseWeight: 0, weightStep: 5, setCount: 4, repCount: 2, weightStage: 5) }
	public static var sample3: ExerciseDefinition { .init(name: "Beinpresse", baseWeight: 0, weightStep: 5, setCount: 5, repCount: 8, weightStage: 5) }
	public static var sample4: ExerciseDefinition { .init(name: "Klimmzüge", baseWeight: 0, weightStep: 5, setCount: 2, repCount: 12, weightStage: 5) }
	public static var sample5: ExerciseDefinition { .init(name: "Dips", baseWeight: 0, weightStep: 5, setCount: 1, repCount: 6, weightStage: 5) }
}

extension PossibleWeights {
	public static var sample1: PossibleWeights { .init(baseWeight: 0, weightStep: 5) }
}

extension Set {
	public static var empty: Set { .init(reps: 0, weight: 0) }
	public static var sample1: Set { .init(reps: 1, weight: 100) }
	public static var sample2: Set { .init(reps: 5, weight: 70) }
	public static var sample3: Set { .init(reps: 10, weight: 50) }
	public static var sample4: Set { .init(reps: 12, weight: 45) }
	public static var sample5: Set { .init(reps: 15, weight: 30) }
}

extension PauseMode {
	static func symbol(mode: PauseMode) -> String {
		switch(mode) {
		case(.fixedPauseDuration): return "pause"
		case(.fixedSetDuration): return "playpause"
		case(.infinitePause): return "infinity"
		}
	}
}
