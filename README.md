# Docker AI Manager - Android Application

A modern Android application for managing Docker containers remotely using AI-powered log analysis with Google Gemini API.

## 🎯 Features

- **Docker Container Monitoring**: Real-time display of all running and stopped containers
- **Container Control**: Start, Stop, Restart containers with a single tap
- **AI Log Analysis**: Intelligent analysis of container logs using Google Gemini API
  - Root cause identification
  - Troubleshooting suggestions
  - Responses in Thai language for better understanding
- **Clean Architecture**: MVVM + Manual Dependency Injection pattern
- **Modern UI**: Jetpack Compose with Material Design 3
- **Async-First**: Kotlin Coroutines and Flow for reactive programming

## 📋 Tech Stack

- **Language**: Kotlin
- **UI Framework**: Jetpack Compose (Material Design 3)
- **Networking**: Ktor Client
- **JSON Serialization**: Kotlinx Serialization
- **Async**: Kotlin Coroutines & Flow
- **Architecture**: MVVM + Manual DI (AppContainer Pattern)
- **Minimum API Level**: 26 (Android 8.0)
- **Target API Level**: 34 (Android 14)

## 🏗️ Project Structure

```
DockerAIApp/
├── app/
│   ├── src/main/
│   │   ├── kotlin/com/dockerai/
│   │   │   ├── di/
│   │   │   │   ├── AppContainer.kt         # DI Container with lazy initialization
│   │   │   │   └── ContainerProvider.kt    # Global container access
│   │   │   ├── data/
│   │   │   │   ├── remote/
│   │   │   │   │   ├── DockerDataSource.kt # Docker API client
│   │   │   │   │   └── GeminiDataSource.kt # Gemini AI client
│   │   │   │   └── repository/
│   │   │   │       ├── DockerRepository.kt # Docker operations
│   │   │   │       └── AIAgentRepository.kt# AI analysis operations
│   │   │   ├── domain/
│   │   │   │   └── model/
│   │   │   │       └── ContainerInfo.kt    # Data models
│   │   │   ├── ui/
│   │   │   │   ├── dashboard/
│   │   │   │   │   ├── DashboardScreen.kt # UI Components
│   │   │   │   │   └── DashboardViewModel.kt # UI State Management
│   │   │   │   └── theme/
│   │   │   │       └── Theme.kt            # Material Design 3 Theme
│   │   │   ├── MainActivity.kt             # Entry point
│   │   │   └── DockerAiApplication.kt      # App initialization
│   │   ├── res/
│   │   │   ├── values/strings.xml          # Localized strings
│   │   │   └── ...
│   │   └── AndroidManifest.xml             # App configuration
│   ├── build.gradle                        # App-level dependencies
│   └── proguard-rules.pro                  # Code obfuscation rules
├── build.gradle                            # Project-level configuration
└── settings.gradle                         # Gradle settings
```

## 🚀 Getting Started

### Prerequisites

