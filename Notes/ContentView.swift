//
//  ContentView.swift
//  Notes
//
//  Created by Maxime Tanter on 21/01/2025.
//

import MarkdownUI
import SwiftUI

struct ContentView: View {
    @State private var inputText: String = ""
    @State private var isLoading: Bool = false
    @State private var showSignUp: Bool = false
    @State private var generatedNotes: String = ""
    @State private var errorMessage: String = ""
    @State private var streamTask: Task<Void, Never>?
    @State private var scrollOffset: CGFloat = 0
    @State var isAnimating: Bool = false
    @Environment(\.colorScheme) var colorScheme

    // Get API key from environment
    private var apiKey: String {
        guard let apiKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] else {
            fatalError("OPENAI_API_KEY environment variable not set")
        }
        return apiKey
    }

    private var openAIService: OpenAIService {
        OpenAIService(apiKey: apiKey)
    }

    private func generateNotes() async {
        guard !inputText.isEmpty else { return }

        withAnimation(.easeIn(duration: 0.5).delay(0.5)) {
            isLoading = true
        }
        errorMessage = ""
        generatedNotes = ""

        // Cancel any existing stream task
        streamTask?.cancel()

        streamTask = Task {
            do {
                for try await chunk in openAIService.streamNotes(from: inputText) {
                    generatedNotes += chunk
                }
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }

    var body: some View {
        ZStack {
            Color(.systemGray6).edgesIgnoringSafeArea(.all)

            ScrollViewReader { proxy in
                ScrollView {
                    GeometryReader { geometry in
                        Color.clear.onChange(of: geometry.frame(in: .named("scroll")).minY) { value in
                            scrollOffset = -value
                            print("Scroll offset: \(scrollOffset)")
                        }
                    }
                    .frame(height: 0)

                    VStack(spacing: 20) {
                        // First card - Generate Notes
                        VStack(spacing: 20) {
                            if !isLoading {
                                Text("Generate Notes")
                                    .customAttribute(EmphasisAttribute())
                                    .transition(TextTransition())
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal, 32)
                            }

                            Text("Transform your thoughts into well-structured notes using artificial intelligence.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 32)

                            // Add PromptTemplates here
                            PromptTemplates { prompt in
                                inputText = prompt
                            }
                            .padding(.vertical, 8)

                            TextEditor(text: $inputText)
                                .frame(height: 200)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(.primary.opacity(0.1), lineWidth: 1)
                                )
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color(.systemBackground))
                                        .shadow(color: .black.opacity(0.05), radius: 15, x: 0, y: 5)
                                )
                                .padding(.horizontal, 32)
                                .overlay {
                                    AnimatedMeshGradient()
                                        .blendMode(colorScheme == .dark ? .colorBurn : .screen)
                                }

                            PrimaryButton(isLoading: isLoading, isDisabled: inputText.isEmpty) {
                                Task {
                                    await generateNotes()
                                }
                            }
                            .padding(.horizontal, 32)

                            if !errorMessage.isEmpty {
                                Text(errorMessage)
                                    .foregroundColor(.red)
                                    .font(.callout)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal, 32)
                            }
                        }
                        .padding(.vertical, 32)
                        .background(Color(.systemBackground))
                        .cornerRadius(44)
                        .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)

                        // Generated Notes card
                        if !generatedNotes.isEmpty {
                            GeneratedNotesCard(content: generatedNotes)
                                .id(1) // Add an ID for scrolling
                                .onChange(of: generatedNotes) {
                                    withAnimation {
                                        proxy.scrollTo(1, anchor: .bottom)
                                    }
                                }
                        }
                    }
                    .padding()
                    .padding(.top, 20)
                    .blur(radius: showSignUp ? 5 : 0)
                    .safeAreaInset(edge: .bottom) {
                        if scrollOffset > 50 {
                            CircleButton(icon: "arrow.up") {
                                withAnimation {
                                    proxy.scrollTo(0, anchor: .top)
                                }
                            }
                            .padding(.bottom, 32)
                        }
                    }
                }
                .coordinateSpace(name: "scroll")
            }

            VStack {
                HStack {
                    Spacer()
                    AccountButton {
                        withAnimation(.spring()) {
                            showSignUp.toggle()
                        }
                    }
                }
                Spacer()
            }

            if showSignUp {
                SignUpView()
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .frame(maxHeight: .infinity)
                    .background(
                        Color
                            .black
                            .opacity(0.7)
                            .allowsHitTesting(false)
                            .ignoresSafeArea()
                    )
                    .zIndex(1)
            }
            
            if isLoading {
                AnimatedMeshGradient()
                    .mask(
                        RoundedRectangle(cornerRadius: 44)
                            .stroke(lineWidth: 44)
                            .blur(radius: 22)
                    )
                    .ignoresSafeArea()
            }
        }
    }
}

#Preview {
    ContentView()
}
