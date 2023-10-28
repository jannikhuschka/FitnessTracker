//
//  NumberTextField.swift
//  FitnessTracker
//
//  Created by Jannik Huschka on 21/10/23.
//

import SwiftUI

struct IntTextField: View {
	@State var description: String = "Description"
	@State var image: String = ""
	@Binding var value: Int
	@State var additionalText: String = ""
	
	var body: some View {
		HStack {
			if (!description.isEmpty) {
				Label(description, systemImage: image)
			}
			Spacer()
			TextField(description, value: $value, formatter: NumberFormatter.int)
				.keyboardType(.numberPad)
				.multilineTextAlignment(.trailing)
				.foregroundStyle(.blue)
				.frame(width: 100)
//				.background(.black)
			Text(additionalText)
				.foregroundStyle(.blue)
		}
	}
}

extension NumberFormatter {
	public static var int: NumberFormatter {
		let result = NumberFormatter()
		result.numberStyle = .none
		result.maximumFractionDigits = 0
		result.allowsFloats = false
		return result
	}
}

#Preview {
	IntTextField(value: .constant(5))
}
