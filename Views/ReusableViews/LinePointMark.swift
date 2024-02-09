import Foundation
import Charts

struct LinePointMark<X: Plottable, Y: Plottable>: ChartContent {
	let x: PlottableValue<X>
	let y: PlottableValue<Y>
	
	init(x: PlottableValue<X>, y: PlottableValue<Y>) {
		self.x = x
		self.y = y
	}
	
	var body: some ChartContent {
		LineMark(x: x, y: y)
//		PointMark(x: x, y: y)
	}
}
