# Task Manager App

A Flutter task management app built with Firebase Firestore for real-time cloud persistence. This app allows users to create tasks, mark them complete, delete them, and manage nested subtasks. All changes are synced live with Firestore, so the task list updates instantly without requiring a manual refresh.

## Features

### Core Features
- Add new tasks
- View all tasks in a live-updating task list
- Mark tasks as completed or incomplete
- Delete tasks
- Add nested subtasks under each main task
- Mark subtasks as completed or incomplete
- Delete subtasks
- Real-time synchronization with Firebase Firestore

### UX and Validation
- Blocks empty task submission
- Blocks empty subtask submission
- Shows a loading spinner while Firestore data is loading
- Shows an empty-state message when no tasks exist
- Shows an error message if the Firestore stream fails
- Uses delete confirmation dialogs before removing tasks

## Enhanced Features

### 1. Search / Filter
I added a search bar that filters tasks by title in real time. This makes the app easier to use when the task list gets longer because users can quickly find the specific task they want instead of scrolling through the full list.

### 2. Dark Mode Support
I implemented `ThemeMode.system` so the app follows the device’s light or dark theme automatically. I chose this because it improves the overall user experience without adding extra complexity to the interface.

### 3. Swipe-to-Delete
I also added swipe-to-delete for task items as an extra polish feature. This gives users a faster way to remove tasks while still keeping a confirmation step to reduce accidental deletion.

## Technologies Used
- Flutter
- Dart
- Firebase Core
- Cloud Firestore
- StatefulWidget
- StreamBuilder

## Project Structure
```text
lib/
├── main.dart
├── firebase_options.dart
├── models/
│   └── task.dart
├── services/
│   └── task_service.dart
└── screens/
    └── task_list_screen.dart