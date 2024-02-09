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
	@State private var exercisesExpanded: Bool = false
	
	var body: some View {
		NavigationStack {
			VStack {
				Form {
					Section(header: Text("Stats")) {
						NavigationLink(destination: ActiveTrainingView2(training: $training)) {
							Label("Start Training", systemImage: "play.circle")
								.bold()
						}
						InfoField(description: "Total moved weight", symbol: "scalemass", value: "\(training.totalMovedWeight.formatted(.number)) kg")
						
						HStack {
							Label("\(training.exercises.count) Exercises with \(training.totalSets) Sets", systemImage: "list.bullet.indent")
							Spacer()
							Button(action: {
								withAnimation {
									exercisesExpanded.toggle()
								}
							}) {
								Image(systemName: "chevron.right")
									.font(.caption)
									.rotationEffect(.degrees(exercisesExpanded ? 90 : 0))
							}
						}
						if(exercisesExpanded) {
							List(training.exercises, id: \.self, children: \.supersetMembers) { exDef in
								if(exDef.isSupersetMember) {
									let superset = training.exercises.first(where: { $0.isSuperset && $0.supersetMembers!.contains(exDef) })
									ExerciseListItem(exercise: exDef, overrideChain: .init(root: training.defaults, overrides: [superset?.overrides, exDef.overrides]))
										.padding(.leading)
								} else {
									ExerciseListItem(exercise: exDef, overrideChain: .init(root: training.defaults, overrides: [exDef.overrides]))
								}
							}
						}
					}
					
					Section(header: Text("Sessions")) {
						if (training.sessions.isEmpty) {
							Text("No sessions yet")
								.foregroundStyle(.gray)
						}
						ForEach(training.sessions.reversed(), id: \.self) { session in
							NavigationLink(destination: SessionView(session: session, sessions: training.sessions)) {
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
