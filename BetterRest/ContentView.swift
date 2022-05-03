//
//  ContentView.swift
//  BetterRest
//
//  Created by Lucas Chae on 5/3/22.
//
import CoreML
import SwiftUI

struct ContentView: View {
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 0
    @State private var wakeUp = defaultWakeTime
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var isShowing = false
    
    @State private var sleepTimeDisplay = ""
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date.now
    }
    
    
    var body: some View {
        NavigationView {
            Form {
                Section {
//                    Stepper(coffeeAmount == 1 ? "1 cup" : "\(coffeeAmount) cups", value: $coffeeAmount, in: 1...10)
                    Picker("How much coffee did you drink", selection: $coffeeAmount) {
                        ForEach(1..<6) {number in
                            Text(number == 1 ? "1 cup" : "\(number) cups")
                        }
                    }
                    .pickerStyle(.segmented)
                } header: {
                    Text("How much coffee did you drink?")
                        .font(.subheadline)
                }
                
                Section {
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 0...24, step: 0.5)
                } header: {
                    Text("How much sleep do you want?")
                        .font(.subheadline)
                }
                
                
                Section {
                    HStack {
                        Text("I'll wake up at")
                        DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
                    }
                    
                } header: {
                    Text("When do you want to wake up?")
                        .font(.subheadline)
                }
                
                
                Text("Your ideal bedtime is..")
            }
            .navigationTitle("BetterRest")
            .toolbar{
                Button("Calculate", action: calculateBedtime)
            }
            .alert(alertTitle, isPresented: $isShowing) {
                Button("Ok") { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    func calculateBedtime() {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)

            let sleepTimeComponent = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            
            let hour = (sleepTimeComponent.hour ?? 0) * 3600 // in seconds
            let minute = sleepTimeComponent.minute ?? 0 * 60 // in seconds
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
            
            sleepTimeDisplay = "\(sleepTime.formatted(date: .omitted, time: .shortened))"
            
            alertTitle = "Your ideal bedtime is.."
            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
            
            
        } catch {
            alertTitle = "Error"
            alertMessage = "Sorry, there was an error calculating your bedtime."
        }
        
        isShowing = true
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
