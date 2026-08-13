import SwiftUI

struct HomeHeader: View {
    var body: some View {
        HStack {
            Text("Choisis ton thème")
                .font(.largeTitle.bold())
                .foregroundStyle(.black)
                .padding(.horizontal)
                .padding(.top, 20)
                .accessibilityAddTraits(.isHeader)
                .accessibilityIdentifier("home.title")

            Spacer()
        }
    }
}
