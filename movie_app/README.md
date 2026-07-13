# Movie App Flutter

A comprehensive Flutter application designed for browsing movies, viewing cinema schedules, managing user profiles, and simulating movie ticket bookings. This project demonstrates clean architecture, centralized navigation, and integration with modern Flutter packages to deliver a seamless user experience.

## Comprehensive Features

This application incorporates various essential features, mapped directly from the codebase:

*   **Onboarding Experience:** A welcoming first-time user flow managed via `shared_preferences` to ensure it only shows once.
*   **Robust Authentication:** Secure user authentication leveraging `firebase_core`, `firebase_auth`, and `google_sign_in` for a seamless login and registration process.
*   **Profile Management:** Users can view and edit their profiles, including updating their avatar using the `image_picker` package.
*   **Movie Discovery & Search:**
    *   Browse "Now Playing" and "Upcoming" movies via an integrated API (`http` package), likely connecting to TMDB.
    *   Dedicated search functionality to find specific titles.
    *   Dynamic hero banners and carousels using `carousel_slider` on the Home Tab.
*   **Cinema & Showtimes:** A dedicated tab and details page for cinemas, utilizing simulated local data to present schedules and locations.
*   **Interactive Ticket Booking:** 
    *   Users can select their preferred seats through an interactive layout presented in a Bottom Sheet, maintaining the visual context of the movie.
    *   Calculates dynamic pricing based on seat selection.
*   **Transaction & Ticket History:**
    *   Checkout flow to finalize purchases.
    *   Users can view their purchase history and active tickets.
*   **Media Playback & External Links:** 
    *   In-app movie trailers using `youtube_player_iframe`.
    *   Safe handling of external URLs (like routing or external browsers) using `url_launcher`.
*   **Session & Local Storage:** Employs `shared_preferences` to persist user sessions, reducing the need for repetitive logins.
*   **Security & Environment Configuration:** 
    *   Environment variables are managed securely with `flutter_dotenv`.
    *   The project is also configured with `flutter_secure_storage` and `jwt_decoder` for advanced secure token management.
*   **Custom Styling & Assets:** Utilizes `google_fonts` for polished typography, and a combination of `cupertino_icons` and `font_awesome_flutter` for high-quality, varied visual elements.

## App Flow & Screens

To demonstrate a complete User Experience (UX), the app implements a full journey across multiple interconnected pages:

*   **Initialization & Onboarding Flow:**
    *   **Splash Screen:** The initial loading screen that greets the user (`splash_screen.dart`).
    *   **Onboarding:** A guided tour for first-time users, managed via local storage (`onboarding_page.dart`).
    *   **Auth Pages:** Dedicated forms for Login and Registration (`login_page.dart`, `register_page.dart`).
*   **Main Dashboard (Bottom Navigation):**
    *   **Home Tab:** The central hub displaying greetings, carousels, and movie lists (`home_tab.dart`).
    *   **Movies Tab:** A comprehensive catalog of all available films (`movie_list_tab.dart`).
    *   **Cinemas Tab:** A directory of cinema locations (`cinema_list_tab.dart`).
    *   **Profile Tab:** The user account control center (`profile_tab.dart`).
*   **Detail & Secondary Pages:**
    *   **Search Page:** A dedicated interface for querying movies (`search_page.dart`).
    *   **Movie Detail:** Deep dive into movie info, trailers, and available cinemas (`movie_detail_page.dart`).
    *   **Cinema Detail:** Information about the cinema and randomly generated movie schedules (`cinema_detail_page.dart`).
    *   **Edit Profile:** A form to update personal data and photos (`edit_profile_page.dart`).
*   **Transactional Pages:**
    *   **Seat Selection:** An interactive Bottom Sheet UI for picking seats (`ticket_buttom_sheet.dart`).
    *   **Checkout:** Order summary and payment validation (`checkout_page.dart`).
    *   **My Tickets & History:** Sub-pages to view purchased tickets and past orders (`tiket_saya_tab.dart`, `daftar_transaksi_tab.dart`).

## Project Structure

The project follows a modular structure to separate concerns and improve maintainability:

*   **`lib/constants/`**: Contains global styling configurations (`app_color.dart`, `app_text_styles.dart`), enabling centralized theming.
*   **`lib/data/`**: Handles local data processing. Includes dummy data for cinemas (compensating for API limitations), payment methods, seat layouts (`seat_data.dart`), and local account logic (`account_data.dart`).
*   **`lib/models/`**: Defines the data structures and entities (e.g., `Movie`, `Transaction`) used across the application.
*   **`lib/repositories/`**: Acts as an intermediary layer between data sources (API or local) and the UI.
*   **`lib/routes/`**: Centralizes all navigation routes (`route_generator.dart`) for safer and easier routing management (`Navigator.pushNamed`).
*   **`lib/screens/`**: Contains all the UI pages, cleanly categorized:
    *   `auth/`: Splash screen, onboarding, login, register.
    *   `main/`: The core tabs (Home, Movies, Cinemas, Profile) and search.
    *   `details/`: Detailed views for movies and cinemas.
    *   `history/`: Checkout and transaction-related pages.
*   **`lib/services/`**: Houses the API service classes (`api_services.dart`) responsible for HTTP requests.
*   **`lib/widgets/`**: Contains reusable UI components, such as `movie_card.dart` and `ticket_buttom_sheet.dart`.

## Technical Highlights

*   **Stateful Tab Management**: The `main_page.dart` uses a `StatefulWidget` with an `IndexedStack` to switch tabs efficiently, preventing navigation history buildup and ensuring instant transitions.
*   **FutureBuilder Implementation**: Used extensively in screens requiring API data to handle loading states gracefully without freezing the UI.
*   **Simulated Realism**: To compensate for APIs that do not provide local cinema data, the app smartly merges remote movie data (via API) with local dummy data (for cinemas and seats), creating a realistic prototype.

## Getting Started

Follow these steps to run the project locally:

1.  **Clone the repository:**
    ```bash
    git clone <repository_url>
    cd movie_app
    ```

2.  **Install Dependencies:**
    Ensure you have the Flutter SDK installed. Run the following command to get all required packages:
    ```bash
    flutter pub get
    ```

3.  **Environment Variables:**
    Create a `.env` file in the root directory based on the project requirements (e.g., storing your TMDB API keys).

4.  **Firebase Configuration:**
    Ensure that the `google-services.json` (for Android) and `GoogleService-Info.plist` (for iOS) are correctly placed in their respective directories if you intend to test the Firebase Authentication features.

5.  **Run the Application:**
    Connect a device or start an emulator, then run:
    ```bash
    flutter run
    ```
