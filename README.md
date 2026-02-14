# WeatherApp

A modern iOS weather application built with Swift 6.0, featuring clean architecture and real-time weather data.

## Features

- ✅ Real-time weather data from Open-Meteo API (free, no API key required)
- ✅ Current weather conditions with temperature, wind speed, and weather icons
- ✅ Hourly forecast (24 hours)
- ✅ 7-day daily forecast
- ✅ Location-based weather using GPS
- ✅ City search with autocomplete
- ✅ Clean, modern SwiftUI interface
- ✅ Support for multiple locations
- 🚧 Widgets (planned)
- 🚧 Live Activities (planned)

## Architecture

This project follows Clean Architecture principles with modular design:

- **WeatherKit** (SPM Module): Core domain logic, models, services, and repositories
  - Domain models (Weather, Location, Forecasts)
  - Weather service (Open-Meteo API integration)
  - Repository pattern for data access
  
- **WeatherUI** (SPM Module): SwiftUI views and view models
  - WeatherViewModel with @Observable macro
  - LocationManager for GPS access
  - Reusable UI components

- **WeatherApp** (Main Target): iOS application
  - App entry point
  - ContentView with weather display
  - Info.plist configuration

## Requirements

- iOS 18.0+
- Xcode 16.0+
- Swift 6.0+
- Location permissions (for current location weather)

## Project Structure

```
weather-app/
├── Package.swift                    # Swift Package Manager configuration
├── Sources/
│   ├── WeatherKit/                  # Core domain module
│   │   ├── Models/
│   │   │   ├── Domain/              # Domain models
│   │   │   └── OpenMeteo/           # API response models
│   │   ├── Services/                # Weather API service
│   │   └── Repositories/            # Data repositories
│   └── WeatherUI/                   # UI module
│       ├── ViewModels/              # View models
│       ├── Views/                   # SwiftUI views
│       └── Components/              # Reusable components
├── WeatherApp/                      # Main app target
│   ├── WeatherApp.swift             # App entry point
│   ├── ContentView.swift            # Main view
│   ├── Info.plist                   # App configuration
│   └── Assets.xcassets/             # App assets
└── WeatherApp.xcodeproj/            # Xcode project
```

## Getting Started

1. Clone the repository
2. Open `WeatherApp.xcodeproj` in Xcode
3. Select your development team in project settings
4. Build and run on simulator or device
5. Grant location permissions when prompted

## API Integration

This app uses the **Open-Meteo API** (https://open-meteo.com/):
- ✅ Completely free, no API key required
- ✅ No rate limits for reasonable use
- ✅ Provides current weather, hourly, and daily forecasts
- ✅ Geocoding for location search
- ✅ WMO weather codes for conditions

## Technical Highlights

- **Swift 6.0** with strict concurrency checking
- **SwiftUI** with @Observable macro (iOS 17+)
- **Async/await** for all network operations
- **Actor isolation** for thread-safe services
- **Protocol-oriented design** for testability
- **Clean Architecture** with clear separation of concerns
- **No external dependencies** - pure Swift and SwiftUI

## Known Issues

- City name display for current location may show "Current Location" instead of actual city name
- Requires manual location search for best results

## Future Enhancements

- [ ] Home Screen widgets
- [ ] Lock Screen widgets
- [ ] Live Activities for weather alerts
- [ ] Weather radar/maps
- [ ] Precipitation notifications
- [ ] Dark mode optimizations
- [ ] iPad support
- [ ] Unit and UI tests

## License

MIT
