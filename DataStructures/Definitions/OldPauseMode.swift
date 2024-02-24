import Foundation

enum OldPauseMode: String, CaseIterable, HashEqCod {
	case fixedPauseDuration = "Pause Duration"
	case fixedSetDuration = "Set Duration"
	case infinitePause = "Infinite Pause"
}

extension OldPauseMode {
	var shortened: String {
		switch(self) {
		case .fixedPauseDuration: return "Pause"
		case .fixedSetDuration: return "Set"
		case .infinitePause: return "Infinite"
		}
	}
	
	static func symbol(mode: OldPauseMode) -> String {
		switch(mode) {
		case(.fixedPauseDuration): return "pause"
		case(.fixedSetDuration): return "playpause"
		case(.infinitePause): return "infinity"
		}
	}
}
