import SwiftUI

struct ResultHistoryView: View {
    @Environment(ResultHistoryStore.self) private var history

    var body: some View {
        List {
            Section {
                ForEach(history.results) { result in
                    NavigationLink {
                        SavedResultDetail(result: result)
                    } label: {
                        SavedResultRow(result: result)
                    }
                }
                .onDelete { offsets in
                    let ids = Set(offsets.map { history.results[$0].id })
                    history.delete(ids: ids)
                }
            } footer: {
                if !history.results.isEmpty {
                    Text("Retrouve tes portraits ou glisse vers la gauche pour en supprimer un. Ils sont conservés uniquement sur cet appareil.")
                }
            }
        }
        .overlay {
            if history.results.isEmpty {
                ContentUnavailableView(
                    "Ton histoire commence ici",
                    systemImage: "sparkles",
                    description: Text("Termine un quiz pour retrouver ton portrait ici.")
                )
                .accessibilityIdentifier("history.empty")
            }
        }
        .navigationTitle("Mes portraits")
        .toolbar {
            if !history.results.isEmpty {
                EditButton()
            }
        }
    }
}
