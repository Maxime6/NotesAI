//import SwiftUI
//
//@MainActor
//class ContentViewModel: ObservableObject {
//    @Published var inputText: String = ""
//    @Published var isLoading: Bool = false
//    @Published var showSignUp: Bool = false
//    @Published var generatedNotes: String = ""
//    @Published var error: String? = nil
//
//    private var openAIService: OpenAIService
//
//    init(openAIService: OpenAIService) {
//        self.openAIService = openAIService
//    }
//
//    func updateService(_ service: OpenAIService) {
//        openAIService = service
//        error = nil
//    }
//
//    func generateNotes() async {
//        guard !inputText.isEmpty else { return }
//
//        isLoading = true
//        error = nil
//
//        do {
//            generatedNotes = try await openAIService.generateNotes(from: inputText)
//        } catch {
//            self.error = error.localizedDescription
//        }
//
//        isLoading = false
//    }
//}
