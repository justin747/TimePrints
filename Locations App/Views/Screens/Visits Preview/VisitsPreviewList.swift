//
//  LocationsView.swift
//  Locations App
//
//  Created by Kevin Li on 1/30/20.
//  Copyright © 2020 Kevin Li. All rights reserved.
//

import SwiftUI

struct VisitsPreviewList: View {
//    @State private var showingDetail = false
    @State private var currentDayComponent = DateComponents()
    let visits: [Visit]
    
    private var visitsForDate: [DateComponents: [Visit]] {
        Dictionary(grouping: visits, by: { $0.arrivalDate.dateComponents })
    }
    
    private var datesForMonth: [DateComponents: [DateComponents]] {
        Dictionary(grouping: Array(visitsForDate.keys), by: { $0.monthAndYear })
    }
    
    var body: some View {
        var fill = false
        
        func isFilled() -> Bool {
            fill.toggle()
            return fill
        }
        
        return ZStack {
            SuperColor(UIColor.black)
            
//            DayDetailsView(show: $showingDetail, date: currentDateComponent.date, visits: dateVisits[currentDateComponent] ?? [])
//                .frame(width: showingDetail ? nil : 0, height: showingDetail ? nil : 0)
//                .animation(.easeIn)
            
            ScrollView(.vertical, showsIndicators: false) {
                V0Stack {
                    ForEach(datesForMonth.descendingKeys) { monthComponent in
                        H0Stack {
                            MonthYearSideBar(date: monthComponent.date)
//                                .offset(x: self.showingDetail ? -200 : 0)
                            V0Stack {
                                ForEach(self.datesForMonth[monthComponent]!.sortDescending) { dateComponent in
                                    HStack {
                                        DaySideBar(date: dateComponent.date)
//                                            .offset(x: self.showingDetail ? -200 : 0)
                                        DayPreviewBlock(visits: self.visitsForDate[dateComponent]!, isFilled: isFilled())
                                            .onTap {
//                                                self.showingDetail = true
                                                self.currentDayComponent = dateComponent
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
//            .opacity(showingDetail ? 0 : 1)
            .beyond()
        }
    }
}

struct VisitsPreviewList_Previews: PreviewProvider {
    static var previews: some View {
        VisitsPreviewList(visits: Visit.previewVisits).environment(\.managedObjectContext, CoreData.stack.context).statusBar(hidden: true)
    }
}
