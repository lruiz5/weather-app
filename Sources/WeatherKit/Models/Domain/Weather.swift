import Foundation

/// Domain model for current weather
public struct Weather: Sendable, Identifiable {
    public let id = UUID()
    public let temperature: Double
    public let feelsLike: Double?
    public let condition: WeatherCondition
    public let windSpeed: Double
    public let windDirection: Int
    public let humidity: Double?
    public let pressure: Double?
    public let visibility: Double?
    public let uvIndex: Double?
    public let timestamp: Date
    public let isDay: Bool

    public var temperatureFahrenheit: Double {
        (temperature * 9/5) + 32
    }

    public init(
        temperature: Double,
        feelsLike: Double? = nil,
        condition: WeatherCondition,
        windSpeed: Double,
        windDirection: Int,
        humidity: Double? = nil,
        pressure: Double? = nil,
        visibility: Double? = nil,
        uvIndex: Double? = nil,
        timestamp: Date,
        isDay: Bool
    ) {
        self.temperature = temperature
        self.feelsLike = feelsLike
        self.condition = condition
        self.windSpeed = windSpeed
        self.windDirection = windDirection
        self.humidity = humidity
        self.pressure = pressure
        self.visibility = visibility
        self.uvIndex = uvIndex
        self.timestamp = timestamp
        self.isDay = isDay
    }
}

/// Domain model for hourly forecast
public struct HourlyForecast: Sendable, Identifiable {
    public let id = UUID()
    public let time: Date
    public let temperature: Double
    public let condition: WeatherCondition
    public let precipitation: Double
    public let precipitationProbability: Int

    public var temperatureFahrenheit: Double {
        (temperature * 9/5) + 32
    }

    public init(
        time: Date,
        temperature: Double,
        condition: WeatherCondition,
        precipitation: Double,
        precipitationProbability: Int
    ) {
        self.time = time
        self.temperature = temperature
        self.condition = condition
        self.precipitation = precipitation
        self.precipitationProbability = precipitationProbability
    }
}

/// Domain model for daily forecast
public struct DailyForecast: Sendable, Identifiable {
    public let id = UUID()
    public let date: Date
    public let condition: WeatherCondition
    public let temperatureHigh: Double
    public let temperatureLow: Double
    public let precipitation: Double
    public let precipitationProbability: Int

    public var temperatureHighFahrenheit: Double {
        (temperatureHigh * 9/5) + 32
    }

    public var temperatureLowFahrenheit: Double {
        (temperatureLow * 9/5) + 32
    }

    public init(
        date: Date,
        condition: WeatherCondition,
        temperatureHigh: Double,
        temperatureLow: Double,
        precipitation: Double,
        precipitationProbability: Int
    ) {
        self.date = date
        self.condition = condition
        self.temperatureHigh = temperatureHigh
        self.temperatureLow = temperatureLow
        self.precipitation = precipitation
        self.precipitationProbability = precipitationProbability
    }
}

/// Weather conditions based on WMO Weather interpretation codes
public enum WeatherCondition: Sendable {
    case clear
    case partlyCloudy
    case cloudy
    case overcast
    case fog
    case drizzle
    case rain
    case freezingRain
    case snow
    case showers
    case thunderstorm
    case unknown

    public init(wmoCode: Int, isDay: Bool = true) {
        switch wmoCode {
        case 0:
            self = .clear
        case 1:
            self = isDay ? .partlyCloudy : .clear
        case 2:
            self = .partlyCloudy
        case 3:
            self = .overcast
        case 45, 48:
            self = .fog
        case 51, 53, 55:
            self = .drizzle
        case 56, 57:
            self = .freezingRain
        case 61, 63, 65:
            self = .rain
        case 66, 67:
            self = .freezingRain
        case 71, 73, 75, 77, 85, 86:
            self = .snow
        case 80, 81, 82:
            self = .showers
        case 95, 96, 99:
            self = .thunderstorm
        default:
            self = .unknown
        }
    }

    public var systemIconName: String {
        switch self {
        case .clear:
            return "sun.max.fill"
        case .partlyCloudy:
            return "cloud.sun.fill"
        case .cloudy:
            return "cloud.fill"
        case .overcast:
            return "smoke.fill"
        case .fog:
            return "cloud.fog.fill"
        case .drizzle:
            return "cloud.drizzle.fill"
        case .rain:
            return "cloud.rain.fill"
        case .freezingRain:
            return "cloud.sleet.fill"
        case .snow:
            return "cloud.snow.fill"
        case .showers:
            return "cloud.heavyrain.fill"
        case .thunderstorm:
            return "cloud.bolt.fill"
        case .unknown:
            return "questionmark.circle.fill"
        }
    }

    public var description: String {
        switch self {
        case .clear:
            return "Clear"
        case .partlyCloudy:
            return "Partly Cloudy"
        case .cloudy:
            return "Cloudy"
        case .overcast:
            return "Overcast"
        case .fog:
            return "Fog"
        case .drizzle:
            return "Drizzle"
        case .rain:
            return "Rain"
        case .freezingRain:
            return "Freezing Rain"
        case .snow:
            return "Snow"
        case .showers:
            return "Showers"
        case .thunderstorm:
            return "Thunderstorm"
        case .unknown:
            return "Unknown"
        }
    }
}

/// Domain model for location
public struct Location: Sendable, Identifiable {
    public let id = UUID()
    public let name: String
    public let latitude: Double
    public let longitude: Double
    public let country: String?
    public let admin1: String?

    public var displayName: String {
        var parts: [String] = [name]
        if let admin1 = admin1 {
            parts.append(admin1)
        }
        if let country = country {
            parts.append(country)
        }
        return parts.joined(separator: ", ")
    }

    public init(
        name: String,
        latitude: Double,
        longitude: Double,
        country: String? = nil,
        admin1: String? = nil
    ) {
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.country = country
        self.admin1 = admin1
    }
}
