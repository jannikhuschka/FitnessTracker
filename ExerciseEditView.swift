import SwiftUI
import Combine

struct ExerciseEditView: View {
	@Binding var exercise: ExerciseDefinition
	@State var overrideChain: ExerciseOverrideChain
	@State var isPresentingNewExerciseView: Bool = false
	@State var isSuperset: Bool = false
	
	var body: some View {
		NavigationStack {
			Form {
				Section(header: Text("Exercise Info")) {
					HStack {
						Label("Name", systemImage: "character.cursor.ibeam")
						Spacer()
						TextField("Exercise Name", text: $exercise.name)
							.multilineTextAlignment(.trailing)
							.foregroundStyle(.blue)
					}
					if(!exercise.isSupersetMember) {
						HStack {
							Label("Type", systemImage: "figure.run")
							Spacer()
							Picker(selection: $isSuperset.animation(), label: Label("Exercise Type", systemImage: "clock")) {
								Text("Simple").tag(false)
								Text("Superset").tag(true)
							}
							.pickerStyle(.segmented)
							.frame(width: 140)
						}
					}
					
					if let paramBinding = Binding<ExerciseParamsOverride>($exercise.overrides) {
						NavigationLink(destination: {
							ExerciseParamsOverrideEditView(override: paramBinding, exercise: $exercise, overrideChain: fullOverrideChain)
								.navigationTitle("\(exercise.name) Overrides")
						}) {
							Label("Overrides (\(paramBinding.wrappedValue.overrideCount))", systemImage: "figure.run.square.stack")
						}
						.swipeActions(edge: .trailing, allowsFullSwipe: true) {
							Button("Remove All Overrides", role: .destructive) {
								exercise.overrides = nil
							}
						}
					} else {
						Button(action: {
							exercise.overrides = .empty
						}) {
							Label("Add Overrides", systemImage: "plus.circle")
						}
					}
				}
				
				if(isSuperset) {
					Section(header: Text("Sub-Exercises")) {
						if(exercise.supersetMembers.isEmpty) {
							Text("No Exercises yet")
						} else {
							ForEach(exercise.supersetMembers.indices, id: \.self) { i in
								NavigationLink(destination: ExerciseEditView(exercise: $exercise.supersetMembers[i], overrideChain: fullOverrideChain)) {
									Label(exercise.supersetMembers[i].name, systemImage: "\(i + 1).square")
								}
							}
						}
						Button("Add Sub-Exercise", systemImage: "plus.circle") {
							exercise.supersetMembers.append(.init(name: "New Sub", isSupersetMember: true))
						}
					}
				} else {
					Section(header: Text("Sets")) {
						if(exercise.isSimple) {
							Label("\("Set".pluralize(fullOverrideChain.setCount)) with \("Repetition".pluralize(fullOverrideChain.setDefinition.repCount))", systemImage: "list.number")
							Button("Change to individual Sets", systemImage: "sparkles.rectangle.stack") {
								exercise.setDefinitions.append(.init())
							}
						} else {
							ForEach(exercise.setDefinitions.indices, id: \.self) { i in
								NavigationLink(destination: {
									Form {
										Section(header: Text("Overrides")) {
											SetDefinitionOverrideEditView(override: $exercise.setDefinitions[i], overrideChain: fullOverrideChain)
										}
									}
									.navigationTitle("Set \(i + 1) Overrides")
								}) {
									Text("Set \(i + 1)")
								}
							}
							.onDelete { indexSet in
								withAnimation {
									exercise.setDefinitions.remove(atOffsets: indexSet)
								}
							}
							.onMove { indices, newOffset in
								withAnimation {
									exercise.setDefinitions.move(fromOffsets: indices, toOffset: newOffset)
								}
							}
							Button("Add Set", systemImage: "plus.circle") {
								exercise.setDefinitions.append(.init())
							}
						}
					}
				}
			}
			.navigationTitle(exercise.name)
		}
	}
	
	var fullOverrideChain: ExerciseOverrideChain { overrideChain.with(exercise.overrides) }
}

#Preview {
	ExerciseEditView(exercise: .constant(.sample1), overrideChain: .init(root: .sample))
}
