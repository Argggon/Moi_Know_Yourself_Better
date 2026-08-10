import SwiftUI

public struct OnboardingView: View {
    @Binding public var isCompleted: Bool
    @AppStorage("user_nickname") private var nickname: String = "you"
    @AppStorage("reminder_time_hour") private var reminderHour: Int = 8
    @AppStorage("reminder_time_minute") private var reminderMinute: Int = 0
    @AppStorage("story_day") private var storyDay: Int = Date().dayOfMonth
    
    @State private var step: Int = 1
    @State private var selectedReminderTime: Date = Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date()) ?? Date()
    
    public init(isCompleted: Binding<Bool>) {
        self._isCompleted = isCompleted
    }
    
    public var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            if step == 1 {
                // Step 1: Welcome & Vision
                VStack(spacing: 20) {
                    Image(systemName: "circle.hexagonpath")
                        .font(.system(size: 70, weight: .ultraLight))
                        .foregroundColor(MoiDesign.Colors.primary)
                    
                    Text("Moi")
                        .font(.system(size: 38, weight: .light, design: .serif))
                    
                    Text("Ask yourself one question a day,\nand discover who you truly are.")
                        .font(.title3)
                        .fontWeight(.light)
                        .multilineTextAlignment(.center)
                        .foregroundColor(MoiDesign.Colors.secondaryText)
                        .lineSpacing(6)
                }
                .transition(.opacity)
                
            } else if step == 2 {
                // Step 2: Nickname Setup
                VStack(spacing: 20) {
                    Text("What should we call you?")
                        .font(.title2)
                        .fontWeight(.medium)
                    
                    TextField("Enter your nickname", text: $nickname)
                        .font(.title3)
                        .multilineTextAlignment(.center)
                        .padding()
                        .background(MoiDesign.Colors.secondaryBackground)
                        .cornerRadius(12)
                        .padding(.horizontal, 40)
                }
                .transition(.opacity)
                
            } else if step == 3 {
                // Step 3: Time Preferences
                VStack(spacing: 20) {
                    Text("Daily Reminder Time")
                        .font(.title2)
                        .fontWeight(.medium)
                    
                    DatePicker("", selection: $selectedReminderTime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                        .frame(height: 120)
                    
                    Divider().padding(.vertical, 10)
                    
                    Text("Monthly Letter Date: Day \(storyDay) of every month")
                        .font(.subheadline)
                        .foregroundColor(MoiDesign.Colors.secondaryText)
                }
                .transition(.opacity)
            }
            
            Spacer()
            
            // Bottom Action Controls
            VStack(spacing: 16) {
                Button(action: {
                    withAnimation {
                        if step < 3 {
                            step += 1
                        } else {
                            // Complete setup
                            let calendar = Calendar.current
                            reminderHour = calendar.component(.hour, from: selectedReminderTime)
                            reminderMinute = calendar.component(.minute, from: selectedReminderTime)
                            LocalNotificationManager.shared.requestAuthorization()
                            LocalNotificationManager.shared.scheduleDailyQuestionReminder(time: selectedReminderTime)
                            isCompleted = true
                        }
                    }
                }) {
                    Text(step == 3 ? "Start" : "Next")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(MoiDesign.Colors.primary)
                        .cornerRadius(26)
                }
                .padding(.horizontal, 40)
                
                if step < 3 {
                    Button("Skip") {
                        isCompleted = true
                    }
                    .font(.subheadline)
                    .foregroundColor(MoiDesign.Colors.tertiaryText)
                }
            }
            .padding(.bottom, 30)
        }
        .padding()
        .background(MoiDesign.Colors.background.ignoresSafeArea())
    }
}
