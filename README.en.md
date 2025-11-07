# 📝 TodoList - Modern Todo Management App

<div align="center">

![Platform](https://img.shields.io/badge/Platform-iOS%2017%2B-blue)
![Swift](https://img.shields.io/badge/Swift-5.9-orange)
![SwiftUI](https://img.shields.io/badge/SwiftUI-Framework-green)
![License](https://img.shields.io/badge/License-MIT-yellow)

A powerful and elegant todo management app built with SwiftUI and SwiftData

English | [简体中文](./README.md)

</div>

---

## ✨ Core Features

### 🎯 Todo Management
- ✅ **Complete Task Management** - Create, edit, delete, and mark todos as complete
- 📋 **Subtask Support** - Break down large tasks into manageable subtasks
- 🏷️ **Priority System** - High/Medium/Low priorities with intelligent sorting
- 🔖 **Tag System** - Flexible tagging for quick filtering and organization
- ⏰ **Due Date Reminders** - Set due dates and reminder times to never miss important tasks
- 📊 **Progress Tracking** - Real-time display of task and subtask completion progress

### 📂 Category Management
- 🎨 **Custom Categories** - Customize icons, colors, and names
- 🔧 **System Presets** - Work, Life, Study, Health, Goals
- 📈 **Category Statistics** - Task counts and completion progress for each category
- 🔒 **Category Protection** - System categories cannot be deleted for data safety

### 🍅 Pomodoro Timer
- ⏱️ **Standard Pomodoro Technique** - 25 min work + 5 min short break + 15 min long break
- 🎛️ **Custom Duration** - Flexible adjustment of work and break durations
- 📊 **Pomodoro Statistics** - Track pomodoro counts for each task
- 🔔 **Focus Reminders** - Notifications when work or break sessions end
- 📝 **Task Association** - Link pomodoros to specific tasks for precise time tracking

### 📅 Calendar View
- 📆 **Monthly View** - Intuitive overview of daily todos
- 🗓️ **Date Selection** - Quick navigation to specific dates
- 📍 **Today Highlight** - Highlight current date and today's tasks
- 📊 **Date Markers** - Automatic marking of dates with tasks

### 📊 Data Statistics
- 📈 **Completion Trends** - Visualize task completion trends
- 🎯 **Efficiency Analysis** - Analyze work efficiency and time allocation
- 📊 **Category Distribution** - Task distribution across different categories
- 🔥 **Streak Tracking** - Record consecutive days of task completion

### 🧩 Widget Support
- 📱 **Widget Sizes** - Support for small, medium, and large home screen widgets
- ⚡ **Quick Add** - Quickly add new tasks via Widget
- 🔄 **Real-time Sync** - Widget data syncs with main app in real-time
- 👁️ **At a Glance** - View todos without opening the app

### 👤 User System
- 🔐 **Secure Authentication** - Email registration and login support
- 📱 **WeChat Login** - Integrated WeChat third-party login (extensible)
- 👤 **Personal Profile** - Avatar, nickname, and bio
- 🎨 **Theme Switching** - Support for light/dark themes

### 🎨 Modern Design
- 💎 **Native SwiftUI** - Built with the latest SwiftUI framework
- 🌓 **Dark Mode** - Perfect support for system dark mode
- ✨ **Smooth Animations** - Carefully designed transitions and interactions
- 📱 **Responsive Layout** - Adapts to all iPhone sizes

---

## 📸 Screenshots

> Note: Screenshot placeholders - replace with actual screenshots when available

```
┌─────────────┬─────────────┬─────────────┬─────────────┐
│  Todo List  │  Categories │  Pomodoro   │  Statistics │
│             │             │             │             │
│  [TODO]     │  [CATEGORY] │  [POMODORO] │ [STATISTICS]│
│             │             │             │             │
└─────────────┴─────────────┴─────────────┴─────────────┘
```

---

## 🛠️ Tech Stack

### Core Frameworks
- **SwiftUI** - Declarative UI framework
- **SwiftData** - Modern data persistence solution
- **Combine** - Reactive programming framework
- **WidgetKit** - Home screen widget framework

### Architecture Patterns
- **MVVM** - Model-View-ViewModel architecture
- **Repository Pattern** - Data access layer abstraction
- **Dependency Injection** - Dependency injection pattern

### Data Storage
- **SwiftData** - Primary data storage
- **App Group** - Data sharing between app and widgets
- **UserDefaults** - User preference settings
- **Keychain** - Encrypted storage for sensitive information

### System Capabilities
- **UserNotifications** - Local notifications
- **App Intents** - Widget interactions and Siri shortcuts
- **Share Extension** - Share extension (extensible)

---

## 📁 Project Structure

```
TodoList/
├── TodoList/                    # Main App
│   ├── App/                    # App Entry
│   │   ├── TodoListApp.swift  # Main app entry
│   │   ├── ContentView.swift  # Content view
│   │   └── MainTabView.swift  # Main tab view
│   │
│   ├── Models/                 # Data Models
│   │   ├── TodoItem.swift     # Todo item model
│   │   ├── Category.swift     # Category model
│   │   ├── User.swift         # User model
│   │   ├── Subtask.swift      # Subtask model
│   │   ├── PomodoroSession.swift  # Pomodoro session model
│   │   └── PomodoroSettings.swift # Pomodoro settings model
│   │
│   ├── Views/                  # View Layer
│   │   ├── Todo/              # Todo views
│   │   │   ├── TodoListView.swift
│   │   │   ├── TodoDetailView.swift
│   │   │   ├── AddTodoView.swift
│   │   │   └── Components/    # Sub-components
│   │   │
│   │   ├── Category/          # Category views
│   │   │   ├── CategoryListView.swift
│   │   │   └── CategoryEditView.swift
│   │   │
│   │   ├── Pomodoro/          # Pomodoro views
│   │   │   ├── PomodoroView.swift
│   │   │   ├── PomodoroTimerView.swift
│   │   │   └── Components/
│   │   │
│   │   ├── Calendar/          # Calendar views
│   │   │   ├── CalendarView.swift
│   │   │   └── Components/
│   │   │
│   │   ├── Statistics/        # Statistics views
│   │   │   ├── StatisticsView.swift
│   │   │   └── Components/
│   │   │
│   │   ├── Profile/           # Profile views
│   │   │   ├── ProfileView.swift
│   │   │   ├── SettingsView.swift
│   │   │   └── Components/
│   │   │
│   │   └── Auth/              # Authentication views
│   │       ├── LoginView.swift
│   │       ├── RegisterView.swift
│   │       └── Components/
│   │
│   ├── ViewModels/            # View Models
│   │   ├── TodoViewModel.swift
│   │   ├── CategoryViewModel.swift
│   │   ├── PomodoroViewModel.swift
│   │   ├── StatisticsViewModel.swift
│   │   ├── ProfileViewModel.swift
│   │   ├── AuthViewModel.swift
│   │   └── ThemeManager.swift
│   │
│   └── Utils/                 # Utilities
│       ├── Constants.swift    # Constants
│       ├── Validators.swift   # Validation utilities
│       └── Extensions/        # Extensions
│           ├── Date+Extension.swift
│           ├── Color+Extension.swift
│           ├── View+Extension.swift
│           └── String+Extension.swift
│
├── Widget/                    # Widget Extension
│   ├── TodoListWidget.swift  # Main widget
│   ├── QuickAddWidget.swift  # Quick add widget
│   ├── SmallWidgetView.swift # Small size view
│   ├── MediumWidgetView.swift # Medium size view
│   ├── LargeWidgetView.swift # Large size view
│   ├── WidgetDataProvider.swift # Data provider
│   ├── AddTodoIntent.swift   # Add todo intent
│   └── WidgetBundle.swift    # Widget bundle
│
├── docs/                      # Documentation
│   └── (documentation files)
│
└── README.md                  # This file
```

---

## 🚀 Getting Started

### Requirements

- **macOS**: Sonoma (14.0) or later
- **Xcode**: 15.0 or later
- **iOS**: 17.0 or later
- **Swift**: 5.9 or later

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/yipoo/todolist.git
cd TodoList
```

2. **Open the project**
```bash
open TodoList.xcodeproj
```

3. **Configure App Group**
   - Select the `TodoList` target
   - Go to `Signing & Capabilities`
   - Confirm App Group is set to: `group.com.yipoo.todolist`
   - Repeat for `WidgetExtension` target

4. **Configure developer account**
   - Sign in with your Apple ID in Xcode
   - Select the correct Team
   - Ensure Bundle Identifier is unique

5. **Run the app**
   - Select a simulator or device
   - Press `Cmd + R` to run

---

## 📱 Widget Configuration

### Adding Widgets to Home Screen

1. Long press on the home screen
2. Tap the `+` button in the top left
3. Search for "TodoList"
4. Select widget size:
   - **Small**: Shows today's todo count and quick view
   - **Medium**: Shows up to 4 todo items
   - **Large**: Shows up to 8 todo items
5. Tap "Add Widget"

### Widget Features

- ✅ **Real-time Data**: Widgets automatically fetch latest data from App Group
- 🔄 **Auto Refresh**: Automatically updates based on Timeline policy
- 👆 **Tap Interaction**: Tap widget to open corresponding todo details
- ⚡ **Quick Add**: Use quick add widget to create new tasks instantly

### App Group Explanation

This app uses App Group to share data between main app and widgets:
- **Group ID**: `group.com.yipoo.todolist`
- **Purpose**: SwiftData database sharing, UserDefaults sharing

---

## 🔧 Build and Deploy

### Debug Build

```bash
xcodebuild -project TodoList.xcodeproj \
  -scheme TodoList \
  -configuration Debug \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
  build
```

### Release Build

```bash
xcodebuild -project TodoList.xcodeproj \
  -scheme TodoList \
  -configuration Release \
  -destination generic/platform=iOS \
  archive
```

### Export IPA

1. In Xcode, select `Product > Archive`
2. Select the Archive and click `Distribute App`
3. Choose distribution method (App Store, Ad Hoc, Enterprise, Development)
4. Follow the wizard to complete export

---

## 📚 Development Guide

### Adding New Features

1. **Create Model** - Add data model in `Models/` directory
2. **Create ViewModel** - Add business logic in `ViewModels/` directory
3. **Create View** - Add view in corresponding `Views/` subdirectory
4. **Register Route** - Add navigation in `MainTabView.swift`

### Database Operations

Use SwiftData for data operations:

```swift
// Query
@Query(sort: \TodoItem.createdAt, order: .reverse)
var todos: [TodoItem]

// Insert
context.insert(todo)

// Update
todo.title = "New Title"
todo.updatedAt = Date()

// Delete
context.delete(todo)

// Save
try? context.save()
```

### Adding Widgets

1. Create new Widget file in `Widget/` directory
2. Implement `Widget` protocol
3. Register in `WidgetBundle.swift`
4. Configure Timeline Provider
5. Design Widget view

---

## 🤝 Contributing

Contributions, bug reports, and feature suggestions are welcome!

### Contribution Process

1. Fork the repository
2. Create feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Code Standards

- Follow Swift API Design Guidelines
- Use meaningful variable and function names
- Add necessary comments and documentation
- Keep code clean and readable
- Write unit tests (when applicable)

### Commit Convention

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation update
- `style`: Code formatting
- `refactor`: Code refactoring
- `test`: Test related
- `chore`: Build/tool related

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details

---

## 👨‍💻 Author

**Your Name**

- Website: [https://example.com](https://example.com)
- Email: support@example.com
- GitHub: [@yipoo](https://github.com/yipoo)

---

## 🙏 Acknowledgments

- Thanks to Apple for excellent development tools and frameworks
- Thanks to the SwiftUI and SwiftData community for support
- Thanks to all contributors and users

---

## 📮 Contact

For questions or suggestions, feel free to reach out:

- 📧 Email: support@example.com
- 🐛 Issues: [GitHub Issues](https://github.com/yipoo/TodoList/issues)
- 💬 Discussions: [GitHub Discussions](https://github.com/yipoo/TodoList/discussions)

---

<div align="center">

**⭐ If this project helps you, please give it a star! ⭐**

Made with ❤️ using SwiftUI

</div>
