import SwiftUI
import Combine

struct ExerciseEditView: View {
	@Binding var exercise: ExerciseDefinition
	@State var overrideChain: ExerciseOverrideChain
	@State var isPresentingNewExerciseView: Bool = false
	@State var exerciseType: Int = 0
	@State var exerciseTypeOldValue: Int = 0
	@State var changeTypeAlert: Bool = false
	@State var silentVarChange: Bool = false
	
	var body: some View {
		NavigationStack {
			Form {
				Section(header: Text("Exercise Info")) {
					HStack {
						Label("Name", systemImage: "character.cursor.ibeam")
						Spacer()
						TextField("Exercise Name", text: $exercise.name)
							.multilineTextAlignment(.trailing)
							.foregroundStyle(Color.accentColor)
					}
					if(!exercise.isSupersetMember) {
						HStack {
							Label("Type", systemImage: exercise.typeSymbol)
							Spacer()
							Menu(content: {
								Button("Simple", systemImage: exercise.isSimple ? "checkmark" : "line.3.horizontal") {
									print("Simple")
									if(exercise.isSimple) { return }
									exercise.setDefinitions = []
									exercise.supersetMembers = nil
								}
								Button("Sets", systemImage: !exercise.isSuperset && !exercise.isSimple ? "checkmark" : "lineweight") {
									print("Sets")
									if(!exercise.isSimple && !exercise.isSuperset) { return }
									exercise.setDefinitions = [SetDefinitionOverride()]
									exercise.supersetMembers = nil
								}
								Button("Superset", systemImage: exercise.isSuperset ? "checkmark" : "square.stack.3d.up") {
									print("Superset")
									if(exercise.isSuperset) { return }
									exercise.setDefinitions = []
									exercise.supersetMembers = [ExerciseDefinition(name: exercise.name, isSupersetMember: true)]
								}
							}) {
								Text(exercise.isSuperset ? "Superset" : (exercise.isSimple ? "Simple" : "Individual Sets"))
								Image(systemName: "chevron.up.chevron.down")
									.font(.caption)
							}
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
							Button("Remove All", role: .destructive) {
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
				
				if let supersetMembers = Binding<[ExerciseDefinition]>($exercise.supersetMembers) {
					//				if(exercise.isSuperset) {
					Section(header: Text("Sub-Exercises")) {
						if(supersetMembers.wrappedValue.isEmpty) {
							Text("No Exercises yet")
						} else {
							ForEach(supersetMembers.wrappedValue.indices, id: \.self) { i in
								NavigationLink(destination: ExerciseEditView(exercise: supersetMembers[i], overrideChain: fullOverrideChain)) {
									Label(supersetMembers.wrappedValue[i].name, systemImage: supersetMembers.wrappedValue[i].typeSymbol)
								}
							}
							.onDelete { indexSet in
								withAnimation {
									exercise.supersetMembers!.remove(atOffsets: indexSet)
								}
							}
							.onMove(perform: { indices, newOffset in
								withAnimation {
									exercise.supersetMembers!.move(fromOffsets: indices, toOffset: newOffset)
								}
							})
						}
						Button("Add Sub-Exercise", systemImage: "plus.circle") {
							withAnimation {
								exercise.supersetMembers!.append(.init(name: "New Sub", isSupersetMember: true))
							}
						}
					}
					.headerProminence(.increased)
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
					.headerProminence(.increased)
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
