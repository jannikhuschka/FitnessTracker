import SwiftUI

struct InfoField: View {
	@State var description: String
	@State var symbol: String
	var value: String
	
	var body: some View {
		HStack {
			Label(description, systemImage: symbol)
			Spacer()
			Text(value)
				.foregroundStyle(.gray)
				.multilineTextAlignment(.trailing)
		}
	}
}

#Preview {
	InfoField(description: "Description", symbol: "clock", value: "Value")
}
