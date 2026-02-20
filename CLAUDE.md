# WeatherApp - Project Context

## Project Overview

A production-grade iOS weather application built with Swift 6.0, targeting iOS 18+ with cutting-edge widget features.

## Technical Stack

- **Language**: Swift 6.0
- **Minimum iOS**: 18.0
- **Architecture**: Clean Architecture (Domain, UI, Data layers)
- **UI Framework**: SwiftUI
- **Concurrency**: Swift Concurrency (async/await, actors)
- **Widgets**: WidgetKit with Live Activities support

## Code Standards

### Swift Style
- Use strict concurrency checking
- Prefer value types over reference types
- Use @MainActor for UI-bound types
- Follow Swift API Design Guidelines
- Use explicit `self` only when required
- Prefer `guard` for early returns
- Use trailing closures appropriately

### Architecture Principles
- **Separation of Concerns**: Domain logic isolated from UI
- **Dependency Injection**: Constructor injection preferred
- **Protocol-Oriented**: Define protocols for abstraction boundaries
- **Testability**: All business logic must be testable
- **SOLID Principles**: Applied throughout

### File Organization
```
Sources/
  WeatherKit/           # Core domain
    Models/
    Services/
    Repositories/
  WeatherUI/            # UI layer
    Views/
    ViewModels/
    Components/
WeatherApp/
  Views/                # Screen-level views (CurrentWeather, Search, Daily, State)
  Components/           # Reusable UI (SunArc, FrostedCard, ExpandableDetail, Gauges)
  Charts/               # Temperature curve, spline interpolation, scrubber
  Effects/              # Particles, animated gradients, motion/parallax
```

### Naming Conventions
- Types: PascalCase
- Functions/Variables: camelCase
- Protocols: Descriptive nouns or -able suffix
- View Models: suffix with `ViewModel`
- Services: suffix with `Service`

### Testing Strategy
- Unit tests for business logic
- Snapshot tests for UI components
- Integration tests for API layer
- Aim for >80% code coverage on domain layer

## Widget Strategy

### Planned Widget Types
1. **Home Screen Widgets**
   - Small: Current temperature + icon
   - Medium: Current + hourly forecast
   - Large: Full day forecast + details

2. **Lock Screen Widgets**
   - Circular: Current temp
   - Rectangular: Temp + conditions
   - Inline: Brief forecast

3. **Live Activities**
   - Severe weather alerts
   - Temperature changes
   - Precipitation tracking

### Widget Technical Requirements
- Use AppIntents for interactive widgets
- Implement timeline provider efficiently
- Cache data for widget performance
- Share data via App Groups

## API Requirements

### Criteria for Weather API
- Free tier available
- No credit card required
- Reasonable rate limits
- JSON response format
- Supports:
  - Current weather
  - Hourly forecast
  - Daily forecast
  - Location search
  - Weather icons/conditions

## Performance Guidelines

- Keep widget timelines lean (max 100 entries)
- Use background URLSession for updates
- Implement proper caching strategy
- Optimize image loading and rendering
- Profile regularly with Instruments

## Security & Privacy

- Request location permission appropriately
- Store API keys securely (not in source)
- Use HTTPS for all network calls
- Follow App Privacy Details guidelines
- Implement proper error handling

## Git Workflow

- Main branch: production-ready code
- Feature branches: `feature/description`
- Commit messages: conventional commits format
- PR required for main branch changes

## Next Steps

1. ✅ Initialize project structure
2. ✅ Select weather API (Open-Meteo - free, no API key)
3. ✅ Design app architecture
4. ✅ Implement core networking layer
5. ✅ Build UI components (redesigned with full-screen display)
6. ✅ UI improvements (°C/°F toggle, rolling 12h forecast, cleaner time display)
7. ✅ Visual overhaul (particles, animated gradients, spline chart, sun arc, expandable cards, parallax)
8. ✅ Celestial clock (24-hour sun/moon circle, timezone-aware for searched cities, simple hourly scroll list)
9. ⏳ Create widget extensions
10. ⏳ Testing & polish

## Notes

- Using Swift Package Manager for modular architecture
- Targeting latest iOS for cutting-edge features
- Widget-first approach to UX design
