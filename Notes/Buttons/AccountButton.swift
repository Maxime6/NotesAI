import SwiftUI

struct AccountButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "person.crop.circle")
                .font(.system(size: 24))
                .foregroundColor(.primary)
                .padding()
                .background(Color(.systemBackground))
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        }
        .padding(.top, 16)
        .padding(.trailing)
        .ignoresSafeArea()
    }
}

#Preview {
    AccountButton(action: {})
        .previewLayout(.sizeThatFits)
}
