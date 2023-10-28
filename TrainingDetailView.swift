//
//  TrainingDetailView.swift
//  FitnessTracker
//
//  Created by Jannik Huschka on 17/10/23.
//

import SwiftUI

struct TrainingDetailView: View {
	@Binding var training: Training
	//	@State private var trainingBackup = Training.empty
	@State var editingTraining: Training = .empty
	@State private var isPresentingEditView = false
	
	var body: some View {
		NavigationStack {
			VStack {
				Form {
					Section(header: Text("Stats")) {
						NavigationLink(destination: ActiveTrainingView(training: $training)) {
							Label("Start Training", systemImage: "play.circle")
								.bold()
						}
						InfoField(description: "Total moved weight", symbol: "scalemass", value: "\(training.totalMovedWeight.formatted(.number)) kg")
						
						List([ExerciseHierarchy.fromTraining(training)], id: \.self, children: \.children) { exercise in
							ExerciseHierarchyListItem(exercise: exercise)
						}
					}
					//				}
					
					
					//				List{
					Section(header: Text("Sessions")) {
						if (training.sessions.isEmpty) {
							Text("No sessions yet")
								.foregroundStyle(.gray)
						}
						ForEach(training.sessions.reversed(), id: \.self) { session in
							NavigationLink(destination: SessionView(session: session)) {
								HStack {
									ValueDescriptionAbove(description: "Session \(session.number)", value: "\(session.date.formatted(date: .numeric, time: .omitted))")
									Spacer()
									ValueDescriptionAbove(description: "Duration", value: "\((session.duration ?? Duration.seconds(0)).formatted(.time(pattern: .hourMinute))) h")
										.padding(.trailing, 5)
									ValueDescriptionAbove(description: "Weight", value: "\(session.totalMovedWeight.formatted(.number)) kg")
								}
								.padding(1)
							}
						}
					}
				}
			}
			.navigationTitle(training.name)
			.toolbar {
				Button("Edit") {
					editingTraining = training
					isPresentingEditView = true
				}
			}
			.sheet(isPresented: $isPresentingEditView) {
				NavigationStack {
					TrainingEditView(training: $editingTraining)
						.navigationTitle("Edit \(training.name)")
						.navigationBarTitleDisplayMode(.large)
						.toolbar{
							ToolbarItem(placement: .cancellationAction) {
								Button("Cancel") {
									isPresentingEditView = false
								}
							}
							ToolbarItem(placement: .confirmationAction) {
								Button("Save") {
									isPresentingEditView = false
									training = editingTraining
								}
							}
						}
				}
			}
		}
	}
}

#Preview {
	TrainingDetailView(training: .constant(.sampleData.first!))
}
