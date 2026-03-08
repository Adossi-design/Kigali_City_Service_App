# Kigali City Services Directory

A Flutter mobile application that helps users discover, explore, and review local services and places in Kigali, Rwanda. It's built with Flutter and Firebase.

---

## Features

- **User Authentication** — Sign up and log in with email and password. Email verification is required before accessing the app.
- **Directory** — Browse all listings with real-time search and category filtering (Café, Hospital, Park, Restaurant, Police Station, Library, Tourist Attraction).
- **Listing Detail** — View full information about a place including address, contact, description, and an embedded Google Map.
- **Navigation** — Launch Google Maps directions directly from any listing.
- **My Listings** — Create, edit, and delete your own listings.
- **Reviews & Ratings** — Rate any service with 1–5 stars and leave a comment. Reviews are displayed on both the listing detail page and the global Reviews tab.
- **Map View** — See all listings as markers on a full-screen Google Map.
- **Settings** — Manage your profile and notification preferences.

---

## Firestore Database Structure
```
users/
  {uid}/
    name: string
    email: string
    emailVerified: boolean
    createdAt: timestamp

listings/
  {listingId}/
    name: string
    category: string
    address: string
    contact: string
    description: string
    latitude: number
    longitude: number
    createdBy: string (uid)
    createdAt: timestamp

reviews/
  {reviewId}/
    listingId: string
    userId: string
    userName: string
    comment: string
    rating: number
    createdAt: timestamp
```

---

## State Management

This app uses **Riverpod** for state management.

- `authStateProvider` — Streams Firebase Auth state changes to drive login/logout routing.
- `allListingsProvider` — Streams all listings from Firestore in real time.
- `myListingsProvider` — Streams only the current user's listings.
- `filteredListingsProvider` — Derives filtered listings from search query and selected category state.
- `searchQueryProvider` — Holds the current search string.
- `selectedCategoryProvider` — Holds the currently selected category chip.

---

## Tech Stack

| Layer             | Technology |
|-------------------|---------------------------|
| Framework         | Flutter (Dart)            |
| Backend           | Firebase                  |
| State Management  | Riverpod                  |
| Maps              | Google Maps Flutter       |
| Fonts             | Google Fonts              |

---

## Setup Instructions

1. Clone the repository
2. Run `flutter pub get`
3. Add your `google-services.json` to `android/app/`
4. Add your Google Maps API key to `android/app/src/main/AndroidManifest.xml`
5. Run `flutter run`