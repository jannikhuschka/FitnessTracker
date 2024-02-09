import SwiftUI

struct PartialRing: Shape {
	var progress: Double
	private var realProgress: Double
	var diameter: Double
	
	var animatableData: Double {
		get { realProgress }
		set { realProgress = newValue }
	}
	
	init(progress: Double, diameter: Double) {
		self.progress = progress
		self.realProgress = progress
		self.diameter = diameter
	}
	
	private var startAngle: Angle {
		.degrees(0.0)
	}
	private var endAngle: Angle {
		.degrees(realProgress * 360.0)
	}
	
	func path(in rect: CGRect) -> Path {
		let radius = diameter / 2.0
		let center = CGPoint(x: rect.midX, y: rect.midY)
		return Path { path in
			path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
		}
	}
}
