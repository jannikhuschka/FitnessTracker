import Foundation

struct OldTraining : HashEqCod, Identifiable {
	var id: UUID = UUID()
	var name: String
	var defaults: OldExerciseParams
	var exercises: [OldExerciseDefinition] = []
	var sessions: [OldTrainingSession] = []
}

extension OldTraining {
	public var totalSets: Int {
		exercises.reduce(0, { result, exercise in
			return result + exercise.setCount(overrideChain: .init(root: defaults, overrides: [exercise.overrides]))
		})
	}
	
	public var totalExercises: Int {
		exercises.reduce(0, { $0 + ($1.isSuperset ? $1.supersetMembers!.count : 1) })
	}
	
	public var lastTrainedDate: Date {
		sessions.last?.date ?? .distantPast
	}
	
	public var totalMovedWeight: Double {
		sessions.reduce(0, {tmp, session in
			tmp + session.totalMovedWeight
		})
	}
	
	public var validity: String {
		if(name.isEmpty) { return "Please enter a name for the training." }
		if(exercises.isEmpty) { return "Please add at least one exercise to the training." }
		return "OK"
	}
}

extension OldTraining {
	public static var empty: OldTraining {
		OldTraining(name: "", defaults: .sample, exercises: [])
	}
	
	public static var sampleData: [OldTraining] {
		var result = [
			OldTraining.init(name: "Schwanztraining", defaults: .sample, exercises: [ .sample1, .sample2, .sample3, .sample4, .sample5 ]),
			OldTraining.init(name: "Kraft", defaults: .sample, exercises: [ .sample2, .sample5, .sample1 ]),
			OldTraining.init(name: "Oberkörper", defaults: .sample, exercises: [ .sample4 ]),
			OldTraining.init(name: "Ausdauer", defaults: .sample, exercises: [ .sample3, .sample1, .sample4, .sample2 ]),
			OldTraining.init(name: "Joggen", defaults: .sample, exercises: [ .sample4, .sample2 ]),
			OldTraining.init(name: "Ganzkörper", defaults: .sample, exercises: [ .sample5, .sample3 ])
		]
		
		for i in 0...5 {
			result[i].sessions = OldTrainingSession.sampleData
		}
		
		return result
	}
	
	public static var standard: OldTraining {
		let defaults = OldExerciseParams(possibleWeights: .init(baseWeight: 0, weightStep: 5), setCount: 3, setDefinition: .init(repCount: 15, weightStage: 8, pause: .init(mode: .fixedSetDuration, duration: 180)))
		var result = OldTraining(name: "King Day", defaults: defaults)
		result.exercises.append(.init(name: "Brustpresse", overrides: .init(setDefinition: .init(weightStage: 10))))
		result.exercises.append(.init(name: "Butterfly", overrides: .init(setDefinition: .init(weightStage: 8))))
		result.exercises.append(.init(name: "Schultermaschine", overrides: .init(setDefinition: .init(weightStage: 5))))
		result.exercises.append(.init(name: "Bauchpresse", overrides: .init(setDefinition: .init(weightStage: 10))))
		result.exercises.append(.init(name: "Dips", overrides: .init(setDefinition: .init(weightStage: 5))))
		result.exercises.append(.init(name: "Seitenheben", overrides: .init(setDefinition: .init(weightStage: 4))))
		result.exercises.append(.init(name: "Beinheben", overrides: .init(setDefinition: .init(weightStage: 0))))
		result.exercises.append(.init(name: "Trizepsmaschine", overrides: .init(setDefinition: .init(weightStage: 12))))
		
		return result
	}
	
	public static var sample1: OldTraining { .init(name: "Massiv", defaults: .sample, exercises: [.sample1, .sample2, .sample3, .sample4, .sample5]) }
}
