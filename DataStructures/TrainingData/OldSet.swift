import Foundation

struct OldSet : HashEqCod, Sendable {
	var reps: Int
	var weight: Double
}

extension OldSet {
	public func toSet() -> Set {
		.init(reps: reps, weight: weight)
	}
}

extension OldSet {
	public static var empty: OldSet { .init(reps: 0, weight: 0) }
	public static var sample1: OldSet { .init(reps: 1, weight: 100) }
	public static var sample2: OldSet { .init(reps: 5, weight: 70) }
	public static var sample3: OldSet { .init(reps: 10, weight: 50) }
	public static var sample4: OldSet { .init(reps: 12, weight: 45) }
	public static var sample5: OldSet { .init(reps: 15, weight: 30) }
}
