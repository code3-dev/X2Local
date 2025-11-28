# X2Local - X Downloader

A cross-platform X (Twitter) video and audio downloader built with Flutter and GetX.

## Features

- Download X (Twitter) videos and audio files
- Cross-platform support (Android, iOS, Web, Windows, macOS, Linux)
- Modern Material 3 design with glass UI effects
- Supports both MP4 video and MP3 audio downloads
- Progress tracking during downloads
- Clean and intuitive user interface

## Getting Started

### Prerequisites

- Flutter SDK 3.0 or higher
- Dart SDK 2.17 or higher
- Android Studio or VS Code with Flutter extensions

### Installation

1. Clone the repository:
   ```bash
   git clone <repository-url>
   ```

2. Navigate to the project directory:
   ```bash
   cd x2local
   ```

3. Install dependencies:
   ```bash
   flutter pub get
   ```

4. Run the app:
   ```bash
   flutter run
   ```

## Usage

1. Paste a valid X (Twitter) URL into the input field
2. Select the download type (MP4 video or MP3 audio)
3. Tap the Download button
4. Wait for the download to complete
5. Access your downloaded files in the device's download folder

## Architecture

This app follows the GetX pattern for Flutter:
- **Model**: Data models for API responses
- **Provider**: Handles API requests
- **Repository**: Manages data operations
- **Controller**: Business logic with GetX state management
- **View**: UI components
- **Binding**: Dependency injection

## Dependencies

- `get`: State management and navigation
- `http`: API requests
- `dio`: File downloading with progress tracking
- `permission_handler`: Handle storage permissions
- `path_provider`: Access device directories
- `file_picker`: File selection (future enhancement)

## Supported Platforms

- Android
- iOS
- Web
- Windows
- macOS
- Linux

## License

This project is licensed under the MIT License.