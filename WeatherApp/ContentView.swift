import SwiftUI
import WeatherKit
import WeatherUI

struct ContentView: View {
    @State private var viewModel = WeatherViewModel(repository: WeatherRepository())
    @State private var showingSearch = false
    @State private var motionManager = MotionManager()

    private var weather: Weather? { viewModel.currentWeather }

    var body: some View {
        ZStack {
            // Animated mesh gradient background
            AnimatedGradientBackground(
                condition: weather?.condition,
                isDay: weather?.isDay ?? true
            )
            .parallax(manager: motionManager, magnitude: 3)

            // Weather particles (rain, snow, fog)
            WeatherParticleView(
                condition: weather?.condition,
                isThunderstorm: weather?.condition == .thunderstorm,
                windDirection: weather?.windDirection ?? 0
            )
            .parallax(manager: motionManager, magnitude: 8)

            // Main content
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    if viewModel.isLoading {
                        LoadingView()
                    } else if let error = viewModel.errorMessage, weather == nil {
                        ErrorView(message: error) {
                            Task { await viewModel.loadWeatherForCurrentLocation() }
                        }
                    } else if let currentWeather = weather {
                        CurrentWeatherView(viewModel: viewModel)
                        if !viewModel.hourlyForecast.isEmpty {
                            TemperatureCurveView(
                                forecasts: viewModel.hourlyForecast,
                                displayTemperature: viewModel.displayTemperature
                            )
                        }
                        ExpandableDetailCard(weather: currentWeather)
                        if !viewModel.dailyForecast.isEmpty {
                            DailyForecastCard(viewModel: viewModel)
                        }
                    } else {
                        EmptyStateView {
                            Task { await viewModel.loadWeatherForCurrentLocation() }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 60)
                .padding(.bottom, 40)
            }
            .overlay(alignment: .topTrailing) {
                Button { showingSearch = true } label: {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 36, height: 36)
                        .background(.white.opacity(0.2))
                        .clipShape(Circle())
                }
                .padding(.horizontal, 16)
                .padding(.top, 54)
            }
        }
        .ignoresSafeArea()
        .task {
            await viewModel.loadWeatherForCurrentLocation()
        }
        .onAppear {
            motionManager.start()
        }
        .onDisappear {
            motionManager.stop()
        }
        .sheet(isPresented: $showingSearch) {
            SearchView(viewModel: viewModel, isPresented: $showingSearch)
        }
    }
}

#Preview {
    ContentView()
}
