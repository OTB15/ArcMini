//
//  TimelineDayView.swift
//  Arc Mini
//
//  Created by Matt Greenfield on 6/3/20.
//  Copyright © 2020 Matt Greenfield. All rights reserved.
//

import SwiftUI
import LocoKit

struct TimelineDayView: View {

    @ObservedObject var timelineSegment: TimelineSegment
    @EnvironmentObject var timelineState: TimelineState
    @EnvironmentObject var mapState: MapState

    var body: some View {
        List {
            ForEach(self.filteredListItems) { timelineItem in
                ZStack {
                    self.listBox(for: timelineItem)
                    NavigationLink(destination: ItemDetailsView(timelineItem: timelineItem)) {
                        EmptyView()
                    }.hidden()
                }
                .listRowInsets(EdgeInsets())
            }
        }
        .navigationBarTitle("")
        .navigationBarHidden(true)
        .onAppear {
            self.mapState.selectedItems.removeAll()
            self.mapState.itemSegments.removeAll()
            self.timelineState.backButtonHidden = true
            self.timelineState.mapHeightPercent = TimelineState.rootMapHeightPercent
        }
    }

    // TODO: need "thinking..." boxes represented in the list array somehow
    var filteredListItems: [TimelineItem] {
        return self.timelineSegment.timelineItems.reversed().filter { $0.dateRange != nil }
    }

    func listBox(for timelineItem: TimelineItem) -> some View {
        if let visit = timelineItem as? ArcVisit {
            return AnyView(VisitListBox(visit: visit)
                .listRowInsets(EdgeInsets()))
        }
        if let path = timelineItem as? ArcPath {
            return AnyView(PathListBox(path: path)
                .listRowInsets(EdgeInsets()))
        }
        fatalError("nah")
    }

}

//struct TimelineView_Previews: PreviewProvider {
//    static var previews: some View {
//        TimelineView(segment: AppDelegate.todaySegment)
//    }
//}