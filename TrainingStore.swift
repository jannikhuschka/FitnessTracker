import SwiftUI

@MainActor
class TrainingStore: ObservableObject {
	@Published var trainings: [Training] = []
	
	private static func fileURL() throws -> URL {
		try FileManager.default.url(for: .documentDirectory,
									in: .userDomainMask,
									appropriateFor: nil,
									create: false)
		.appendingPathComponent("trainings.data")
	}
	
	func load() async throws {
		let task = Task<[Training], Error> {
			let fileURL = try Self.fileURL()
			guard let data = try? Data(contentsOf: fileURL) else {
				return []
			}
			let allTrainings = try JSONDecoder().decode([Training].self, from: data)
			return allTrainings.sorted(by: {t1, t2 in
				t1.lastTrainedDate > t2.lastTrainedDate
			})
		}
		let trainings = try await task.value
		self.trainings = trainings
	}
	
	func save(trainings: [Training]) async throws {
		let task = Task {
			let data = try JSONEncoder().encode(trainings)
			let outfile = try Self.fileURL()
			try data.write(to: outfile)
		}
		_ = try await task.value
	}
}
