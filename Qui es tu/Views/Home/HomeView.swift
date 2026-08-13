import SwiftUI

struct HomeView: View {
    let quizzes: [Quizz]
    let onSelect: (Quizz) -> Void

    var body: some View {
        VStack {
            HomeHeader()

            ScrollView {
                HomeQuizGrid(quizzes: quizzes, onSelect: onSelect)
            }

            Spacer()
        }
        .background {
            HomeBackground()
        }
    }
}
