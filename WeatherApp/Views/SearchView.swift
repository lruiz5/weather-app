import SwiftUI
import WeatherUI

struct SearchView: View {
    let viewModel: WeatherViewModel
    @Binding var isPresented: Bool
    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.searchResults) { location in
                    Button {
                        Task {
                            await viewModel.selectLocation(location)
                            isPresented = false
                        }
                    } label: {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(location.name)
                                .font(.headline)
                                .foregroundStyle(.primary)
                            Text(location.displayName)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Search Location")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Search for a city")
            .onChange(of: searchText) { _, newValue in
                Task { await viewModel.searchLocations(query: newValue) }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { isPresented = false }
                }
            }
        }
    }
}
