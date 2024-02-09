//
//  SessionView.swift
//  FitnessTracker
//
//  Created by Jannik Huschka on 17/10/23.
//

import SwiftUI

struct SessionView: View {
	@State var session: TrainingSession
	@State var sessions: [TrainingSession]?
	
	var body: some View {
		NavigationStack {
			List {
				if session.exercises.isEmpty {
					Text("No exercises yet")
						.foregroundStyle(.gray)
				}
				ForEach(session.exercises, id: \.self) { exercise in
					Section(header: Text(exercise.name)) {
						if(exercise.isSuperset) {
							ForEach(exercise.subExercises.indices, id: \.self) {i in
								HStack {
									Text(exercise.subExercises[i].name)
									SimpleExerciseRow(exercise: exercise.subExercises[i])
								}
							}
						} else {
							SimpleExerciseRow(exercise: exercise)
						}
					}
				}
			}
			.listStyle(.insetGrouped)
			.navigationTitle("\(session.trainingName): Session \(session.number)")
			.toolbar {
				if let sessions {
					ToolbarItem(placement: .confirmationAction) {
						Button("", systemImage: "chevron.up") {
							if let index = sessions.firstIndex(of: session) {
								session = sessions[sessions.index(after: index)]
							}
						}
						.disabled(session == sessions.last)
					}
					ToolbarItem(placement: .confirmationAction) {
						Button("", systemImage: "chevron.down") {
							if let index = sessions.firstIndex(of: session) {
								session = sessions[sessions.index(before: index)]
							}
						}
						.disabled(session == sessions.first)
					}
				}
			}
		}
	}
}

#Preview {
	SessionView(session: .sample2, sessions: [.empty, .sample1])
}
