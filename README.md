<div align="center">

<img src="https://capsule-render.vercel.app/api?type=waving&color=0E7490&height=180&section=header&text=TodoList&fontSize=58&fontColor=FFFFFF&animation=fadeIn" alt="TodoList banner" width="100%" />

### Plan less. Accomplish more.

<p>A simple and focused Flutter app for organizing daily tasks and building productive habits.</p>

<img src="https://img.shields.io/badge/Flutter-3.x-0E7490?logo=flutter&logoColor=white" alt="Flutter" />
<img src="https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white" alt="Dart" />
<img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS-111827" alt="Platforms" />

</div>

<br />

<div align="center">
	<img src="https://media.giphy.com/media/qgQUggAC3Pfv687qPC/giphy.gif" alt="Developer working on an app" width="360" />
</div>

## About

TodoList helps users keep their everyday plans in one place. Create tasks, edit them when plans change, mark them as completed, and track your progress throughout the day.

## Features

- Add, edit, and delete tasks
- Mark tasks as completed
- Separate active and completed tasks
- Track daily progress
- Local data storage
- Russian and English interface
- Light and dark themes
- Onboarding for new users

## Built With

- [Flutter](https://flutter.dev/)
- [Dart](https://dart.dev/)
- [Flutter Bloc](https://pub.dev/packages/flutter_bloc)
- [Shared Preferences](https://pub.dev/packages/shared_preferences)

## Getting Started

### Prerequisites

- Flutter SDK
- Dart SDK
- Android Studio or Xcode for mobile development

### Installation

```bash
git clone https://github.com/your-username/todo_list.git
cd todo_list
flutter pub get
flutter run
```

## Project Structure

```text
lib/
├── database/          # Local task storage
├── home/              # Main application screens
│   ├── add/           # Create and edit tasks
│   ├── details/       # Task details
│   ├── onboard/       # Onboarding flow
│   └── settings/      # App settings and theme control
├── app.dart           # App configuration and themes
└── main.dart          # Application entry point
```

## License

This project is for learning and personal use.
