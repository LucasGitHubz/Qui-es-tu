import SwiftUI

struct PrivacyInformationView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Tes données").font(.largeTitle.bold())
                Text("Aucun compte supplémentaire n’est nécessaire. Les achats sont gérés par Apple. Leur preuve est vérifiée pour donner accès aux quiz achetés.")
                Text("Tes portraits sont enregistrés sur cet appareil. Tu peux les effacer depuis les réglages de l’app. Tes réponses et tes portraits ne sont pas envoyés dans les statistiques.")
                Text("Les statistiques d’utilisation et les rapports de plantage nous aident à améliorer l’app. Les notifications de nouveaux quiz sont facultatives.")
                Text("Si les publicités sont activées, Google AdMob peut traiter des informations techniques pour diffuser et mesurer les annonces. Les préférences publicitaires sont accessibles depuis les réglages de l’app lorsqu’elles sont requises. Premium ne demande aucune annonce.")
                Text("Contact : overtechapps@gmail.com")
            }.padding(24)
        }.navigationTitle("Confidentialité")
    }
}
