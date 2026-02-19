import Foundation
import Combine
import CoreLocation
import WeatherKit

@MainActor
@Observable
public final class WeatherViewModel {
    // MARK: - Published State
    public private(set) var currentWeather: Weather?
    public private(set) var hourlyForecast: [HourlyForecast] = []
    public private(set) var dailyForecast: [DailyForecast] = []
    public private(set) var currentLocation: Location?
    public private(set) var searchResults: [Location] = []
    public private(set) var isLoading = false
    public private(set) var errorMessage: String?
    public var useFahrenheit = false

    public func toggleTemperatureUnit() {
        useFahrenheit.toggle()
    }

    public func displayTemperature(_ celsius: Double) -> String {
        let value = useFahrenheit ? (celsius * 9/5) + 32 : celsius
        return "\(Int(value))°"
    }

    // MARK: - Dependencies
    private let repository: WeatherRepositoryProtocol
    private let locationManager: LocationManager

    public init(repository: WeatherRepositoryProtocol, locationManager: LocationManager = LocationManager()) {
        self.repository = repository
        self.locationManager = locationManager
    }

    // MARK: - Public Methods

    public func loadWeatherForCurrentLocation() async {
        isLoading = true
        errorMessage = nil

        do {
            let coordinate = try await locationManager.requestLocation()

            // Reverse-geocode coordinates to get actual city name
            let clLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            let geocoder = CLGeocoder()
            let placemarks = try? await geocoder.reverseGeocodeLocation(clLocation)
            let placemark = placemarks?.first

            let location = Location(
                name: placemark?.locality ?? "Current Location",
                latitude: coordinate.latitude,
                longitude: coordinate.longitude,
                country: placemark?.country,
                admin1: placemark?.administrativeArea
            )

            currentLocation = location
            await loadWeather(for: location)
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    public func loadWeather(for location: Location) async {
        isLoading = true
        errorMessage = nil
        currentLocation = location

        async let weather = repository.fetchCurrentWeather(for: location)
        async let hourly = repository.fetchHourlyForecast(for: location, hours: 24)
        async let daily = repository.fetchDailyForecast(for: location, days: 7)

        do {
            let (weatherResult, hourlyResult, dailyResult) = try await (weather, hourly, daily)
            currentWeather = weatherResult
            hourlyForecast = hourlyResult
            dailyForecast = dailyResult
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    public func searchLocations(query: String) async {
        guard !query.isEmpty else {
            searchResults = []
            return
        }

        do {
            searchResults = try await repository.searchLocations(query: query)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    public func selectLocation(_ location: Location) async {
        searchResults = []
        await loadWeather(for: location)
    }
}

// MARK: - Location Manager

@MainActor
public final class LocationManager: NSObject, ObservableObject {
    private let manager = CLLocationManager()
    private var locationContinuation: CheckedContinuation<CLLocationCoordinate2D, Error>?
    private var authorizationContinuation: CheckedContinuation<CLAuthorizationStatus, Never>?

    public override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
    }

    public func requestLocation() async throws -> CLLocationCoordinate2D {
        let status = manager.authorizationStatus

        // Request authorization if not determined
        if status == .notDetermined {
            let newStatus = await requestAuthorization()
            
            #if os(iOS)
            guard newStatus == .authorizedWhenInUse || newStatus == .authorizedAlways else {
                throw LocationError.unauthorized
            }
            #elseif os(macOS)
            guard newStatus == .authorizedAlways else {
                throw LocationError.unauthorized
            }
            #endif
        } else {
            // Check existing authorization
            #if os(iOS)
            guard status == .authorizedWhenInUse || status == .authorizedAlways else {
                throw LocationError.unauthorized
            }
            #elseif os(macOS)
            guard status == .authorizedAlways else {
                throw LocationError.unauthorized
            }
            #endif
        }

        return try await withCheckedThrowingContinuation { continuation in
            self.locationContinuation = continuation
            manager.requestLocation()
        }
    }
    
    private func requestAuthorization() async -> CLAuthorizationStatus {
        await withCheckedContinuation { continuation in
            self.authorizationContinuation = continuation
            manager.requestWhenInUseAuthorization()
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    nonisolated public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }

        Task { @MainActor in
            locationContinuation?.resume(returning: location.coordinate)
            locationContinuation = nil
        }
    }

    nonisolated public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            locationContinuation?.resume(throwing: error)
            locationContinuation = nil
        }
    }

    nonisolated public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        Task { @MainActor in
            authorizationContinuation?.resume(returning: status)
            authorizationContinuation = nil
        }
    }
}

public enum LocationError: Error, LocalizedError {
    case unauthorized

    public var errorDescription: String? {
        switch self {
        case .unauthorized:
            return "Location access is required to show weather for your area. Please enable location permissions in Settings."
        }
    }
}
