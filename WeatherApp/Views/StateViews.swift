import SwiftUI
import WeatherUI

struct LoadingView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .progressViewStyle(.circular)
                .tint(.white)
                .scaleEffect(1.4)
            Text("Loading weather…")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.75))
        }
        .padding(.top, 120)
    }
}

struct ErrorView: View {
    let message: String
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 52))
                .foregroundStyle(.yellow)

            Text("Something went wrong")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(.white)

            Text(message)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.75))
                .multilineTextAlignment(.center)

            Button(action: onRetry) {
                Text("Try Again")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(.white.opacity(0.2))
                    .clipShape(Capsule())
            }
        }
        .padding(.top, 80)
        .padding(.horizontal, 32)
    }
}

struct EmptyStateView: View {
    let onLoad: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "cloud.sun.fill")
                .font(.system(size: 64))
                .symbolRenderingMode(.multicolor)

            Text("No Weather Data")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(.white)

            Button(action: onLoad) {
                Text("Load Weather")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(.white.opacity(0.2))
                    .clipShape(Capsule())
            }
        }
        .padding(.top, 80)
    }
}
