//
//  NumberPickerView.swift
//  FitnessTracker
//
//  Created by Jannik Huschka on 20/10/23.
//

import SwiftUI

struct IntPickerView: View {
	@State var description: String
	@State var image: String = ""
	@Binding var value: Int
	@State var range: ClosedRange<Int>
	@State var transformFunction: (Int) -> String = { "\($0)" }
	
    var body: some View {
		Picker(selection: $value, label: Label(description, systemImage: image)) {
			ForEach(range, id: \.self) { i in
				Text(transformFunction(i))
					.tag(i)
			}
		}
		.tint(.blue)
    }
}

#Preview {
	IntPickerView(description: "test", value: .constant(5), range: 1...10)
}
