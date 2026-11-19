# Message Board Vault Hunt — Homework 02

## Overview
A Flutter message board application using Firebase Authentication and Cloud Firestore. Users can register, log in, complete their profiles, and create, view, edit, and delete messages.
The application uses Firestore streams for live updates and security rules to protect user data.

## Features
- Email/password registration and login
- User profile setup
- Create, read, update, and delete messages
- Live message updates using Firestore streams
- Edit and delete options for message owners
- Input validation, loading states, and error handling
- Firestore security rules

## Firebase Data Model

**Collection: `users`**

Each document uses the authenticated user's UID as its document ID.

`uid` - Firebase Authentication user ID

`firstName` - User's first name 

`lastName` - User's last name

`role` - User role (`user`)

`registrationDateTime` - Profile creation timestamp

Profiles are created during account setup and are accessible only to their owners.

**Collection: `messages`**

`text` - Message content

`authorUid` - UID of the message creator

`authorName` - Display name

`createdAt` - Creation timestamp

`editedAt` - Last edit timestamp, initially null

Authenticated users create messages through `BoardService`. The message owner can update or delete their own messages.

## CRUD Operations
- **Create:** Submit a message to Firestore.
- **Read:** Display messages using a real-time Firestore stream.
- **Update:** Edit an existing message and update its edit timestamp.
- **Delete:** Remove a message from Firestore.

## Security Rules
Firestore security rules enforce access independently of the app interface.

- Only authenticated users can read messages.
- Users can only create messages under their own UID.
- Only the original author can edit or delete a message.
- Users can only access their own profile documents.
- Protected fields such as message ownership cannot be changed through an update.

Rules are defined in `firestore.rules`.

## Running the App
1. Install Flutter and the project dependencies.
2. Run `flutter pub get`.
3. Configure Firebase for the project.
4. Run `flutter run` to launch the application.

The app uses Firebase Emulators in debug mode and the configured Firebase project in release mode.

## Testing
1. Register or log in with a test account.
2. Complete the user profile if prompted.
3. Create a message and verify it appears on the board.
4. Edit the message and confirm the updated content.
5. Delete the message and confirm it disappears.
6. Test invalid input, empty-board behavior, and duplicate submissions.
7. Verify that Firestore rules reject unauthorized operations.

## Extra Spices

### #1 — Firebase Emulator Explorer
Configured Firebase Authentication and Firestore Emulators for local testing.

The `emulator-data/` directory contains exported, reusable test data using disposable test accounts.

To start the emulators:
- `firebase emulators:start --import=./emulator-data`

### #2 — Automated Firestore Security Rules Tester
Created automated tests for signed-out access, unauthorized message updates, forged ownership, and authorized CRUD operations.

With the Firestore Emulator running: 
- `cd rules-tests` 
- `npm install`
- `node --test firestore.rules.test.js`

All four automated security rules tests passed.

### #4 — Idempotent Alchemist
Implemented duplicate-write protection using a stable message ID and a Firestore transaction.

A deliberate test called the message creation method twice with the same ID. Firestore contained exactly one message document.

## Release Build
Build the Android release APK using: 
- `flutter build apk --release`

Output: `build/app/outputs/flutter-apk/app-release.apk`

The release APK was tested successfully for login, message loading, creation, editing, and deletion.