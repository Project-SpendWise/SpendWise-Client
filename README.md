# SpendWise - Personal Finance Management App

## 🎥 Project Presentation Video

<div align="center">

### 📹 **Watch the Complete Project Demonstration**

**[👉 CLICK HERE TO WATCH THE VIDEO 👈](https://drive.google.com/file/d/1ZiwSxTRRA50gxMJeQ_mSuYlTxH1J_b5t/view?usp=sharing)**

*This video demonstrates the complete SpendWise application, including code structure, API integration, database design, and feature walkthroughs.*

</div>

---

## 📱 What is SpendWise?

SpendWise is a mobile application that helps users manage their personal finances. Users can:
- Upload bank statements (PDF files)
- View all their transactions automatically extracted from statements
- Analyze spending patterns with charts and graphs
- Track expenses by category (Food, Transport, Shopping, etc.)
- Set budgets and compare with actual spending
- Get financial insights and recommendations

The app is built with **Flutter**, which is Google's framework for building mobile apps that work on both Android and iOS.

---

## 🎯 Understanding the Project Structure

This project follows a **clean architecture** pattern, which means the code is organized into layers that have specific responsibilities. This makes the code easier to understand, maintain, and test.

### Key Concepts (For Beginners)

1. **Flutter**: A framework for building mobile apps using the Dart programming language
2. **Dart**: The programming language used to write Flutter apps
3. **Widget**: Everything in Flutter is a widget (buttons, text, screens, etc.)
4. **State Management**: How the app remembers and updates data (we use Riverpod)
5. **API**: How the app communicates with the backend server
6. **Provider**: A way to share data across different parts of the app

---

## 📁 Complete Project Structure

```
SpendWise-Client/
│
├── lib/                          # All application code goes here
│   │
│   ├── main.dart                 # 🚀 App entry point - starts the app
│   │
│   ├── core/                     # Core functionality (reusable across app)
│   │   ├── constants/           # Fixed values used throughout app
│   │   │   ├── api_constants.dart    # API base URL and endpoints
│   │   │   └── app_constants.dart    # App-wide constants (spacing, sizes, etc.)
│   │   │
│   │   ├── theme/               # App appearance (colors, fonts, styles)
│   │   │   ├── app_colors.dart       # Color definitions
│   │   │   ├── app_text_styles.dart  # Text styling
│   │   │   └── app_theme.dart        # Light/dark theme configuration
│   │   │
│   │   └── utils/               # Helper functions
│   │       ├── app_initializer.dart      # Loads data when app starts
│   │       ├── date_formatter.dart      # Formats dates for display
│   │       └── mock_data_initializer.dart # For testing with fake data
│   │
│   ├── data/                     # Data layer - handles all data operations
│   │   ├── models/              # Data structures (like blueprints)
│   │   │   ├── transaction.dart      # What a transaction looks like
│   │   │   ├── statement.dart        # What a bank statement looks like
│   │   │   ├── user.dart             # What a user looks like
│   │   │   ├── budget.dart           # What a budget looks like
│   │   │   ├── category.dart         # What a category looks like
│   │   │   └── file_model.dart       # What a file looks like
│   │   │
│   │   ├── services/            # API communication
│   │   │   ├── api_service.dart          # Base API class (handles HTTP requests)
│   │   │   ├── auth_service.dart         # Login, register, user management
│   │   │   ├── transaction_service.dart  # Get transactions from API
│   │   │   ├── upload_service.dart       # Upload bank statements
│   │   │   ├── analytics_service.dart    # Get analytics data
│   │   │   ├── budget_service.dart      # Budget operations
│   │   │   ├── file_service.dart         # File operations
│   │   │   └── api_models.dart           # API request/response models
│   │   │
│   │   └── mock/                # Fake data for testing
│   │       └── mock_data.dart          # Sample transactions, statements, etc.
│   │
│   ├── presentation/             # UI layer - everything user sees
│   │   ├── navigation/          # App navigation (routing)
│   │   │   └── app_router.dart       # Defines all app routes/screens
│   │   │
│   │   ├── screens/             # Full-screen pages
│   │   │   ├── home/            # Home screen
│   │   │   │   ├── home_screen.dart
│   │   │   │   └── widgets/          # Widgets only used on home screen
│   │   │   │       ├── overview_cards.dart      # Income/Expenses/Savings cards
│   │   │   │       ├── spending_trends_card.dart
│   │   │   │       ├── monthly_comparison_card.dart
│   │   │   │       ├── quick_stats_card.dart
│   │   │   │       ├── quick_insights_card.dart
│   │   │   │       └── recent_transactions.dart
│   │   │   │
│   │   │   ├── analytics/       # Analytics screen
│   │   │   │   ├── analytics_screen.dart
│   │   │   │   └── widgets/
│   │   │   │       ├── income_expenses_chart.dart
│   │   │   │       ├── monthly_trends_chart.dart
│   │   │   │       ├── spending_patterns_card.dart
│   │   │   │       ├── spending_forecast_card.dart
│   │   │   │       ├── year_over_year_chart.dart
│   │   │   │       └── spending_trends.dart
│   │   │   │
│   │   │   ├── upload/          # Upload screen
│   │   │   │   ├── upload_screen.dart
│   │   │   │   └── widgets/
│   │   │   │       ├── file_picker_button.dart
│   │   │   │       ├── upload_progress.dart
│   │   │   │       ├── file_list_widget.dart
│   │   │   │       └── file_viewer_screen.dart
│   │   │   │
│   │   │   ├── profile/         # Profile screen
│   │   │   │   ├── profile_screen.dart
│   │   │   │   └── widgets/
│   │   │   │       ├── edit_profile_dialog.dart
│   │   │   │       ├── change_password_dialog.dart
│   │   │   │       └── settings_section.dart
│   │   │   │
│   │   │   └── auth/            # Login/Register screens
│   │   │       ├── login_screen.dart
│   │   │       └── register_screen.dart
│   │   │
│   │   └── widgets/             # Reusable UI components
│   │       ├── layout/         # Layout components
│   │       │   ├── app_scaffold.dart      # Main app layout (with navigation)
│   │       │   └── navigation_bar.dart    # Bottom navigation bar
│   │       │
│   │       ├── common/          # Common reusable widgets
│   │       │   ├── custom_card.dart
│   │       │   ├── custom_button.dart
│   │       │   ├── error_boundary.dart
│   │       │   └── ...
│   │       │
│   │       └── profile_selector.dart  # Profile selection dropdown
│   │
│   ├── providers/               # State management (Riverpod)
│   │   ├── auth_provider.dart          # User authentication state
│   │   ├── transaction_provider.dart   # Transaction data state
│   │   ├── upload_provider.dart        # File upload state
│   │   ├── analytics_provider.dart     # Analytics data state
│   │   ├── budget_provider.dart        # Budget data state
│   │   ├── profile_provider.dart       # Selected profile state
│   │   ├── theme_provider.dart         # Dark/light theme state
│   │   ├── language_provider.dart      # Language selection state
│   │   ├── filter_provider.dart        # Time period filter state
│   │   ├── monthly_comparison_provider.dart  # Monthly comparison calculations
│   │   └── quick_stats_provider.dart   # Quick stats calculations
│   │
│   └── l10n/                    # Localization (translations)
│       ├── app_en.arb           # English translations
│       ├── app_tr.arb           # Turkish translations
│       └── app_localizations.dart # Generated localization code
│
├── android/                     # Android-specific code
├── ios/                         # iOS-specific code
├── web/                         # Web-specific code
├── windows/                     # Windows-specific code
├── test/                        # Unit and widget tests
├── docs/                        # Documentation
├── pubspec.yaml                 # Project dependencies and configuration
└── README.md                    # This file
```

---

## 🔄 How the App Works: Data Flow

Understanding how data flows through the app is crucial. Here's the complete flow:

### Example: Displaying Transactions on Home Screen

```
1. USER OPENS APP
   ↓
2. main.dart runs → App starts
   ↓
3. app_router.dart → Checks if user is logged in
   ↓
4. If logged in → Shows home_screen.dart
   ↓
5. home_screen.dart → Shows overview_cards.dart widget
   ↓
6. overview_cards.dart → Asks transaction_provider.dart for data
   ↓
7. transaction_provider.dart → Checks if it has data
   ↓
8. If no data → app_initializer.dart loads data on app start
   ↓
9. app_initializer.dart → Calls transaction_service.dart
   ↓
10. transaction_service.dart → Calls api_service.dart
    ↓
11. api_service.dart → Sends HTTP GET request to backend
    ↓
12. Backend API → Queries database
    ↓
13. Database → Returns transaction data
    ↓
14. Backend API → Sends JSON response
    ↓
15. api_service.dart → Parses JSON response
    ↓
16. transaction_service.dart → Converts to Transaction objects
    ↓
17. transaction_provider.dart → Stores transactions in state
    ↓
18. overview_cards.dart → Reads from transaction_provider
    ↓
19. UI Updates → User sees income, expenses, savings
```

### Key Components Explained

#### 1. **Models** (`lib/data/models/`)
Think of models as **blueprints** or **templates**. They define what data looks like.

Example: `transaction.dart` defines that a transaction has:
- `id`: Unique identifier
- `date`: When it happened
- `description`: What it was for
- `amount`: How much money
- `type`: Income or expense
- `category`: What category (Food, Transport, etc.)

#### 2. **Services** (`lib/data/services/`)
Services are like **messengers** between the app and the backend server. They:
- Make API calls (GET, POST, PUT, DELETE)
- Convert data between app format and API format
- Handle errors

Example: `transaction_service.dart`:
- Has a method `getTransactions()` that asks the backend for transactions
- Sends HTTP request to `/api/transactions`
- Receives JSON response
- Converts JSON to `Transaction` objects
- Returns list of transactions

#### 3. **Providers** (`lib/providers/`)
Providers are like **memory** for the app. They:
- Store data that multiple screens need
- Update UI when data changes
- Provide data to widgets

Example: `transaction_provider.dart`:
- Stores list of all transactions
- Has methods like `totalIncome`, `totalExpenses`, `savings`
- Any widget can "watch" this provider to get updates

#### 4. **Screens** (`lib/presentation/screens/`)
Screens are the **full pages** users see.

Example: `home_screen.dart`:
- Shows greeting
- Shows overview cards
- Shows spending trends
- Shows recent transactions
- Uses widgets to build the UI

#### 5. **Widgets** (`lib/presentation/widgets/` and `lib/presentation/screens/*/widgets/`)
Widgets are **reusable UI components**.

Example: `overview_cards.dart`:
- Shows income, expenses, savings cards
- Gets data from `transaction_provider`
- Updates when data changes

---

## 🗂️ Detailed Folder Explanations

### `lib/core/` - Core Functionality

This folder contains code that is used throughout the entire app.

#### `constants/`
- **Purpose**: Store fixed values that don't change
- **Files**:
  - `api_constants.dart`: API base URL (e.g., `https://api.spendwise.com`)
  - `app_constants.dart`: App-wide constants like spacing sizes, border radius, etc.

#### `theme/`
- **Purpose**: Define how the app looks (colors, fonts, styles)
- **Files**:
  - `app_colors.dart`: All color definitions (primary, success, error, etc.)
  - `app_text_styles.dart`: Text styles (headings, body text, labels)
  - `app_theme.dart`: Light and dark theme configurations

#### `utils/`
- **Purpose**: Helper functions used across the app
- **Files**:
  - `app_initializer.dart`: **Important!** Loads data when app starts (transactions, budgets)
  - `date_formatter.dart`: Formats dates for display (e.g., "Jan 15, 2024")
  - `mock_data_initializer.dart`: For testing with fake data

---

### `lib/data/` - Data Layer

This folder handles all data operations - getting data, storing it, and converting it.

#### `models/`
- **Purpose**: Define data structures (like blueprints)
- **Files**:
  - `transaction.dart`: Defines what a transaction is
  - `statement.dart`: Defines what a bank statement is
  - `user.dart`: Defines what a user is
  - `budget.dart`: Defines what a budget is
  - `category.dart`: Defines what a category is
  - `file_model.dart`: Defines what a file is

**Example from `transaction.dart`:**
```dart
class Transaction {
  final String id;
  final DateTime date;
  final String description;
  final double amount;
  final TransactionType type;  // income or expense
  final String? category;      // optional
  final String? account;        // optional
}
```

#### `services/`
- **Purpose**: Communicate with backend API
- **Files**:
  - `api_service.dart`: **Base class** for all API calls. Handles:
    - HTTP requests (GET, POST, PUT, DELETE)
    - Authentication (JWT tokens)
    - Error handling
    - Token refresh
  
  - `auth_service.dart`: User authentication
    - `login()`: User login
    - `register()`: User registration
    - `getCurrentUser()`: Get logged-in user info
    - `updateProfile()`: Update user profile
    - `changePassword()`: Change password
  
  - `transaction_service.dart`: Transaction operations
    - `getTransactions()`: Get all transactions (with filters)
    - `getSummary()`: Get transaction summary
  
  - `upload_service.dart`: File upload
    - `uploadStatement()`: Upload bank statement PDF
    - `getStatements()`: Get list of uploaded statements
    - `deleteStatement()`: Delete a statement
  
  - `analytics_service.dart`: Analytics data
    - `getCategoryBreakdown()`: Category spending breakdown
    - `getSpendingTrends()`: Spending trends over time
    - `getFinancialInsights()`: Financial recommendations
    - `getMonthlyTrends()`: Monthly trends
    - And more...
  
  - `budget_service.dart`: Budget operations
    - `getBudgets()`: Get all budgets
    - `createBudget()`: Create new budget
    - `updateBudget()`: Update budget
    - `deleteBudget()`: Delete budget
  
  - `file_service.dart`: File operations
    - `getFiles()`: Get list of files
    - `downloadFile()`: Download a file
    - `deleteFile()`: Delete a file

#### `mock/`
- **Purpose**: Fake data for testing when backend is not available
- **Files**:
  - `mock_data.dart`: Sample transactions, statements, budgets, etc.

---

### `lib/presentation/` - User Interface

This folder contains everything the user sees and interacts with.

#### `navigation/`
- **Purpose**: Define app navigation (which screen shows when)
- **Files**:
  - `app_router.dart`: **Important!** Defines all routes:
    - `/login` → Login screen
    - `/register` → Register screen
    - `/home` → Home screen
    - `/upload` → Upload screen
    - `/analytics` → Analytics screen
    - `/profile` → Profile screen
    - Also handles authentication checks (redirects to login if not authenticated)

#### `screens/`
- **Purpose**: Full-screen pages
- **Structure**: Each screen has its own folder with the screen file and a `widgets/` folder for screen-specific widgets

**Home Screen** (`home/`):
- `home_screen.dart`: Main home screen
- `widgets/`:
  - `overview_cards.dart`: Income, Expenses, Savings cards
  - `spending_trends_card.dart`: 7-day spending chart
  - `monthly_comparison_card.dart`: Current vs previous month
  - `quick_stats_card.dart`: Quick statistics
  - `quick_insights_card.dart`: Financial insights
  - `recent_transactions.dart`: List of recent transactions

**Analytics Screen** (`analytics/`):
- `analytics_screen.dart`: Main analytics screen
- `widgets/`:
  - `income_expenses_chart.dart`: Income vs expenses line chart
  - `monthly_trends_chart.dart`: Monthly bar chart
  - `spending_patterns_card.dart`: Weekly patterns
  - `spending_forecast_card.dart`: Future spending predictions
  - `year_over_year_chart.dart`: Year comparison chart
  - `spending_trends.dart`: Daily/weekly trends

**Upload Screen** (`upload/`):
- `upload_screen.dart`: Main upload screen
- `widgets/`:
  - `file_picker_button.dart`: Button to select file
  - `upload_progress.dart`: Shows upload progress
  - `file_list_widget.dart`: List of uploaded files
  - `file_viewer_screen.dart`: View uploaded PDF

**Profile Screen** (`profile/`):
- `profile_screen.dart`: Main profile screen
- `widgets/`:
  - `edit_profile_dialog.dart`: Edit user profile
  - `change_password_dialog.dart`: Change password
  - `settings_section.dart`: App settings

**Auth Screens** (`auth/`):
- `login_screen.dart`: Login page
- `register_screen.dart`: Registration page

#### `widgets/`
- **Purpose**: Reusable UI components used across multiple screens
- **Structure**:
  - `layout/`: Layout components (scaffold, navigation bar)
  - `common/`: Common widgets (buttons, cards, error boundaries)
  - `profile_selector.dart`: Profile selection dropdown

---

### `lib/providers/` - State Management

This folder contains **Riverpod providers** that manage app state (data that needs to be shared).

#### Key Providers:

1. **`auth_provider.dart`**
   - Stores: User authentication state, user info, access token
   - Methods: `login()`, `register()`, `logout()`, `refreshAccessToken()`

2. **`transaction_provider.dart`**
   - Stores: List of all transactions
   - Methods: `addTransaction()`, `addTransactions()`, `clearTransactions()`
   - Getters: `totalIncome`, `totalExpenses`, `savings`, `categoryBreakdown`, `getRecentTransactions()`

3. **`upload_provider.dart`**
   - Stores: Upload status, progress, list of statements
   - Methods: `uploadFile()`, `loadStatements()`, `removeStatement()`

4. **`analytics_provider.dart`**
   - Stores: Analytics data (category breakdown, trends, insights)
   - Methods: `loadCategoryBreakdown()`, `loadSpendingTrends()`, etc.

5. **`budget_provider.dart`**
   - Stores: List of budgets
   - Methods: `addBudget()`, `removeBudget()`, `updateBudget()`

6. **`profile_provider.dart`**
   - Stores: Selected profile/statement ID
   - Methods: `selectProfile()`, `setDefaultProfile()`

7. **`theme_provider.dart`**
   - Stores: Current theme (light/dark)
   - Methods: `toggleTheme()`

8. **`language_provider.dart`**
   - Stores: Current language (English/Turkish)
   - Methods: `setLanguage()`

9. **`filter_provider.dart`**
   - Stores: Time period filter (Today, Last 7 Days, This Month)
   - Methods: `setTimePeriod()`

10. **`monthly_comparison_provider.dart`**
    - Calculates: Current period vs previous period comparisons
    - Provides: Income change %, expenses change %, savings change %

11. **`quick_stats_provider.dart`**
    - Calculates: Quick statistics (average daily spending, biggest expense, etc.)

---

### `lib/l10n/` - Localization

This folder contains translations for different languages.

- `app_en.arb`: English translations
- `app_tr.arb`: Turkish translations
- `app_localizations.dart`: Generated code (auto-generated, don't edit manually)

---

## 🚀 How the App Starts

1. **`main.dart`** is the entry point
   ```dart
   void main() {
     runApp(
       const ProviderScope(  // Wraps app with Riverpod
         child: SpendWiseApp(),
       ),
     );
   }
   ```

2. **`SpendWiseApp`** widget builds the app:
   - Sets up theme (light/dark)
   - Sets up language (English/Turkish)
   - Sets up routing (`app_router.dart`)

3. **`app_router.dart`** checks authentication:
   - If logged in → Shows `/home`
   - If not logged in → Shows `/login`

4. **`app_initializer.dart`** (called when user logs in):
   - Loads transactions from API
   - Loads budgets from API
   - Updates providers with data

5. **UI updates** automatically when providers have data

---

## 🔗 How Components Connect

### Example: Showing Income on Home Screen

```
1. User opens app → home_screen.dart displays
   ↓
2. home_screen.dart uses overview_cards.dart widget
   ↓
3. overview_cards.dart reads from monthly_comparison_provider
   ↓
4. monthly_comparison_provider reads from transaction_provider
   ↓
5. transaction_provider has data from app_initializer.dart
   ↓
6. app_initializer.dart called transaction_service.getTransactions()
   ↓
7. transaction_service.getTransactions() called api_service.get()
   ↓
8. api_service.get() sends HTTP GET to backend API
   ↓
9. Backend queries database and returns JSON
   ↓
10. api_service parses JSON → transaction_service converts to Transaction objects
    ↓
11. transaction_provider stores transactions
    ↓
12. monthly_comparison_provider calculates totals
    ↓
13. overview_cards.dart displays income amount
    ↓
14. User sees income on screen! ✅
```

---

## 📚 Key Files to Understand

### For Beginners - Start Here:

1. **`lib/main.dart`** - How the app starts
2. **`lib/presentation/navigation/app_router.dart`** - How navigation works
3. **`lib/presentation/screens/home/home_screen.dart`** - Main screen structure
4. **`lib/providers/transaction_provider.dart`** - How data is stored
5. **`lib/data/services/transaction_service.dart`** - How API calls work
6. **`lib/data/services/api_service.dart`** - Base API communication
7. **`lib/core/utils/app_initializer.dart`** - How data loads on startup

### Understanding a Feature:

To understand how a feature works, follow this path:
1. Find the **screen** that shows the feature (`lib/presentation/screens/`)
2. Find the **widget** that displays it (`widgets/` folder)
3. Find the **provider** it uses (`lib/providers/`)
4. Find the **service** that gets data (`lib/data/services/`)
5. Find the **API endpoint** it calls (check `api_service.dart`)

---

## 🛠️ Tech Stack Explained

### Flutter
- **What it is**: Framework for building mobile apps
- **Why we use it**: Write once, run on Android and iOS
- **Language**: Dart

### Riverpod
- **What it is**: State management solution
- **Why we use it**: Manages app data and updates UI automatically
- **Alternative**: Could use Provider, Bloc, GetX, etc.

### GoRouter
- **What it is**: Navigation/routing package
- **Why we use it**: Handles screen navigation and deep linking
- **Alternative**: Could use Navigator 2.0, AutoRoute, etc.

### fl_chart
- **What it is**: Chart library
- **Why we use it**: Beautiful charts for analytics
- **Used for**: Line charts, bar charts, pie charts

### HTTP
- **What it is**: Package for making API calls
- **Why we use it**: Communicates with backend server
- **Used for**: GET, POST, PUT, DELETE requests

---

## 📖 Learning Path

### Step 1: Understand the Basics
1. Read this README completely
2. Look at `lib/main.dart` - understand how app starts
3. Look at `lib/presentation/screens/home/home_screen.dart` - understand screen structure

### Step 2: Understand Data Flow
1. Look at `lib/providers/transaction_provider.dart` - understand state management
2. Look at `lib/data/services/transaction_service.dart` - understand API calls
3. Look at `lib/core/utils/app_initializer.dart` - understand data loading

### Step 3: Understand a Complete Feature
1. Pick a feature (e.g., "Recent Transactions")
2. Find the screen/widget that shows it
3. Trace back to provider → service → API
4. Understand the complete flow

### Step 4: Explore More
1. Look at other screens (Analytics, Upload, Profile)
2. Understand how they work
3. See how they connect to providers and services

---

## 🔍 Common Questions

### Q: Where is the code that shows transactions?
**A**: 
- UI: `lib/presentation/screens/home/widgets/recent_transactions.dart`
- Data: `lib/providers/transaction_provider.dart`
- API: `lib/data/services/transaction_service.dart`

### Q: Where is the login code?
**A**: 
- UI: `lib/presentation/screens/auth/login_screen.dart`
- Logic: `lib/providers/auth_provider.dart`
- API: `lib/data/services/auth_service.dart`

### Q: Where is the file upload code?
**A**: 
- UI: `lib/presentation/screens/upload/upload_screen.dart`
- Logic: `lib/providers/upload_provider.dart`
- API: `lib/data/services/upload_service.dart`

### Q: How does the app know which user is logged in?
**A**: `lib/providers/auth_provider.dart` stores the user info and access token.

### Q: How does data get loaded when app starts?
**A**: `lib/core/utils/app_initializer.dart` is called when user logs in, and it loads transactions and budgets from the API.

### Q: Where are API endpoints defined?
**A**: 
- Base URL: `lib/core/constants/api_constants.dart`
- Endpoints: Defined in each service file (e.g., `transaction_service.dart` uses `/transactions`)

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (latest stable version)
- Dart SDK (comes with Flutter)
- Android Studio / Xcode (for mobile development)
- VS Code or Android Studio (as IDE)

### Installation

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd SpendWise-Client
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Generate localization files:**
   ```bash
   flutter gen-l10n
   ```

4. **Run the app:**
   ```bash
   flutter run
   ```

---

## 📝 Development Guidelines

### Adding a New Feature

1. **Create/Update Model** (`lib/data/models/`)
   - Define the data structure

2. **Create/Update Service** (`lib/data/services/`)
   - Add API call methods

3. **Create/Update Provider** (`lib/providers/`)
   - Add state management

4. **Create/Update Screen/Widget** (`lib/presentation/screens/` or `widgets/`)
   - Create UI

5. **Add Localization** (`lib/l10n/`)
   - Add text strings to `app_en.arb` and `app_tr.arb`

6. **Update Navigation** (`lib/presentation/navigation/app_router.dart`)
   - Add route if it's a new screen

### File Naming Conventions
- Files: `snake_case.dart` (e.g., `home_screen.dart`)
- Classes: `PascalCase` (e.g., `HomeScreen`)
- Variables/Functions: `camelCase` (e.g., `getTransactions`)

---

## 📚 Additional Documentation

- **Backend API Documentation**: See `docs/BACKEND_API.md`
- **Backend Requirements**: See `docs/BACKEND_REQUIREMENTS.md`
- **Video Presentation Guide**: See `docs/VIDEO_PRESENTATION_SCRIPT.md`
- **Feature Code Mapping**: See `docs/FEATURE_CODE_MAPPING.md`

---

## 🎯 Summary

This project is organized into clear layers:
- **`core/`**: Reusable functionality
- **`data/`**: Data models, API services, mock data
- **`presentation/`**: UI screens and widgets
- **`providers/`**: State management
- **`l10n/`**: Translations

Data flows: **UI → Provider → Service → API → Backend → Database**

Understanding this structure will help you navigate and understand the entire codebase!

---

## 📄 License

[Your License Here]

---

## 🤝 Contributing

[Contributing Guidelines]

---

**Happy Coding! 🚀**
