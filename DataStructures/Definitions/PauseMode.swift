import Foundation

enum PauseMode: String, CaseIterable, HashEqCod {
	case fixedPauseDuration = "Pause Duration"
	case fixedSetDuration = "Set Duration"
	case infinitePause = "Infinite Pause"
}

extension PauseMode {
	var shortened: String {
		switch(self) {
		case .fixedPauseDuration: return "Pause"
		case .fixedSetDuration: return "Set"
		case .infinitePause: return "Infinite"
		}
	}
	
	static func symbol(mode: PauseMode) -> String {
		switch(mode) {
		case(.fixedPauseDuration): return "pause"
		case(.fixedSetDuration): return "playpause"
		case(.infinitePause): return "infinity"
		}
	}
}
