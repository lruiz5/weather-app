import Foundation

/// Open-Meteo API response structure
struct OpenMeteoResponse: Codable, Sendable {
    let latitude: Double
    let longitude: Double
    let timezone: String
    let timezoneAbbreviation: String
    let elevation: Double
    let current: CurrentWeather?
    let hourly: HourlyWeather?
    let daily: DailyWeather?

    enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
        case timezone
        case timezoneAbbreviation = "timezone_abbreviation"
        case elevation
        case current
        case hourly
        case daily
    }
}

/// Current weather conditions
struct CurrentWeather: Codable, Sendable {
    let time: String
    let temperature: Double
    let apparentTemperature: Double
    let weatherCode: Int
    let windSpeed: Double
    let windDirection: Int
    let isDay: Int
    let relativeHumidity: Int?
    let surfacePressure: Double?
    let visibility: Double?
    let uvIndex: Double?

    enum CodingKeys: String, CodingKey {
        case time
        case temperature = "temperature_2m"
        case apparentTemperature = "apparent_temperature"
        case weatherCode = "weather_code"
        case windSpeed = "wind_speed_10m"
        case windDirection = "wind_direction_10m"
        case isDay = "is_day"
        case relativeHumidity = "relative_humidity_2m"
        case surfacePressure = "surface_pressure"
        case visibility
        case uvIndex = "uv_index"
    }
}

/// Hourly weather forecast
struct HourlyWeather: Codable, Sendable {
    let time: [String]
    let temperature: [Double]
    let weatherCode: [Int]
    let precipitation: [Double]
    let precipitationProbability: [Int]
    let isDay: [Int]

    enum CodingKeys: String, CodingKey {
        case time
        case temperature = "temperature_2m"
        case weatherCode = "weather_code"
        case precipitation
        case precipitationProbability = "precipitation_probability"
        case isDay = "is_day"
    }
}

/// Daily weather forecast
struct DailyWeather: Codable, Sendable {
    let time: [String]
    let weatherCode: [Int]
    let temperatureMax: [Double]
    let temperatureMin: [Double]
    let precipitationSum: [Double]
    let precipitationProbabilityMax: [Int]
    let sunrise: [String]
    let sunset: [String]

    enum CodingKeys: String, CodingKey {
        case time
        case weatherCode = "weather_code"
        case temperatureMax = "temperature_2m_max"
        case temperatureMin = "temperature_2m_min"
        case precipitationSum = "precipitation_sum"
        case precipitationProbabilityMax = "precipitation_probability_max"
        case sunrise
        case sunset
    }
}
