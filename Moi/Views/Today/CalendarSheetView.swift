import SwiftUI
import SwiftData

public struct CalendarSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @Query private var logs: [DailyLog]
    @Query private var notes: [SpontaneousNote]
    
    @State private var selectedDate: Date = Date()
    @State private var currentMonthOffset: Int = 0
    
    public init() {}
    
    private var displayedMonthDate: Date {
        Calendar.current.date(byAdding: .month, value: currentMonthOffset, to: Date()) ?? Date()
    }
    
    private var daysInMonth: [Date?] {
        let calendar = Calendar.current
        guard let monthInterval = calendar.dateInterval(of: .month, for: displayedMonthDate),
              let firstDayWeekday = calendar.dateComponents([.weekday], from: monthInterval.start).weekday else {
            return []
        }
        
        var days: [Date?] = Array(repeating: nil, count: firstDayWeekday - 1)
        var date = monthInterval.start
        while date < monthInterval.end {
            days.append(date)
            date = calendar.date(byAdding: .day, value: 1, to: date) ?? monthInterval.end
        }
        return days
    }
    
    private var selectedDateLog: DailyLog? {
        logs.first { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }
    }
    
    private var selectedDateNotes: [SpontaneousNote] {
        notes.filter { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }
            .sorted { $0.date > $1.date }
    }
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    
                    // MONTH SELECTOR HEADER
                    HStack {
                        Button(action: { currentMonthOffset -= 1 }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(MoiDesign.Colors.primaryText)
                        }
                        Spacer()
                        Text(displayedMonthDate.formattedMonthYear(language: "en"))
                            .font(.title3)
                            .fontWeight(.semibold)
                        Spacer()
                        Button(action: { currentMonthOffset += 1 }) {
                            Image(systemName: "chevron.right")
                                .foregroundColor(MoiDesign.Colors.primaryText)
                        }
                    }
                    .padding(.horizontal, MoiDesign.Metrics.contentHorizontalPadding)
                    
                    // WEEKDAY HEADERS
                    let weekdays = ["S", "M", "T", "W", "T", "F", "S"]
                    HStack {
                        ForEach(weekdays.indices, id: \.self) { index in
                            Text(weekdays[index])
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(MoiDesign.Colors.tertiaryText)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.horizontal, MoiDesign.Metrics.contentHorizontalPadding)
                    
                    // 7-COLUMN GRID
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 14) {
                        ForEach(0..<daysInMonth.count, id: \.self) { index in
                            if let date = daysInMonth[index] {
                                let isAnswered = logs.contains { Calendar.current.isDate($0.date, inSameDayAs: date) && $0.isCompleted }
                                let isSelected = Calendar.current.isDate(date, inSameDayAs: selectedDate)
                                let isToday = Calendar.current.isDateInToday(date)
                                
                                Button(action: {
                                    selectedDate = date
                                }) {
                                    ZStack {
                                        if isSelected {
                                            Circle()
                                                .fill(MoiDesign.Colors.primary)
                                                .frame(width: 34, height: 34)
                                        } else if isToday {
                                            Circle()
                                                .fill(MoiDesign.Colors.primary.opacity(0.18))
                                                .overlay(
                                                    Circle()
                                                        .stroke(MoiDesign.Colors.primary, lineWidth: 1.5)
                                                )
                                                .frame(width: 34, height: 34)
                                        } else {
                                            Circle()
                                                .fill(isAnswered ? MoiDesign.Colors.primary.opacity(0.35) : Color.clear)
                                                .overlay(
                                                    Circle()
                                                        .stroke(isAnswered ? Color.clear : Color.gray.opacity(0.25), lineWidth: 1.5)
                                                )
                                                .frame(width: 34, height: 34)
                                        }
                                        
                                        Text("\(Calendar.current.component(.day, from: date))")
                                            .font(.caption)
                                            .fontWeight(isSelected || isToday ? .bold : .regular)
                                            .foregroundColor(isSelected ? .white : (isToday ? MoiDesign.Colors.primary : MoiDesign.Colors.primaryText))
                                    }
                                }
                            } else {
                                Color.clear.frame(height: 34)
                            }
                        }
                    }
                    .padding(.horizontal, MoiDesign.Metrics.contentHorizontalPadding)
                    
                    Divider()
                        .padding(.horizontal, MoiDesign.Metrics.contentHorizontalPadding)
                    
                    // INLINE MASTER-DETAIL AREA FOR SELECTED DATE
                    VStack(alignment: .leading, spacing: 20) {
                        Text(selectedDate.formattedHeaderString(language: "en"))
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(MoiDesign.Colors.primaryText)
                        
                        // SECTION 1: DAILY REFLECTION
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Daily Reflection")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(MoiDesign.Colors.secondaryText)
                            
                            if let log = selectedDateLog, log.isCompleted {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(log.questionEn.isEmpty ? log.questionZh : log.questionEn)
                                        .font(.body)
                                        .fontWeight(.medium)
                                        .foregroundColor(MoiDesign.Colors.primaryText)
                                    
                                    Text(log.isRefinedUsed ? log.refinedAnswer : log.rawAnswer)
                                        .font(.subheadline)
                                        .foregroundColor(MoiDesign.Colors.secondaryText)
                                }
                                .padding()
                                .background(MoiDesign.Colors.secondaryBackground)
                                .cornerRadius(MoiDesign.Metrics.cornerRadiusStandard)
                            } else {
                                Text("No reflection recorded for this date")
                                    .font(.subheadline)
                                    .foregroundColor(MoiDesign.Colors.tertiaryText)
                            }
                        }
                        
                        // SECTION 2: SPARKLES
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Sparkles")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(MoiDesign.Colors.secondaryText)
                            
                            if !selectedDateNotes.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    ForEach(selectedDateNotes) { note in
                                        HStack(alignment: .top, spacing: 10) {
                                            Text(note.date, format: .dateTime.hour().minute())
                                                .font(.caption2)
                                                .fontWeight(.bold)
                                                .foregroundColor(MoiDesign.Colors.secondaryText)
                                            
                                            Text(note.content)
                                                .font(.subheadline)
                                                .foregroundColor(MoiDesign.Colors.primaryText)
                                            
                                            Spacer()
                                        }
                                    }
                                }
                                .padding()
                                .background(MoiDesign.Colors.secondaryBackground)
                                .cornerRadius(MoiDesign.Metrics.cornerRadiusStandard)
                            } else {
                                Text("No sparkles recorded for this date")
                                    .font(.subheadline)
                                    .foregroundColor(MoiDesign.Colors.tertiaryText)
                            }
                        }
                    }
                    .padding(.horizontal, MoiDesign.Metrics.contentHorizontalPadding)
                }
                .padding(.vertical)
            }
            .navigationTitle("Calendar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    MoiSheetCloseButton()
                }
            }
        }
    }
}
