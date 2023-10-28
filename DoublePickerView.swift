//
//  NumberPickerView.swift
//  FitnessTracker
//
//  Created by Jannik Huschka on 20/10/23.
//

import SwiftUI

struct DoublePickerView: View {
	@State var description: String
	@Binding var value: Double
	@State var allowedValues: [Double]
	@State var additionalText: String = ""
	@State var step: Int = 1
	
	var body: some View {
		Picker(description, selection: $value) {
//			ForEach((range.lowerBound / step)...(range.upperBound / step), id: \.self) { i in
//				Text("\(step * i)\(additionalText)")
//					.tag(Double(step * i))
//			}
			ForEach(allowedValues, id: \.self) { d in
				Text("\(d.formatted(.number))\(additionalText)")
					.tag(d)
			}
		}
		.tint(.blue)
	}
}

#Preview {
	DoublePickerView(description: "test", value: .constant(5), allowedValues: [1, 8, 7])
}
