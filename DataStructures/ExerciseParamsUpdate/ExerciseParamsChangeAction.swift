import Foundation

protocol ExerciseParamsChangeAction: Hashable, Equatable {
	var changeType: ExerciseParamsUpdateType { get }
	var subExercise: String? { get }
	var setNumber: Int? { get }
	var valueBefore: Double { get set }
	var valueAfter: Double { get set }
	var formattedValueBefore: String { get }
	var formattedValueAfter: String { get }
	var executed: Bool { get set }
	func apply(_ exerciseDefinition: ExerciseDefinition) -> ExerciseDefinition
	func revert(_ exerciseDefinition: ExerciseDefinition) -> ExerciseDefinition
}

extension ExerciseParamsChangeAction {
	var description: String {
		var result = "Entire Exercise"
		if let subExercise, let setNumber {
			result = "\(subExercise), Set \(setNumber + 1)"
		} else if !(subExercise == nil && setNumber == nil) {
			result = "\(subExercise ?? ("Set " + String(setNumber! + 1)))"
		}
		return result
	}
}
