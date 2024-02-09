//
//  StopwatchTimeView.swift
//  FitnessTracker
//
//  Created by Jannik Huschka on 22/12/23.
//

import SwiftUI

struct StopwatchTimeView: View {
	var endOfPauseDate: Date
	var pausePhase: Bool
	var paused: Bool
	var timerInterval: ClosedRange<Date> {
		endOfPauseDate > .now ? .now...endOfPauseDate : endOfPauseDate...Date.distantFuture
	}
	var pauseTime: Date? {
		if !paused { return nil }
		return pausePhase ? endOfPauseDate : .now
	}
	
    var body: some View {
		Text(timerInterval: timerInterval, pauseTime: pauseTime, countsDown: pausePhase)
			.contentTransition(.numericText(countsDown: pausePhase))
			.foregroundStyle(pausePhase ? .primary : Color.accent)
			.transaction { transaction in
				transaction.animation = .default
			}
    }
}

#Preview {
	StopwatchTimeView(endOfPauseDate: .now, pausePhase: false, paused: false)
}
