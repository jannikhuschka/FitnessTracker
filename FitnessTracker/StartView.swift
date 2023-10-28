import SwiftUI
import UserNotifications

struct StartView: View {
	@Binding var trainings: [Training]
	@State private var selectedTab = "Training"
	@Environment(\.scenePhase) private var scenePhase
	@State private var isPresentingNewTrainingView = false
	@State private var test: Test = Test(name: "Amk")
	let saveAction: ()->Void
	
	var body: some View {
		TabView(selection: $selectedTab) {
			TrainingsView(trainings: $trainings, saveAction: saveAction)
				.tabItem { Label("Training".localizedCapitalized, systemImage: "figure.strengthtraining.traditional") }
				.tag("Training")
			Text("🖕🏻")
				.font(.title)
				.tabItem { Label("Stats".localizedCapitalized, systemImage: "chart.xyaxis.line")	}
				.tag("Stats")
			VStack {
				Button("Request Permission") {
					UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
						if success {
							print("All set!")
						} else if let error = error {
							print(error.localizedDescription)
						}
					}
				}
				
				Button("Schedule Notification") {
					let content = UNMutableNotificationContent()
					content.title = "Feed the cat"
					content.subtitle = "It looks hungry"
					content.sound = UNNotificationSound.default
					
					// show this notification five seconds from now
					let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
					
					// choose a random identifier
					let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
					
					// add our notification request
					UNUserNotificationCenter.current().add(request)
					
					Task {
						try await Task.sleep(until: .now + .seconds(8), clock: .continuous)
						UNUserNotificationCenter.current().removeAllDeliveredNotifications()
					}
				}
			}
			.tabItem { Label("Settings".localizedCapitalized, systemImage: "gear") }
			.tag("Settings")
		}
	}
}
#Preview {
	StartView(trainings: .constant(Training.sampleData), saveAction: {})
}
