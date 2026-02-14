import Foundation

/// Repository protocol for weather data access
public protocol WeatherRepositoryProtocol: Sendable {
    func fetchCurrentWeather(for location: Location) async throws -> Weather
    func fetchHourlyForecast(for location: Location, hours: Int) async throws -> [HourlyForecast]
    func fetchDailyForecast(for location: Location, days: Int) async throws -> [DailyForecast]
    func searchLocations(query: String) async throws -> [Location]
}

/// Default implementation of weather repository
public actor WeatherRepository: WeatherRepositoryProtocol {
    private let weatherService: WeatherServiceProtocol

    public init(weatherService: WeatherServiceProtocol = WeatherService()) {
        self.weatherService = weatherService
    }

    public func fetchCurrentWeather(for location: Location) async throws -> Weather {
        try await weatherService.getCurrentWeather(
            latitude: location.latitude,
            longitude: location.longitude
        )
    }

    public func fetchHourlyForecast(for location: Location, hours: Int = 24) async throws -> [HourlyForecast] {
        try await weatherService.getHourlyForecast(
            latitude: location.latitude,
            longitude: location.longitude,
            hours: hours
        )
    }

    public func fetchDailyForecast(for location: Location, days: Int = 7) async throws -> [DailyForecast] {
        try await weatherService.getDailyForecast(
            latitude: location.latitude,
            longitude: location.longitude,
            days: days
        )
    }

    public func searchLocations(query: String) async throws -> [Location] {
        try await weatherService.searchLocations(query: query)
    }
}
