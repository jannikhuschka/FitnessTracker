//
//  TestEditView.swift
//  FitnessTracker
//
//  Created by Jannik Huschka on 19/10/23.
//

import SwiftUI

struct TestEditView: View {
	@Binding var test: Test
	@State var tempTest: Test
	@Binding var isPresentingNewTrainingView: Bool
	
	init(test: Binding<Test>, isPresentingNewTrainingView: Binding<Bool>) {
		_tempTest = State(wrappedValue: test.wrappedValue)
		_test = test
		_isPresentingNewTrainingView = isPresentingNewTrainingView
	}
	
    var body: some View {
		NavigationStack {
			VStack {
				TextField("Text for Test", text: $tempTest.name)
					.padding()
			}
			.toolbar {
				ToolbarItem(placement: .cancellationAction) {
					Button("Cancel") {
						isPresentingNewTrainingView = false
					}
				}
				ToolbarItem(placement: .confirmationAction) {
					Button("Done") {
						isPresentingNewTrainingView = false
						test = tempTest
					}
				}
			}
		}
    }
}

#Preview {
	TestEditView(test: .constant(.init(name: "Hund")), isPresentingNewTrainingView: .constant(true))
}
