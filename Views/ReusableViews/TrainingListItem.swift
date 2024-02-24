import SwiftUI

struct TrainingListItem: View {
	@Binding var training: OldTraining
	
	var body: some View {
		HStack(spacing: 15) {
			ValueDescriptionBelow(description: "Trained \(training.sessions.count) times", value: training.name)
			
			Spacer()
			
			ValueDescriptionAbove(description: "Ex", value: String(training.totalExercises))
			
			ValueDescriptionAbove(description: "Legs", value: String(training.totalSets.formatted(.number)))
			
			ValueDescriptionAbove(description: "Weight", value: "\(training.totalMovedWeight.formatted(.number)) kg")
		}
		.padding(4)
	}
}

#Preview {
	TrainingListItem(training: .constant(.sample1))
}