1. **Android Studio** (Arctic Fox or later)
2. **JDK 11** or higher
3. **Android SDK 26** or higher
4. **Docker Daemon** with TCP port 2375 exposed (optional, for local testing)
5. **Google Gemini API Key** (get from https://ai.google.dev/)

### Step 1: Clone & Open Project

```bash
# Clone the repository
git clone <repository-url>
cd DockerAIApp

# Open in Android Studio
```

### Step 2: Configure API Keys

1. Open `app/build.gradle`
2. Replace `YOUR_GEMINI_API_KEY_HERE` with your actual Gemini API key:
   ```gradle
   buildConfigField 'String', 'GEMINI_API_KEY', '"your-actual-api-key-here"'
   ```

**Security Note**: In production, store API keys in `local.properties` or Android Keystore:

```bash
# local.properties
GEMINI_API_KEY=your-actual-api-key-here
```

### Step 3: Build & Run

```bash
# Build APK (Debug)
./gradlew assembleDebug

# Install on device
./gradlew installDebug

# Run directly
./gradlew runDebug
```

## 🐳 Docker Setup (For Remote Management)

### Securing Docker Daemon Access

Docker must be accessible over TCP. **Important**: Never expose Docker daemon publicly without proper security.

#### Option 1: VPN/Tailscale (Recommended)

```bash
# Install Tailscale on Docker host
curl -fsSL https://tailscale.com/install.sh | sh

# Configure Docker to listen on Tailscale IP
sudo nano /etc/docker/daemon.json
```

```json
{
  "hosts": [
    "unix:///var/run/docker.sock",
    "tcp://100.x.x.x:2375"  // Replace with your Tailscale IP
  ]
}
```

#### Option 2: TLS Certificates (Advanced)

Generate certificates for mutual TLS authentication between app and Docker daemon:

```bash
# Generate CA certificate
openssl genrsa -out ca-key.pem 2048
openssl req -x509 -new -nodes -key ca-key.pem -days 10000 -out ca.pem

# Generate server certificate
openssl genrsa -out server-key.pem 2048
openssl req -new -key server-key.pem -out server.csr
openssl x509 -req -in server.csr -CA ca.pem -CAkey ca-key.pem \
  -CAcreateserial -out server-cert.pem -days 365

# Configure Docker daemon
{
  "tlsverify": true,
  "tlscacert": "/path/to/ca.pem",
  "tlscert": "/path/to/server-cert.pem",
  "tlskey": "/path/to/server-key.pem",
  "hosts": ["tcp://0.0.0.0:2376"]
}
```

### Connect from App

1. Open app settings
2. Enter Docker Host: `http://192.168.1.100:2375` (or your remote IP)
3. For secured connection: `https://docker-host:2376`

## 📱 Building & Deploying APK

### Debug Build

```bash
# Create debug APK
./gradlew assembleDebug

# Output: app/build/outputs/apk/debug/app-debug.apk
```

### Release Build

```bash
# Create release APK (requires signing configuration)
./gradlew assembleRelease

# Output: app/build/outputs/apk/release/app-release.apk
```

### Signing Configuration

Create `keystore.jks`:

```bash
keytool -genkey -v -keystore keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias dockerai
```

Update `app/build.gradle`:

```gradle
android {
    signingConfigs {
        release {
            storeFile file("../keystore.jks")
            storePassword System.getenv("KEYSTORE_PASSWORD") ?: "your-password"
            keyAlias System.getenv("KEY_ALIAS") ?: "dockerai"
            keyPassword System.getenv("KEY_PASSWORD") ?: "your-password"
        }
    }
    
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

### Install APK on Device

```bash
# Via ADB
adb install app/build/outputs/apk/release/app-release.apk

# Or via Android Studio: Run > Select Device
```

## 🔑 Android Permissions

Required permissions (defined in `AndroidManifest.xml`):

```xml
<!-- Network access for Docker and Gemini APIs -->
<uses-permission android:name="android.permission.INTERNET" />

<!-- Network state detection (optional but recommended) -->
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

## 🏗️ Architecture Details

### Dependency Injection Pattern

Manual DI using `AppContainer` for thread-safe dependency management:

```kotlin
// Get container from application
val container = ContainerProvider.get()

// Create repositories
val dockerRepo = container.createDockerRepository()
val aiRepo = container.createAIAgentRepository()

// Use in ViewModel
val viewModel = DashboardViewModel(dockerRepo, aiRepo)
```

### Data Flow

```
UI Layer (Compose)
    ↓
ViewModel (StateFlow)
    ↓
Repository Layer (Flow/Result)
    ↓
Data Source (API Clients)
    ↓
Docker API / Gemini API
```

### Error Handling

All operations return `Result<T>` for safe error propagation:

```kotlin
val result = dockerRepository.startContainer(containerId)
if (result.isSuccess) {
    val value = result.getOrNull()
} else {
    val error = result.exceptionOrNull()
}
```

## 🧪 Testing

Run unit tests:

```bash
./gradlew test
```

Run instrumentation tests:

```bash
./gradlew connectedAndroidTest
```

## 📊 API Integration

### Docker API Endpoints Used

```
GET    /v1.40/containers/json?all=1          # List all containers
GET    /v1.40/containers/{id}/json           # Inspect container
POST   /v1.40/containers/{id}/start          # Start container
POST   /v1.40/containers/{id}/stop           # Stop container
POST   /v1.40/containers/{id}/restart        # Restart container
GET    /v1.40/containers/{id}/logs           # Get logs
```

### Gemini API Integration

```
POST https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent

Request Body:
{
  "contents": [{
    "parts": [{
      "text": "[Thai-language prompt about container logs]"
    }]
  }]
}
```

## 🐛 Troubleshooting

### Cannot Connect to Docker

- Verify Docker daemon is running: `docker ps`
- Check if port 2375 is open: `telnet localhost 2375`
- On Android, verify VPN/network connectivity

### API Key Issues

- Ensure `GEMINI_API_KEY` is correctly set in `build.gradle`
- Verify key has required permissions from Google AI Studio
- Check if API quota is exceeded

### Compose Crashes

- Ensure `minSdk 26` in `build.gradle`
- Update Compose Compiler to match Kotlin version
- Clear build cache: `./gradlew clean`

## 📚 References

- [Docker Engine API Documentation](https://docs.docker.com/engine/api/)
- [Google Gemini API Documentation](https://ai.google.dev/docs)
- [Android Developer Documentation](https://developer.android.com/)
- [Jetpack Compose Documentation](https://developer.android.com/jetpack/compose)
- [Kotlin Coroutines Documentation](https://kotlinlang.org/docs/coroutines-overview.html)

## 📄 License

This project is provided as-is for educational and development purposes.

## 🤝 Contributing

Contributions are welcome! Please follow these guidelines:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📞 Support

For issues, questions, or suggestions, please:

1. Check existing GitHub issues
2. Create a new issue with detailed information
3. Include logs, device info, and reproduction steps

---

**Made with ❤️ for Docker and AI enthusiasts**
