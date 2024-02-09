import Foundation
import SwiftUI

struct ChartColors {
	static let dict: Dictionary<String, Color> = [
		"Set 1": .red,
		"Set 2": .orange,
		"Set 3": .yellow,
		"Set 4": .green,
		"Set 5": .cyan,
		"Set 6": .indigo,
		"Set 7": .blue,
		"Set 8": .pink,
		"Set 9": .purple,
		"Set 10": .brown,
	]
	
	static func legend(_ length: Int) -> Dictionary<String, Color> {
		if(length > dict.count) { return dict }
		return dict.filter({ Int(String($0.key.last!))! <= length })
	}
}
