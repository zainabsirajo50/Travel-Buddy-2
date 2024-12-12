# Travel Buddy App

## Overview

The **Travel Buddy App** is a Flutter-based mobile application designed to help users plan and manage their trips seamlessly. The app allows users to explore featured destinations, create and customize itineraries, and match with travel buddies who share similar interests. It also integrates Firebase for real-time data synchronization and currency conversion functionality to help users manage budgets while traveling.

---

## Submission Links

- **Canva Presentation Link:** 
- **YouTube Presentation Link:** 

---

## Features

1. **User Authentication**:
   - Secure login and signup using Firebase Authentication.

2. **Homepage**:
   - Displays featured destinations and recent itineraries.
   - Includes a *Plan New Trip* button that navigates users to the itinerary creation screen.

3. **Itinerary Management**:
   - Users can create, view, edit, and delete itineraries.
   - Displays itineraries tailored to user preferences and activities stored in Firebase Firestore.

4. **Currency Conversion**:
   - Supports USD, EUR, and GBP.
   - Uses the CurrencyLayer API to convert itinerary budgets based on the user's selected currency.

5. **Explore Nearby**:
   - Dedicated button for exploring nearby attractions or events (navigates to an `/explore` route).

6. **Travel Buddy Matching**:
   - Matches users with travel buddies based on their itineraries and preferences (future feature).

7. **Responsive Design**:
   - Scrollable and user-friendly interface to ensure seamless navigation.

---

## How to Run the App

Follow these steps to run the Travel Buddy App on your local machine:

1. Clone the repository  
  `git clone https://github.com/zainabsirajo50/Travel-Buddy-2.git`

2. Navigate to the project directory  
   `cd Travel-Buddy-2`
4. Install Dependencies  
   `flutter pub get`
5. Run the App  
  `flutter run`
