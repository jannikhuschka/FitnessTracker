import Foundation
import SwiftData

@Model
class Set {
	var reps: Int
	var weight: Double
	
	init(reps: Int, weight: Double) {
		self.reps = reps
		self.weight = weight
	}
}

extension Set {
	public static var empty: Set { .init(reps: 0, weight: 0) }
	public static var sample1: Set { .init(reps: 1, weight: 100) }
	public static var sample2: Set { .init(reps: 5, weight: 70) }
	public static var sample3: Set { .init(reps: 10, weight: 50) }
	public static var sample4: Set { .init(reps: 12, weight: 45) }
	public static var sample5: Set { .init(reps: 15, weight: 30) }
}
