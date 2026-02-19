import Foundation

/// Protocol defining weather service operations
public protocol WeatherServiceProtocol: Sendable {
    func getCurrentWeather(latitude: Double, longitude: Double) async throws -> Weather
    func getHourlyForecast(latitude: Double, longitude: Double, hours: Int) async throws -> [HourlyForecast]
    func getDailyForecast(latitude: Double, longitude: Double, days: Int) async throws -> [DailyForecast]
    func searchLocations(query: String) async throws -> [Location]
}

/// Service for fetching weather data from Open-Meteo API
public actor WeatherService: WeatherServiceProtocol {
    private let baseURL = "https://api.open-meteo.com/v1"
    private let geocodingURL = "https://geocoding-api.open-meteo.com/v1"
    private let urlSession: URLSession

    public init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }

    public func getCurrentWeather(latitude: Double, longitude: Double) async throws -> Weather {
        let url = buildWeatherURL(
            latitude: latitude,
            longitude: longitude,
            current: ["temperature_2m", "apparent_temperature", "weather_code", "wind_speed_10m", "wind_direction_10m", "is_day"]
        )

        let response: OpenMeteoResponse = try await fetchData(from: url)

        guard let current = response.current else {
            throw WeatherServiceError.missingData
        }

        let formatter = datetimeFormatter(timezone: response.timezone)

        return Weather(
            temperature: current.temperature,
            feelsLike: current.apparentTemperature,
            condition: WeatherCondition(wmoCode: current.weatherCode, isDay: current.isDay == 1),
            windSpeed: current.windSpeed,
            windDirection: current.windDirection,
            humidity: nil,
            pressure: nil,
            visibility: nil,
            uvIndex: nil,
            timestamp: formatter.date(from: current.time) ?? Date(),
            isDay: current.isDay == 1
        )
    }

    public func getHourlyForecast(latitude: Double, longitude: Double, hours: Int = 24) async throws -> [HourlyForecast] {
        let url = buildWeatherURL(
            latitude: latitude,
            longitude: longitude,
            hourly: ["temperature_2m", "weather_code", "precipitation", "precipitation_probability"],
            forecastDays: 2
        )

        let response: OpenMeteoResponse = try await fetchData(from: url)

        guard let hourly = response.hourly else {
            throw WeatherServiceError.missingData
        }

        let formatter = datetimeFormatter(timezone: response.timezone)
        let now = Date()

        let futureForecasts = (0..<hourly.time.count).compactMap { index -> HourlyForecast? in
            guard let date = formatter.date(from: hourly.time[index]) else { return nil }
            // Skip hours in the past
            guard date >= now.addingTimeInterval(-3600) else { return nil }

            return HourlyForecast(
                time: date,
                temperature: hourly.temperature[index],
                condition: WeatherCondition(wmoCode: hourly.weatherCode[index]),
                precipitation: hourly.precipitation[index],
                precipitationProbability: hourly.precipitationProbability[index]
            )
        }

        return Array(futureForecasts.prefix(hours))
    }

    public func getDailyForecast(latitude: Double, longitude: Double, days: Int = 7) async throws -> [DailyForecast] {
        let url = buildWeatherURL(
            latitude: latitude,
            longitude: longitude,
            daily: ["weather_code", "temperature_2m_max", "temperature_2m_min", "precipitation_sum", "precipitation_probability_max", "sunrise", "sunset"],
            forecastDays: days
        )

        let response: OpenMeteoResponse = try await fetchData(from: url)

        guard let daily = response.daily else {
            throw WeatherServiceError.missingData
        }

        let dateFormatter = dateOnlyFormatter(timezone: response.timezone)
        let sunFormatter = datetimeFormatter(timezone: response.timezone)

        return (0..<daily.time.count).compactMap { index in
            guard let date = dateFormatter.date(from: daily.time[index]) else { return nil }

            let sunrise = index < daily.sunrise.count ? sunFormatter.date(from: daily.sunrise[index]) : nil
            let sunset = index < daily.sunset.count ? sunFormatter.date(from: daily.sunset[index]) : nil

            return DailyForecast(
                date: date,
                condition: WeatherCondition(wmoCode: daily.weatherCode[index]),
                temperatureHigh: daily.temperatureMax[index],
                temperatureLow: daily.temperatureMin[index],
                precipitation: daily.precipitationSum[index],
                precipitationProbability: daily.precipitationProbabilityMax[index],
                sunrise: sunrise,
                sunset: sunset
            )
        }
    }

    public func searchLocations(query: String) async throws -> [Location] {
        guard !query.isEmpty else {
            return []
        }

        var components = URLComponents(string: "\(geocodingURL)/search")
        components?.queryItems = [
            URLQueryItem(name: "name", value: query),
            URLQueryItem(name: "count", value: "10"),
            URLQueryItem(name: "language", value: "en"),
            URLQueryItem(name: "format", value: "json")
        ]

        guard let url = components?.url else {
            throw WeatherServiceError.invalidURL
        }

        let response: GeocodingResponse = try await fetchData(from: url)
        return response.results?.map { $0.toDomain() } ?? []
    }

    // MARK: - Private Helpers

    private func buildWeatherURL(
        latitude: Double,
        longitude: Double,
        current: [String]? = nil,
        hourly: [String]? = nil,
        daily: [String]? = nil,
        forecastDays: Int = 1
    ) -> URL {
        var components = URLComponents(string: "\(baseURL)/forecast")!
        var queryItems = [
            URLQueryItem(name: "latitude", value: String(latitude)),
            URLQueryItem(name: "longitude", value: String(longitude)),
            URLQueryItem(name: "forecast_days", value: String(forecastDays)),
            URLQueryItem(name: "temperature_unit", value: "celsius"),
            URLQueryItem(name: "wind_speed_unit", value: "kmh"),
            URLQueryItem(name: "precipitation_unit", value: "mm"),
            URLQueryItem(name: "timezone", value: "auto")
        ]

        if let current = current {
            queryItems.append(URLQueryItem(name: "current", value: current.joined(separator: ",")))
        }
        if let hourly = hourly {
            queryItems.append(URLQueryItem(name: "hourly", value: hourly.joined(separator: ",")))
        }
        if let daily = daily {
            queryItems.append(URLQueryItem(name: "daily", value: daily.joined(separator: ",")))
        }

        components.queryItems = queryItems
        return components.url!
    }

    /// Formatter for "yyyy-MM-dd'T'HH:mm" strings (current time, hourly times, sunrise/sunset)
    private func datetimeFormatter(timezone: String) -> DateFormatter {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd'T'HH:mm"
        f.timeZone = TimeZone(identifier: timezone) ?? .current
        return f
    }

    /// Formatter for "yyyy-MM-dd" strings (daily dates)
    private func dateOnlyFormatter(timezone: String) -> DateFormatter {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.timeZone = TimeZone(identifier: timezone) ?? .current
        return f
    }

    private func fetchData<T: Decodable>(from url: URL) async throws -> T {
        let (data, response) = try await urlSession.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw WeatherServiceError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw WeatherServiceError.httpError(statusCode: httpResponse.statusCode)
        }

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw WeatherServiceError.decodingError(error)
        }
    }
}

// MARK: - Errors

public enum WeatherServiceError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingError(Error)
    case missingData

    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(let statusCode):
            return "HTTP error: \(statusCode)"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .missingData:
            return "Missing required data in response"
        }
    }
}