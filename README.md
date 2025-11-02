# SpendWise - Personal Finance Management App

SpendWise is a comprehensive personal finance management mobile application built with Flutter. It helps users track their expenses, analyze spending patterns, and make informed financial decisions.

## Features

### Home Screen
- **Overview Cards**: Quick view of income, expenses, and savings with monthly comparisons
- **Period Selector**: Filter data by Today, Last 7 Days, or This Month
- **Spending Trends**: 7-day spending trend visualization
- **Monthly Comparison**: Current period vs previous period with percentage changes
- **Top Categories**: Top 4 spending categories with progress bars
- **Quick Stats**: Average daily spending, biggest expense, transaction count, most used category
- **Quick Insights**: Personalized financial insights and recommendations
- **Expense Breakdown**: Pie chart showing category distribution
- **Recent Transactions**: List of most recent transactions

### Analytics Screen
- **Money Flow (Sankey Diagram)**: Visual representation of income flow to categories and savings
- **Income vs Expenses Chart**: Line chart comparing income, expenses, and savings over 12 months
- **Monthly Trends**: Bar chart showing monthly income and expenses
- **Category Trends**: Multi-line chart showing spending trends by category over time
- **Category Distribution**: Detailed breakdown with icons and percentages
- **Category Details**: Drill-down view with stats per category
- **Weekly Patterns**: Bar chart showing average spending by day of week
- **Spending Patterns**: Insights about weekend vs weekday spending
- **Budget Tracking**: Progress bars showing budget vs actual spending per category
- **Spending Forecast**: Predictions for next month based on historical data
- **Year-over-Year Comparison**: Compare current year vs previous year spending
- **Spending Trends**: Daily/weekly trends based on time period filter
- **Insights**: Actionable financial recommendations

### Upload Screen
- PDF bank statement upload
- Upload progress tracking
- File selection from device

### Profile Screen
- User information
- Settings:
  - Dark mode toggle
  - Language selection (English/Turkish)
  - Notifications settings
  - App information

## Tech Stack

- **Framework**: Flutter
- **State Management**: Riverpod
- **Navigation**: go_router
- **Charts**: fl_chart
- **UI Components**: Custom components inspired by shadcn/ui
- **Localization**: Flutter Intl (English & Turkish)
- **Storage**: shared_preferences

## Project Structure

```
lib/
├── core/
│   ├── constants/      # App constants
│   ├── theme/          # Theme and styling
│   └── utils/          # Utility functions
├── data/
│   ├── mock/           # Mock data for development
│   ├── models/         # Data models
│   └── services/       # API service interfaces
├── l10n/               # Localization files
├── presentation/
│   ├── screens/        # Screen widgets
│   ├── widgets/        # Reusable widgets
│   └── navigation/     # Routing configuration
└── providers/          # Riverpod providers

```

## Getting Started

### Prerequisites
- Flutter SDK (latest stable version)
- Dart SDK
- Android Studio / Xcode for mobile development
- VS Code or Android Studio as IDE

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd SpendWise-Client
```

2. Install dependencies:
```bash
flutter pub get
```

3. Generate localization files:
```bash
flutter gen-l10n
```

4. Run the app:
```bash
flutter run
```

## Localization

The app supports English and Turkish. To add more languages:
1. Add new ARB files in `lib/l10n/`
2. Run `flutter gen-l10n`
3. Update language provider

## Mock Data

Currently, the app uses mock data for development. Mock data includes:
- 12 months of transaction history
- Varied monthly spending patterns
- Seasonal variations
- Year-over-year data
- Budget data

See `docs/BACKEND_API.md` for backend integration requirements.

## Development

### Adding New Features

1. Create models in `lib/data/models/`
2. Create providers in `lib/providers/`
3. Create widgets in `lib/presentation/widgets/` or screen-specific folders
4. Add localization strings to `lib/l10n/app_en.arb` and `lib/l10n/app_tr.arb`
5. Update navigation if adding new screens

### Testing

Run tests with:
```bash
flutter test
```

## Backend Integration

See `docs/BACKEND_API.md` for detailed backend API requirements and integration guide.

## License

[Your License Here]

## Contributing

[Contributing Guidelines]
