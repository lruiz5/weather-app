# WeatherApp - Development Game Plan

## Phase 1: API Selection & Architecture (Current Phase)

### API Evaluation Criteria
We need a free weather API with:
- ✅ No credit card requirement
- ✅ Reasonable rate limits (500+ req/day)
- ✅ Current weather + forecasts
- ✅ Hourly & daily data
- ✅ JSON responses
- ✅ Location search/geocoding

### Top Candidates from Free APIs:
1. **Open-Meteo** (Recommended)
   - Completely free, no API key required
   - Excellent rate limits
   - Hourly + daily forecasts (16 days)
   - WMO weather codes
   - Wind, precipitation, pressure, etc.
   - Reverse geocoding built-in

2. **OpenWeatherMap** (Free tier)
   - 1000 calls/day free
   - Current + 5-day forecast
   - Requires API key
   - Well documented

3. **WeatherAPI.com** (Free tier)
   - 1M calls/month free
   - Real-time + forecast
   - Requires API key
   - Good documentation

**Decision Point**: Need to select API before proceeding with implementation.

## Phase 2: Core Architecture Setup

### 2.1 Domain Layer (WeatherKit)
- [ ] Define core weather models
  - `Weather`: Current conditions
  - `Forecast`: Multi-day forecast
  - `HourlyForecast`: Hourly data
  - `Location`: User location data
  - `WeatherCondition`: Enum for conditions

- [ ] Create service protocols
  - `WeatherServiceProtocol`: API abstraction
  - `LocationServiceProtocol`: Location handling
  - `CacheServiceProtocol`: Data persistence

- [ ] Implement repository pattern
  - `WeatherRepository`: Coordinates services
  - Handles caching strategy
  - Error handling & retry logic

### 2.2 Network Layer
- [ ] Build API client
  - Generic `APIClient` with async/await
  - Request/Response models
  - Error handling
  - Rate limiting

- [ ] Implement weather service
  - Concrete implementation of `WeatherServiceProtocol`
  - API endpoint configuration
  - Response parsing
  - Unit tests

### 2.3 Data Persistence
- [ ] Cache implementation
  - UserDefaults for simple data
  - FileManager for forecasts
  - App Group for widget sharing

- [ ] Offline support
  - Cache invalidation strategy
  - Stale data indicators
  - Background refresh

## Phase 3: UI Development

### 3.1 Design System
- [ ] Color palette
  - Dynamic colors for light/dark mode
  - Weather condition theming
  - Accessibility compliance

- [ ] Typography scale
  - SF Pro/SF Rounded
  - Hierarchy definition

- [ ] Component library
  - `WeatherCard`
  - `TemperatureView`
  - `ForecastRow`
  - `ConditionIcon`
  - `LoadingState`
  - `ErrorView`

### 3.2 Main App Views
- [ ] Home View
  - Current weather hero section
  - Hourly forecast scroll
  - Daily forecast list
  - Pull-to-refresh

- [ ] Location Management
  - Search locations
  - Save favorites
  - Current location

- [ ] Settings View
  - Units (°F/°C, mph/km/h)
  - Notifications
  - Widget preferences
  - About section

### 3.3 ViewModels
- [ ] `WeatherViewModel`
  - Fetches & transforms data
  - Handles loading states
  - Error management

- [ ] `LocationViewModel`
  - Location search
  - Favorites management

- [ ] Use `@Observable` macro (iOS 17+)

## Phase 4: Widget Development

### 4.1 Widget Architecture
- [ ] Shared data layer
  - App Groups setup
  - Shared UserDefaults suite
  - Widget timeline optimization

- [ ] Widget configurations
  - ConfigurationIntent for user customization
  - Multiple size support

### 4.2 Home Screen Widgets
- [ ] Small Widget
  - Current temperature
  - Weather icon
  - Location name

- [ ] Medium Widget
  - Current + high/low
  - 3-hour forecast
  - Weather icon

- [ ] Large Widget
  - Current conditions
  - 8-hour forecast
  - Daily summary

- [ ] Interactive elements (iOS 17+)
  - Tap to open specific view
  - Widget buttons for actions

### 4.3 Lock Screen Widgets
- [ ] Circular widget
  - Temperature only

- [ ] Rectangular widget
  - Temp + condition icon

- [ ] Inline widget
  - Text-only forecast

### 4.4 Live Activities
- [ ] Weather alerts activity
  - Severe weather warnings
  - Real-time updates

- [ ] Precipitation tracking
  - Rain start/end times
  - Intensity changes

### 4.5 StandBy Mode (iOS 17+)
- [ ] Full-screen weather display
  - Large, glanceable design
  - Auto-updating
  - Night mode friendly

