
//
//  SwiftUIDebounceTextInput.swift
//
//
//  Created by Alex Nagy on 03.04.2025.
//

import SwiftUI
internal import Combine

/// A generic view model to hold and publish a value.
/// The generic type 'T' must be Equatable so the publisher can compare values.
class DebouncedViewModel<T: Equatable>: ObservableObject {
    @Published var value: T

    init(initialValue: T) {
        self.value = initialValue
    }
}

/// A generic ViewModifier that debounces changes to a binding.
struct DebouncedModifier<T: Equatable>: ViewModifier {
    
    /// The view model that manages the debouncing publisher.
    /// @StateObject ensures it persists for the lifetime of the view.
    @StateObject private var viewModel: DebouncedViewModel<T>
    
    /// A binding to the value that is being changed (e.g., from a TextField).
    @Binding var value: T
    /// A binding to the value that will be updated after the debounce interval.
    @Binding var debouncedValue: T
    /// The time interval to wait before publishing a change.
    let debounceSeconds: TimeInterval
    
    /// Custom initializer to set up the bindings and the view model.
    init(value: Binding<T>, debouncedValue: Binding<T>, debounceSeconds: TimeInterval) {
        self._value = value
        self._debouncedValue = debouncedValue
        self.debounceSeconds = debounceSeconds
        // Initialize the StateObject with the initial value from the binding.
        self._viewModel = StateObject(wrappedValue: DebouncedViewModel(initialValue: value.wrappedValue))
    }
    
    func body(content: Content) -> some View {
        content
            // 1. Listen for debounced changes from the view model's publisher.
            .onReceive(
                viewModel.$value.debounce(for: .seconds(debounceSeconds), scheduler: RunLoop.main)
            ) { receivedValue in
                // 3. When a debounced value is received, update the external debounced binding.
                debouncedValue = receivedValue
            }
            // 2. Watch for immediate changes on the source binding.
            .onChange(of: value) { _, newValue in
                // When the source value changes, update the view model's value.
                // This triggers the debounce timer.
                viewModel.value = newValue
            }
    }
}

extension View {
    /// A convenience extension to apply the debouncing modifier more easily.
    /// This function is generic over any 'Equatable' type.
    public func debounced<T: Equatable>(
        value: Binding<T>,
        debouncedValue: Binding<T>,
        debounceSeconds: TimeInterval = 1.0
    ) -> some View {
        modifier(DebouncedModifier(value: value, debouncedValue: debouncedValue, debounceSeconds: debounceSeconds))
    }
}

struct DebouncedSearchableModifier: ViewModifier {
    
    @State private var text: String = ""
    
    @Binding var debouncedText: String
    let debounceSeconds: TimeInterval
    
    func body(content: Content) -> some View {
        content
            .searchable(text: $text)
            .debounced(value: $text, debouncedValue: $debouncedText, debounceSeconds: debounceSeconds)
    }
}

extension View {
    public func searchable(debouncedText: Binding<String>, for debounceSeconds: TimeInterval = 1.0) -> some View {
        self.modifier(DebouncedSearchableModifier(debouncedText: debouncedText, debounceSeconds: debounceSeconds))
    }
}

struct OnDebouncedSearchableModifier: ViewModifier {
    
    @State private var text: String = ""
    @State private var debouncedText: String = ""
    
    let debounceSeconds: TimeInterval
    let onDebounced: (String) -> Void
    
    func body(content: Content) -> some View {
        content
            .searchable(text: $text)
            .debounced(value: $text, debouncedValue: $debouncedText, debounceSeconds: debounceSeconds)
            .onChange(of: debouncedText) { _, newValue in
                onDebounced(newValue)
            }
    }
}

extension View {
    public func searchable(for debounceSeconds: TimeInterval = 1.0, onDebounced: @escaping (String) -> Void) -> some View {
        self.modifier(OnDebouncedSearchableModifier(debounceSeconds: debounceSeconds, onDebounced: onDebounced))
    }
}
