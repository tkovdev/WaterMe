//
//  DayPickerView.swift
//  WaterMe
//
//  Created by Tommy Kovalchuk on 2024-06-07.
//

import SwiftUI

struct DaysPicker: View {
    @Binding var selection: [Day]
    var disabled: Bool = false
    var onSubmit: (() -> Void)?
    
    var body: some View {
        HStack {
            ForEach(Day.allCases, id: \.self) { day in
                Text(String(day.rawValue.first!))
                    .bold()
                    .foregroundColor(selection.contains(day) ? Color(uiColor: .systemBackground) : Color(uiColor: .systemBlue))
                    .frame(width: 30, height: 30)
                    .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 20))
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(selection.contains(day) ? Color(uiColor: .systemBlue) : Color(uiColor: .systemBackground))
                    )
                    .onTapGesture {
                        if(disabled) {
                            return
                        }
                        if selection.contains(day) {
                            selection.removeAll(where: {$0 == day})
                        } else {
                            selection.append(day)
                        }
                        guard let submit = onSubmit else {
                            return
                        }
                        
                        submit()
                    }
            }
        }.frame(maxWidth: .infinity)
    }
}

enum Day: String, CaseIterable, Codable {
    case Sunday, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday
}

#Preview {
    DaysPicker(selection: .constant([Day]()))
}
