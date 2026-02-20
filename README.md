# WeatherApp

A modern iOS weather application built with Swift 6.0, featuring a celestial clock interface, animated weather effects, and real-time weather data.

## Features

- ✅ Real-time weather data from Open-Meteo API (free, no API key required)
- ✅ **Celestial clock** — 24-hour sun/moon circle showing time of day at a glance
- ✅ Current weather conditions with temperature, wind speed, and weather icons
- ✅ Tap-to-toggle °C/°F temperature units
- ✅ Hourly forecast (rolling 12 hours, horizontal scroll)
- ✅ 7-day daily forecast
- ✅ Location-based weather using GPS
- ✅ City search with autocomplete (timezone-aware display)
- ✅ **Animated weather effects** — rain, snow, fog, and thunder particles
- ✅ **Animated gradient backgrounds** — MeshGradient that adapts to weather conditions
- ✅ **CoreMotion parallax** — subtle tilt effect across visual layers
- ✅ **Expandable detail cards** — UV index, humidity, pressure, visibility gauges
- ✅ Day/night-aware icons throughout the UI
- 🚧 Widgets (planned)
- 🚧 Live Activities (planned)

## Architecture

This project follows Clean Architecture principles with modular design:

- **WeatherKit** (SPM Module): Core domain logic, models, services, and repositories
  - Domain models (Weather, Location with timezone, Forecasts)
  - Weather service (Open-Meteo API integration)
  - Repository pattern for data access

- **WeatherUI** (SPM Module): SwiftUI views and view models
  - WeatherViewModel with @Observable macro
  - LocationManager for GPS access

- **WeatherApp** (Main Target): iOS application
  - `Views/` — Screen-level views (CurrentWeather, Search, Daily, state views)
  - `Components/` — CelestialClockView, FrostedCard, ExpandableDetailCard, Gauges
  - `Charts/` — Temperature curve, spline interpolation, scrubber
  - `Effects/` — Weather particles, animated gradients, motion/parallax

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
│       └── ViewModels/              # View models
├── WeatherApp/                      # Main app target
│   ├── WeatherApp.swift             # App entry point
│   ├── ContentView.swift            # Main view
│   ├── Views/                       # Screen-level views
│   ├── Components/                  # Reusable UI components
│   ├── Charts/                      # Data visualization
│   ├── Effects/                     # Visual effects
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
- Completely free, no API key required
- No rate limits for reasonable use
- Provides current weather, hourly, and daily forecasts
- Geocoding for location search with timezone data
- WMO weather codes for conditions

## Technical Highlights

- **Swift 6.0** with strict concurrency checking
- **SwiftUI** with @Observable macro (iOS 17+)
- **Async/await** for all network operations
- **Actor isolation** for thread-safe services
- **Canvas rendering** for custom celestial clock and weather particles
- **MeshGradient** for adaptive animated backgrounds
- **CoreMotion** parallax tilt effects
- **TimelineView** for real-time clock and particle updates
- **Protocol-oriented design** for testability
- **Clean Architecture** with clear separation of concerns
- **No external dependencies** — pure Swift and SwiftUI

## Future Enhancements

- [ ] Home Screen widgets
- [ ] Lock Screen widgets
- [ ] Live Activities for weather alerts
- [ ] Weather radar/maps
- [ ] Precipitation notifications
- [ ] iPad support
- [ ] Unit and UI tests

## License

MIT
