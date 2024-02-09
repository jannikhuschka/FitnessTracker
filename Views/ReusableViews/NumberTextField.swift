//
//  NumberTextField.swift
//  FitnessTracker
//
//  Created by Jannik Huschka on 21/10/23.
//

import SwiftUI

struct NumberTextField: View {
	@State var description: String = "Description"
	@State var image: String = ""
	@Binding var value: Double
	@State var additionalText: String = ""
	
    var body: some View {
		HStack {
			Label(description, systemImage: image)
			Spacer()
			TextField(description, value: $value, formatter: NumberFormatter.decimal)
				.keyboardType(.decimalPad)
				.multilineTextAlignment(.trailing)
				.foregroundStyle(Color.accentColor)
				.frame(width: 100)
//				.background(.black)
			Text(additionalText)
				.foregroundStyle(Color.accentColor)
		}
    }
}

extension NumberFormatter {
	public static var decimal: NumberFormatter {
		let result = NumberFormatter()
		result.numberStyle = .decimal
		result.maximumFractionDigits = 2
		result.allowsFloats = true
		return result
	}
}

#Preview {
	NumberTextField(value: .constant(5))
}
