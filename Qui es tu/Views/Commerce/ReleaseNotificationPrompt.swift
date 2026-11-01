import SwiftUI

struct ReleaseNotificationPrompt: View {
    @Environment(ReleaseNotificationStore.self) private var notifications

    var body: some View {
        if !notifications.hasAnsweredPrompt {
            VStack(alignment: .leading, spacing: 12) {
                Text("On se retrouve au prochain quiz ?").font(.headline)
                Text("Reçois une notification quand un nouveau quiz sort, y compris les quiz payants. Tu peux désactiver ces alertes à tout moment dans les réglages.")
                    .font(.subheadline)
                Button("Me prévenir des nouveautés") { Task { await notifications.setEnabled(true) } }
                    .buttonStyle(.bordered).disabled(notifications.isBusy)
                Button("Pas maintenant") { notifications.dismissPrompt() }.font(.footnote)
            }
            .padding(16)
            .background(QuizTheme.surface, in: .rect(cornerRadius: 18))
        }
    }
}