## Phase 5: Advanced Features

### 5.1 Location Services
- [ ] CoreLocation integration
  - Request permissions properly
  - Background updates
  - Geocoding/reverse geocoding

- [ ] Multi-location support
  - Save favorite locations
  - Quick switching
  - Separate widgets per location

### 5.2 Notifications
- [ ] Weather alerts
  - Severe weather push notifications
  - User-configurable thresholds

- [ ] Daily forecast
  - Morning briefing
  - Evening update

### 5.3 Premium Features (Optional)
- [ ] Radar/maps integration
  - If API supports
  - MapKit overlay

- [ ] Weather history
  - Past conditions
  - Trends & charts

- [ ] Air quality index
  - If API provides data

### 5.4 Accessibility
- [ ] VoiceOver optimization
  - Descriptive labels
  - Weather announcements

- [ ] Dynamic Type support
  - Scale text properly

- [ ] Reduced motion
  - Respect accessibility settings

- [ ] High contrast mode

### 5.5 Siri & Shortcuts
- [ ] App Intents
  - "Get current weather"
  - "Show forecast for [location]"

- [ ] Siri suggestions
  - Predictive shortcuts

## Phase 6: Polish & Optimization

### 6.1 Performance
- [ ] Profile with Instruments
  - Network usage
  - Memory footprint
  - Battery impact

- [ ] Optimize widget updates
  - Smart timeline generation
  - Minimize background fetches

- [ ] Image caching
  - Weather icons
  - Background imagery

### 6.2 Testing
- [ ] Unit tests
  - >80% coverage on domain layer
  - Mock services

- [ ] UI tests
  - Critical user flows
  - Widget rendering

- [ ] Manual testing
  - Device testing (different screen sizes)
  - iOS versions
  - Network conditions

### 6.3 App Store Preparation
- [ ] App icons (all sizes)
- [ ] Screenshots (all device sizes)
- [ ] App Store description
- [ ] Privacy policy
- [ ] App review preparation

## Phase 7: Launch & Iteration

### 7.1 TestFlight
- [ ] Internal testing
- [ ] External beta
- [ ] Feedback incorporation

### 7.2 App Store Submission
- [ ] Metadata finalization
- [ ] Submit for review
- [ ] Monitor status

### 7.3 Post-Launch
- [ ] Analytics integration
- [ ] Crash reporting
- [ ] User feedback monitoring
- [ ] Iterative improvements

---

## Current Status: Phase 3 (UI Development)

### Completed:
✅ Project structure initialized
✅ Swift Package Manager setup
✅ Clean architecture scaffolding
✅ CLAUDE.md project context
✅ Development plan created
✅ Weather API selected (Open-Meteo - free, no API key)
✅ Xcode project created
✅ Core domain models implemented (Weather, Forecast, Location)
✅ Networking layer built (Open-Meteo API integration)
✅ WeatherService with async/await
✅ WeatherViewModel with @Observable
✅ Main UI redesigned (full-screen display, modern SwiftUI)
✅ Location name resolution fixed (reverse geocoding)
✅ Hourly and daily forecast views
✅ City search functionality
✅ Tap-to-toggle °C/°F temperature units
✅ Rolling 12-hour hourly forecast (was fixed at 24h ending at 11 PM)
✅ Simplified hourly time display (hour only, no :00)
✅ Transparent background on main location card

### Next Immediate Steps:
1. Create widget extensions (Home Screen, Lock Screen)
2. Implement Live Activities for weather alerts
3. Add unit tests for domain layer
4. Polish UI animations and transitions
5. iPad support

### Decisions Made:
- [x] Weather API: Open-Meteo (free, no key required)
- [x] Target iOS 18+ only
- [ ] Include iPad support from start?
- [ ] Preferred color scheme/design direction?
- [ ] Any specific widget features priority?

---

## Technical Decisions Log

| Decision | Rationale | Date |
|----------|-----------|------|
| Swift 6.0 | Strict concurrency, modern features | 2024-02-13 |
| iOS 18+ min | Access to latest widget APIs, Live Activities | 2024-02-13 |
| Clean Architecture | Testability, maintainability, separation of concerns | 2024-02-13 |
| SwiftUI | Modern declarative UI, widget support | 2024-02-13 |
| SPM | Native dependency management, modular architecture | 2024-02-13 |
| Open-Meteo API | Free, no API key, excellent rate limits, full feature set | 2026-02-18 |
| Full-screen UI redesign | Modern immersive weather display | 2026-02-18 |
| °C/°F toggle via tap | Simple UX, no settings screen needed | 2026-02-19 |
| Rolling 12h hourly forecast | More relevant than fixed midnight-to-11PM | 2026-02-19 |
