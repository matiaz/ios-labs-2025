# Foundation Models - Summary

## Overview
Foundation Models is Apple's on-device Large Language Model (LLM) framework introduced in WWDC 2025. It provides a 3 billion parameter model, quantized to 2 bits, designed to run entirely on-device for privacy-preserving AI interactions across macOS, iOS, iPadOS, and visionOS.

## Key Features

### 1. On-Device Processing
- **Privacy First**: All processing happens locally on the user's device
- **No Network Required**: Works offline without sending data to external servers
- **Device-Scale Model**: Optimized for mobile and desktop hardware constraints
- **Cross-Platform**: Available on all Apple platforms

### 2. Guided Generation (`@Generable`)
- **Type-Safe Outputs**: Generate structured Swift objects directly from prompts
- **Constrained Decoding**: Guarantees structural correctness and prevents hallucinations
- **Compile-Time Schema**: Uses `@Generable` macro for schema generation
- **Guide Constraints**: Fine-tune generation with numerical ranges, array constraints, and regex patterns

### 3. Snapshot Streaming
- **Progressive Updates**: Stream partial generations with optional properties
- **SwiftUI Integration**: Seamlessly integrates with SwiftUI for real-time UI updates
- **Responsive UX**: Allows users to see content being generated in real-time

### 4. Tool Calling
- **Autonomous Execution**: Model can call custom app-defined tools
- **Device API Access**: Privately access Contacts, Calendar, MapKit, and other system APIs
- **Source Citation**: Helps prevent hallucinations by citing authoritative sources
- **Custom Functions**: Define tools with names, descriptions, and implementation methods

### 5. Stateful Sessions
- **Context Persistence**: Maintains conversation context across multiple interactions
- **Custom Instructions**: Support for specialized use cases and system prompts
- **Content Tagging**: Advanced text analysis capabilities
- **Multi-Turn Conversations**: Natural dialogue flow preservation

## Core Components

### Language Model Sessions
```swift
// Stateful conversations with persistent transcript
// Customizable instructions and sampling methods
// Error handling for context size and language support
```

### Sampling Methods
- **Random** (default): Natural variation in responses
- **Greedy**: Deterministic, repeatable outputs
- **Temperature-Based**: Control randomness and creativity levels

### Dynamic Schemas
- Runtime schema creation for flexible use cases
- Type-safe content generation
- Nested and referenced schema support

## Best Practices

### Tool Development
- Use verb-based tool names for clarity
- Keep descriptions concise and specific
- Handle potential errors gracefully
- Be mindful of token usage and context limits

### Performance Optimization
- **Xcode Playgrounds**: Rapid prompt iteration and testing
- **Instruments Profiling**: Template available for latency optimization
- **Feedback Mechanism**: Built-in system for model improvement

## Ideal Use Cases
- **Summarization**: Condensing large text into key points
- **Content Extraction**: Pulling specific information from unstructured data
- **Classification**: Categorizing and organizing content
- **Structured Data Generation**: Creating formatted outputs from natural language
- **Interactive Assistants**: Building conversational AI features

## Limitations
- **Device-Scale Model**: Not designed for world knowledge or factual Q&A
- **Task Decomposition**: Best results when complex tasks are broken into smaller pieces
- **Context Limits**: Finite conversation length due to on-device memory constraints
- **Language Support**: May have limitations based on device capabilities

## Key Advantages
- **Privacy Preservation**: No data leaves the device
- **Low Latency**: Fast response times due to local processing
- **Offline Capability**: Works without internet connection
- **Swift-Native**: Designed specifically for iOS/macOS development
- **Type Safety**: Compile-time guarantees for generated content structure

## Developer Resources
- WWDC 2025 Sessions: 286 (Introduction) and 301 (Advanced Implementation)
- Xcode Playgrounds for experimentation
- Instruments profiling templates
- Built-in feedback and optimization tools