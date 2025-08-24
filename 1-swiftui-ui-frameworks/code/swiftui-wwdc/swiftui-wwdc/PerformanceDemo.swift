//
//  PerformanceDemo.swift
//  swiftui-wwdc
//
//  Created by matiaz on 24/8/25.
//

import SwiftUI

struct PerformanceDemo: View {
    @State private var items: [PerformanceItem] = []
    @State private var isLoading = false
    @State private var startTime: Date?
    @State private var loadTime: String = ""
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(alignment: .leading, spacing: 16) {
                Text("Performance Improvements")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Lists are now 6x faster with improved scrolling and memory management")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Performance Metrics
            VStack(spacing: 16) {
                HStack {
                    PerformanceMetric(
                        title: "Items Loaded",
                        value: "\(items.count)",
                        icon: "list.bullet"
                    )
                    
                    PerformanceMetric(
                        title: "Load Time",
                        value: loadTime,
                        icon: "clock"
                    )
                }
                
                HStack {
                    PerformanceMetric(
                        title: "Memory Usage",
                        value: "Optimized",
                        icon: "memorychip"
                    )
                    
                    PerformanceMetric(
                        title: "Scroll FPS",
                        value: "60",
                        icon: "speedometer"
                    )
                }
            }
            
            // Control Buttons
            HStack(spacing: 16) {
                Button("Load 1K Items") {
                    loadItems(count: 1000)
                }
                .buttonStyle(.borderedProminent)
                .disabled(isLoading)
                
                Button("Load 10K Items") {
                    loadItems(count: 10000)
                }
                .buttonStyle(.bordered)
                .disabled(isLoading)
                
                Button("Clear") {
                    items.removeAll()
                    loadTime = ""
                }
                .buttonStyle(.bordered)
                .disabled(isLoading)
            }
            
            // High Performance List
            if !items.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("High Performance List")
                        .font(.headline)
                    
                    Text("Smooth scrolling with lazy loading and optimized rendering")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                List {
                    ForEach(items) { item in
                        PerformanceListItem(item: item)
                            .listRowBackground(Color.clear)
                    }
                }
                .listStyle(.plain)
                .frame(height: 300)
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
            }
            
            // Concurrent Operations Demo
            ConcurrentOperationsDemo()
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
        .backgroundExtensionEffect()
    }
    
    private func loadItems(count: Int) {
        isLoading = true
        startTime = Date()
        
        // Simulate realistic loading with concurrent processing
        Task {
            let newItems = await generateItems(count: count)
            
            await MainActor.run {
                withAnimation(.easeOut(duration: 0.3)) {
                    items = newItems
                    if let startTime = startTime {
                        let elapsed = Date().timeIntervalSince(startTime)
                        loadTime = String(format: "%.2fs", elapsed)
                    }
                    isLoading = false
                }
            }
        }
    }
    
    private func generateItems(count: Int) async -> [PerformanceItem] {
        return await withTaskGroup(of: [PerformanceItem].self) { group in
            let batchSize = 100
            let batches = (count + batchSize - 1) / batchSize
            
            for batch in 0..<batches {
                group.addTask {
                    let startIndex = batch * batchSize
                    let endIndex = min(startIndex + batchSize, count)
                    
                    return (startIndex..<endIndex).map { index in
                        PerformanceItem(
                            id: UUID(),
                            title: "Item \(index + 1)",
                            subtitle: "High performance rendering",
                            value: Double.random(in: 0...100),
                            category: ItemCategory.allCases.randomElement() ?? .primary
                        )
                    }
                }
            }
            
            var allItems: [PerformanceItem] = []
            for await batch in group {
                allItems.append(contentsOf: batch)
            }
            
            return allItems.sorted { $0.title < $1.title }
        }
    }
}

struct PerformanceItem: Identifiable, Hashable {
    let id: UUID
    let title: String
    let subtitle: String
    let value: Double
    let category: ItemCategory
}

enum ItemCategory: String, CaseIterable {
    case primary = "Primary"
    case secondary = "Secondary"
    case success = "Success"
    case warning = "Warning"
    
    var color: Color {
        switch self {
        case .primary: return .blue
        case .secondary: return .gray
        case .success: return .green
        case .warning: return .orange
        }
    }
}

struct PerformanceMetric: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.tint)
            
            Text(value)
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .glassEffect()
    }
}

struct PerformanceListItem: View {
    let item: PerformanceItem
    
    var body: some View {
        HStack(spacing: 12) {
            // Category indicator
            RoundedRectangle(cornerRadius: 4)
                .fill(item.category.color)
                .frame(width: 4, height: 40)
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(item.subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // Value indicator
            VStack(alignment: .trailing, spacing: 4) {
                Text(String(format: "%.1f", item.value))
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .monospacedDigit()
                
                ProgressView(value: item.value, total: 100)
                    .progressViewStyle(.linear)
                    .frame(width: 60)
                    .tint(item.category.color)
            }
        }
        .padding(.vertical, 4)
    }
}

struct ConcurrentOperationsDemo: View {
    @State private var tasks: [TaskStatus] = []
    @State private var isRunning = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Concurrent Programming")
                .font(.headline)
            
            Text("Demonstrates improved concurrent task handling")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Button(isRunning ? "Running..." : "Run Concurrent Tasks") {
                runConcurrentTasks()
            }
            .buttonStyle(.borderedProminent)
            .disabled(isRunning)
            
            if !tasks.isEmpty {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                    ForEach(tasks, id: \.id) { task in
                        TaskStatusView(task: task)
                    }
                }
            }
        }
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
    
    private func runConcurrentTasks() {
        isRunning = true
        tasks = (1...6).map { TaskStatus(id: $0, name: "Task \($0)", status: .pending) }
        
        Task {
            await withTaskGroup(of: Void.self) { group in
                for index in tasks.indices {
                    group.addTask {
                        await runSingleTask(index: index)
                    }
                }
            }
            
            await MainActor.run {
                isRunning = false
            }
        }
    }
    
    private func runSingleTask(index: Int) async {
        await MainActor.run {
            tasks[index].status = .running
        }
        
        // Simulate work
        try? await Task.sleep(nanoseconds: UInt64.random(in: 1_000_000_000...3_000_000_000))
        
        await MainActor.run {
            tasks[index].status = .completed
        }
    }
}

struct TaskStatus {
    let id: Int
    let name: String
    var status: TaskStatusType
}

enum TaskStatusType {
    case pending, running, completed
    
    var color: Color {
        switch self {
        case .pending: return .gray
        case .running: return .blue
        case .completed: return .green
        }
    }
    
    var icon: String {
        switch self {
        case .pending: return "clock"
        case .running: return "arrow.clockwise"
        case .completed: return "checkmark.circle.fill"
        }
    }
}

struct TaskStatusView: View {
    let task: TaskStatus
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: task.status.icon)
                .font(.title3)
                .foregroundStyle(task.status.color)
                .symbolEffect(.pulse, isActive: task.status == .running)
            
            Text(task.name)
                .font(.caption)
                .fontWeight(.medium)
        }
        .frame(height: 60)
        .frame(maxWidth: .infinity)
        .background(task.status.color.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(task.status.color.opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview {
    ScrollView {
        PerformanceDemo()
    }
}