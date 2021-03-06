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

    init(timelineSegment: TimelineSegment) {
        self.timelineSegment = timelineSegment
        UITableViewCell.appearance().selectionStyle = .none
        UITableView.appearance().backgroundColor = UIColor(named: "background")
    }

    var body: some View {
        timelineState.previousListBox = nil
        return ZStack(alignment: .trailing) {
            List {
                ForEach(filteredListItems) { timelineItem in
                    listBox(for: timelineItem)
                }
            }
            Rectangle().fill(Color("brandSecondary10")).frame(width: 0.5).edgesIgnoringSafeArea(.all)
        }
        .navigationBarTitle("")
        .navigationBarHidden(true)
        .onAppear {
            mapState.selectedItems.removeAll()
            mapState.itemSegments.removeAll()
            timelineState.backButtonHidden = true
            timelineState.updateTodayButton()
            timelineState.mapHeightPercent = TimelineState.rootMapHeightPercent

            // do place finds
            for case let visit as ArcVisit in timelineSegment.timelineItems {
                if visit.isWorthKeeping {
                    visit.findAPlace()
                }
            }
        }
        .background(Color("background"))
    }

    var filteredListItems: [TimelineItem] {
        return timelineSegment.timelineItems.reversed().filter { $0.dateRange != nil }
    }

    var isToday: Bool {
        return timelineSegment.dateRange?.contains(Date()) == true
    }

    // the items inside the recorder's processing boundary
    var activeItems: [TimelineItem] {
        if isToday, !LocomotionManager.highlander.recordingState.isSleeping, let currentItem = RecordingManager.recorder.currentItem {
            return TimelineProcessor.itemsToProcess(from: currentItem)
        }
        return []
    }

    func listBox(for item: TimelineItem) -> some View {
        // show a "thinking" item for shitty stuff that's still processing or can't be processed yet
        if item.isInvalid || (!item.isWorthKeeping && (RecordingManager.store.processing || activeItems.contains(item) || item.isMergeLocked)) {
            if timelineState.previousListBox is ThinkingListBox {
                return AnyView(EmptyView().listRowInsets(EdgeInsets()))
            }
            let box = ThinkingListBox()
            timelineState.previousListBox = box
            return AnyView(box.listRowInsets(EdgeInsets()))
        }

        let boxStack = ZStack {
            self.timelineItemBox(for: item).onAppear {
                if self.timelineSegment == self.timelineState.visibleTimelineSegment {
                    if item == self.filteredListItems.first {
                        self.mapState.selectedItems = [] // zoom to all items when scrolled to top
                    } else {
                        self.mapState.selectedItems.insert(item)
                    }
                }
            }.onDisappear {
                if self.timelineSegment == self.timelineState.visibleTimelineSegment {
                    self.mapState.selectedItems.remove(item)
                }
            }
            NavigationLink(destination: ItemDetailsView(timelineItem: item)) {
                EmptyView()
            }.hidden()
        }
        .listRowInsets(EdgeInsets())

        return AnyView(boxStack)
    }

    func timelineItemBox(for item: TimelineItem) -> some View {
        if let visit = item as? ArcVisit {
            let box = VisitListBox(visit: visit)
            timelineState.previousListBox = box
            return AnyView(box.listRowInsets(EdgeInsets()))
        }
        if let path = item as? ArcPath {
            let box = PathListBox(path: path)
            timelineState.previousListBox = box
            return AnyView(box.listRowInsets(EdgeInsets()))
        }
        fatalError("nah")
    }

}

//struct TimelineView_Previews: PreviewProvider {
//    static var previews: some View {
//        TimelineDayView(timelineSegment: AppDelegate.todaySegment)
//            .environmentObject(TimelineState())
//            .environmentObject(MapState())
//    }
//}
