//
//  TestView.swift
//  FitnessTracker
//
//  Created by Jannik Huschka on 30/11/23.
//

import SwiftUI

struct TestView: View {
	var startDate: Date = .now
	var endDate: Date = Date(timeInterval: 60, since: .now)
	
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
		Text(timerInterval: startDate...endDate, countsDown: true, showsHours: true)
			.contentTransition(.numericText(countsDown: true))
			.transaction { transaction in
				transaction.animation = .default
			}
		Text(Date.now, style: .timer)
			.contentTransition(.numericText())
			.transaction { transaction in
				transaction.animation = .default
			}
    }
}

#Preview {
    TestView()
}
