import SwiftUI

struct TrainingListItem: View {
	@Binding var training: Training
	
	var body: some View {
		HStack {
			VStack(alignment: .leading) {
				Text(training.name)
					.font(.headline)
				Text("Trained \(training.sessions.count) times")
					.textCase(.uppercase)
					.font(.caption)
					.foregroundStyle(.gray)
			}
			
			Spacer()
			
			ValueDescriptionAbove(description: "Ex", value: String(training.exercises.count))
			
			ValueDescriptionAbove(description: "Legs", value: String(training.totalSets.formatted(.number)))
			
		}
		.padding()
	}
}

#Preview {
	TrainingListItem(training: .constant(.sample1))
}
