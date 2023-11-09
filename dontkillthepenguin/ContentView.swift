//
//  ContentView.swift
//  dontkillthepenguin
//
//  Created by not Michael Chen on 11/4/23.
//

import SwiftUI
import SwiftData
import DeviceActivity
import FamilyControls
import UIKit
import Charts


struct ContentView: View {
    var body: some View {
        Background()
    }
}

struct Background: View {
    var body: some View {
//        VStack{
        Image("arctic background2").frame(width: 500, height: 1000)
            .overlay(ViewDisplay())
//                .scaleEffect(1)
//        }
    }
}

struct StreakText: View {
    @State private var streakCounter = 0
    var body: some View {
        VStack{
            Text("\(streakCounter)")
                .padding(10)
        }
    }
}

class ScreenTimeSelectAppsModel: ObservableObject {
    @Published var activitySelection = FamilyActivitySelection()

    init() { }
}
// test



struct ScreenTimeSelectAppsContentView: View {

    @State private var pickerIsPresented = false
    @ObservedObject var model: ScreenTimeSelectAppsModel

    var body: some View {
        Button {
            pickerIsPresented = true
        } label: {
            Text("Select Apps")
        }
        .familyActivityPicker(
            isPresented: $pickerIsPresented,
            selection: $model.activitySelection
        )
    }
}


extension DeviceActivityEvent.Name {
    static let encouraged = Self("encouraged")
}


struct ViewDisplay: View {

    @State private var penguinHealth = 100
    @State private var isPopoverVisible = false
    @State private var goalHours = 2.0
    @State private var currHours = 2.0
    @State private var countdownString = "00:00"
    private let calendar = Calendar.current
//    @State private var totalActivity: DeviceActivityData.ActivitySegment
    @State private var context: DeviceActivityReport.Context = .init(rawValue: "test")
    @State private var filter = DeviceActivityFilter(
        segment: .daily(
            during: Calendar.current.dateInterval(
               of: .day, for: .now
            )!
        ),
        users: .all,
        devices: .init([.iPhone, .iPad])
    )

    class MyMonitorExtension: DeviceActivityMonitor {
        @Binding var penguinHealth: Int // Assuming penguinHealth is an @State variable

        init(penguinHealth: Binding<Int>) {
               self._penguinHealth = penguinHealth
           }

        override func eventDidReachThreshold(
            _ event: DeviceActivityEvent.Name,
            activity: DeviceActivityName
        ) {
            super.eventDidReachThreshold(event, activity: activity)
            print(self.penguinHealth)
            
            self.penguinHealth = 50

        }
    }

    
    var body: some View {
//        Button("Apps to Discourage") {
//            isPresented = true
//        }
//        .familyActivityPicker(isPresented: $isPresented, selection: $model.selectionToDiscourage)
 

        let model = ScreenTimeSelectAppsModel()


        let schedule = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: 0, minute: 0, second: 0),
            intervalEnd: DateComponents(hour: 23, minute: 59, second: 59),
            repeats: true
        )


        let selection: FamilyActivitySelection =
        model.activitySelection

        let timeLimitMinutes = 1

        let events = DeviceActivityEvent(
            applications: selection.applicationTokens,
            categories: selection.categoryTokens,
            webDomains: selection.webDomainTokens,
            threshold: DateComponents(minute: timeLimitMinutes)
        )


        let center = DeviceActivityCenter()

        let activity = DeviceActivityName("MyApp.ScreenTime")
        let eventName = DeviceActivityEvent.Name("MyApp.SomeEventName")


        
        VStack {
            
            // Streak Counter in the Top Right Corner
            DeviceActivityReport(context, filter: filter)
            
            HStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(red: 191 / 255, green: 185 / 255, blue: 255 / 255, opacity: 0.7))
                    .frame(width: 200, height: 80)
                    .overlay(HStack {
                        VStack(alignment: .leading){
                                        
                                        Text("Goal time: ").fontWeight(.bold) + Text("\(goalHours, specifier: "%.0f")").font(Font.system(size: 25)) + Text(" hr")
                
                                        Text("Screen time: ").fontWeight(.bold) + Text("\(currHours, specifier: "%.0f")").font(Font.system(size: 25)) + Text(" hr")
//                            
                                    }
                            })
//                Spacer()
                Image("streak")
                    .padding(10)
                    .overlay(StreakText())
            }

            Spacer()
                 .frame(height:100)
            
            VStack{
                Text("Time until damage")
                    .font(.system(size: 20))
                Text(countdownString)
                    .onAppear(perform: {
                        updateCountdown()
                    })
            }
            
            Button("Start Monitoring") {
                do {
                    try center.startMonitoring(activity, during: schedule, events: [eventName: events])
                    print("pressed button!")
                } catch {
                    print("Error starting monitoring: \(error)")
                }
            }.buttonStyle(.borderedProminent)
            ScreenTimeSelectAppsContentView(model: model).buttonStyle(.borderedProminent)

            
            // Penguin Image
            let imageName = penguinImageName(for: penguinHealth)
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 200, height: 200)
            
            ProgressBar(value: $penguinHealth)
                .frame(height: 20)
                .padding(.horizontal, 100)
            
            
            Button(action: { isPopoverVisible.toggle() 
                }) {
                    Text("Add Goals!")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            
                .popover(isPresented: $isPopoverVisible, content: {
                    VStack {
                        Text("Set Goal Hours")
                            .font(.headline)
                            .padding()
                        Slider(value: $goalHours, in: 0.0...24.0, step: 1)
                            .padding()
                        Text("Goal: \(Int(goalHours)) hours")
                            .padding()
                        Button("Save Goal") {
                            // Handle saving the selected goal
                            isPopoverVisible.toggle()
                        }
                        .padding()
                    }
                    .frame(width: 200, height: 200)
                })
            }
//            .padding(150)
        .frame(height: 150)
//            Spacer()
            
    }
    private func updateCountdown() {
            let targetHour = 24
            let targetMinute = 0
            let currentDate = Date()
            let components = calendar.dateComponents([.hour, .minute], from: currentDate)
            
            if let currentHour = components.hour, let currentMinute = components.minute {
                var hoursRemaining = targetHour - currentHour
                var minutesRemaining = targetMinute - currentMinute
                
                if minutesRemaining < 0 {
                    hoursRemaining -= 1
                    minutesRemaining += 60
                }

                // Ensure hours and minutes are formatted as two digits
                let hourString = String(format: "%02d", max(hoursRemaining, 0))
                let minuteString = String(format: "%02d", max(minutesRemaining, 0))

                countdownString = "\(hourString):\(minuteString)"

                // Schedule the timer to update every minute
                Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
                    updateCountdown()
                }
            }
        }    
}


    

            
private func penguinImageName(for penguinHealth: Int) -> String {
    // Determine the penguin image based on penguinHealth
    if penguinHealth <= 0 {
        return "deadpenguincoffin"
    }
    else if penguinHealth < 20{
        return "sickpenguin"
    }
    else if penguinHealth < 40 {
        return "depressedpenguin"
    }
    else if penguinHealth < 60 {
        return "sadpenguin"
    }
    else if penguinHealth < 80 {
        return "penguin"
    }
    else {
        return "drippypenguin"
    }
    
    
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }
}
