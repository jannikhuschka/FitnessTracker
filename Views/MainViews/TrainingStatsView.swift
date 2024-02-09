import SwiftUI
import Charts

struct TrainingStatsView: View {
	@Binding var training: Training
	
    var body: some View {
		NavigationStack {
			ScrollView {
				ForEach(training.exercises, id: \.self) { exDef in
					
					VStack(alignment: .leading) {
						Text(exDef.name)
							.font(.headline)
						
						if(training.sessions.isEmpty) {
							Text("No data yet")
						} else {
							ExerciseChart(exDef: exDef, sessions: training.sessions)
								.frame(height: 150)
						}
					}
					.padding(.vertical)
						
				}
				.padding()
			}
			.navigationTitle(training.name)
		}
    }
}

#Preview {
	TrainingStatsView(training: .constant(.sample1))
}
