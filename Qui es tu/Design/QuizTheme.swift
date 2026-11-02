import SwiftUI

/// Semantic colors shared by the quiz's light and dark appearances.
enum QuizTheme {
    static let background = Color("QuizBackground")
    static let surface = Color("QuizSurface")
    static let ink = Color("QuizInk")
    static let secondary = Color("QuizSecondary")
    static let border = Color("QuizBorder")
    static let question = Color("QuizQuestion")
    static let questionShadow = Color("QuizQuestionShadow")
    static let selection = Color("QuizSelection")
    static let topWash = Color("QuizTopWash")
    static let bottomWash = Color("QuizBottomWash")
    static let accent = Color.mint
    static let questionInk = Color(red: 16 / 255, green: 44 / 255, blue: 65 / 255)
    static let actionInk = Color(red: 9 / 255, green: 54 / 255, blue: 47 / 255)

    static let pagePadding: CGFloat = 22
    static let spacing: CGFloat = 24
    static let cardRadius: CGFloat = 24
    static let answerRadius: CGFloat = 18
    static let maxWidth: CGFloat = 560
}
