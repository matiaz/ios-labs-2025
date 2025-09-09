//
//  HomeAutomationDemo.swift
//  foundationmodels
//
//  Created by matiaz on 29/8/25.
//

import SwiftUI

struct HomeAutomationDemo: View {
    @State private var command = "Turn on the living room lights"
    @State private var isProcessing = false
    @State private var response = ""
    @State private var deviceStatus: [String: Bool] = [
        "Living Room Lights": false,
        "Bedroom AC": false,
        "Kitchen Coffee Maker": false
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Voice Command:")
                .font(.subheadline)
                .fontWeight(.medium)
            
            TextField("Say something...", text: $command)
                .textFieldStyle(.roundedBorder)
            
            Button(action: processCommand) {
                HStack {
                    if isProcessing {
                        ProgressView()
                            .scaleEffect(0.8)
                    }
                    Text(isProcessing ? "Processing..." : "Execute Command")
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(isProcessing)
            
            if !response.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Assistant Response:")
                        .font(.caption)
                        .fontWeight(.medium)
                    
                    Text(response)
                        .font(.caption)
                        .padding(8)
                        .background(Color.mint.opacity(0.1))
                        .cornerRadius(8)
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Device Status:")
                    .font(.caption)
                    .fontWeight(.medium)
                
                ForEach(Array(deviceStatus.keys.sorted()), id: \.self) { device in
                    HStack {
                        Image(systemName: deviceStatus[device] ?? false ? "lightbulb.fill" : "lightbulb")
                            .foregroundColor(deviceStatus[device] ?? false ? .yellow : .gray)
                        Text(device)
                            .font(.caption)
                        Spacer()
                        Text(deviceStatus[device] ?? false ? "ON" : "OFF")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(deviceStatus[device] ?? false ? .green : .red)
                    }
                }
            }
        }
    }
    
    private func processCommand() {
        isProcessing = true
        
        // Simulate AI command processing
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if command.lowercased().contains("living room lights") {
                if command.lowercased().contains("turn on") {
                    deviceStatus["Living Room Lights"] = true
                    response = "I've turned on the living room lights for you."
                } else if command.lowercased().contains("turn off") {
                    deviceStatus["Living Room Lights"] = false
                    response = "I've turned off the living room lights."
                }
            } else {
                response = "I understood your command. The system would normally control your smart home devices."
            }
            isProcessing = false
        }
    }
}

#Preview {
    HomeAutomationDemo()
        .padding()
}