import SwiftUI

@main
struct FitnessTrackerApp: App {
	@StateObject private var store = TrainingStore()
	@State private var errorWrapper: ErrorWrapper?
	
	var body: some Scene {
		WindowGroup {
			StartView(trainings: $store.trainings) {
				Task {
					do {
						try await store.save(trainings: store.trainings)
					} catch {
						errorWrapper = ErrorWrapper(error: error,
													guidance: "Try again later.")
					}
				}
			}
			.task {
				do {
					try await store.load()
				} catch {
					errorWrapper = ErrorWrapper(error: error,
												guidance: "FitnessTracker will load sample data and continue.")
				}
			}
			.sheet(item: $errorWrapper) {
				store.trainings = Training.sampleData
			} content: { wrapper in
				ErrorView(errorWrapper: wrapper)
			}
		}
	}
}
