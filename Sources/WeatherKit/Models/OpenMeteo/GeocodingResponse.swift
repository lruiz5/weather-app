import Foundation

/// Open-Meteo Geocoding API response
struct GeocodingResponse: Codable, Sendable {
    let results: [GeocodingLocation]?
}

/// Location result from geocoding API
struct GeocodingLocation: Codable, Sendable {
    let id: Int
    let name: String
    let latitude: Double
    let longitude: Double
    let country: String
    let countryCode: String
    let admin1: String?
    let admin2: String?
    let timezone: String

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case latitude
        case longitude
        case country
        case countryCode = "country_code"
        case admin1
        case admin2
        case timezone
    }

    /// Convert to domain Location model
    func toDomain() -> Location {
        Location(
            name: name,
            latitude: latitude,
            longitude: longitude,
            country: country,
            admin1: admin1,
            timezone: timezone
        )
    }
}
