// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'SpendWise';

  @override
  String get appSlogan => 'Spend smarter. Save wiser.';

  @override
  String get hello => 'Hello';

  @override
  String get home => 'Home';

  @override
  String get upload => 'Upload';

  @override
  String get analytics => 'Analytics';

  @override
  String get profile => 'Profile';

  @override
  String get income => 'Income';

  @override
  String get expenses => 'Expenses';

  @override
  String get savings => 'Savings';

  @override
  String get recentTransactions => 'Recent Transactions';

  @override
  String get expenseBreakdown => 'Expense Breakdown';

  @override
  String get uploadStatement => 'Upload Bank Statement';

  @override
  String get selectFile => 'Select File';

  @override
  String get uploadedFiles => 'Uploaded Files';

  @override
  String get noFileUploaded => 'No file uploaded yet';

  @override
  String get uploadedFilesDescription => 'Uploaded PDFs will appear here';

  @override
  String get moneyFlow => 'Money Flow';

  @override
  String get noData => 'No data yet';

  @override
  String get uploadDataMessage => 'Upload data to see money flow';

  @override
  String get categoryDistribution => 'Category Distribution';

  @override
  String get noCategory => 'No categories yet';

  @override
  String get categoryDescription => 'Expense categories will appear here';

  @override
  String get spendingTrends => 'Spending Trends';

  @override
  String get last7Days => 'Last 7 Days';

  @override
  String get insights => 'Insights';

  @override
  String get savingsRecommendations => 'Savings Recommendations';

  @override
  String get noInsights => 'No insights yet';

  @override
  String get insightsDescription => 'Savings recommendations require data';

  @override
  String get user => 'User';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get notifications => 'Notifications';

  @override
  String get on => 'On';

  @override
  String get off => 'Off';

  @override
  String get system => 'System';

  @override
  String get about => 'About';

  @override
  String get version => 'Version';

  @override
  String get logout => 'Logout';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get turkish => 'Turkish';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get loading => 'Loading...';

  @override
  String get uploading => 'Uploading...';

  @override
  String get processing => 'Processing...';

  @override
  String get success => 'Success';

  @override
  String get error => 'Error';

  @override
  String get food => 'Food';

  @override
  String get transport => 'Transport';

  @override
  String get shopping => 'Shopping';

  @override
  String get bills => 'Bills';

  @override
  String get entertainment => 'Entertainment';

  @override
  String get health => 'Health';

  @override
  String get education => 'Education';

  @override
  String get other => 'Other';

  @override
  String get lowSavingsRate => 'Low Savings Rate';

  @override
  String lowSavingsMessage(String percentage) {
    return 'You are saving $percentage% of your income. You should aim for at least 20%.';
  }

  @override
  String get excessiveSpending => 'Excessive Spending';

  @override
  String get excessiveSpendingMessage => 'Your expenses exceed your income. We recommend making a budget plan.';

  @override
  String get highestSpendingCategory => 'Highest Spending Category';

  @override
  String highestSpendingMessage(String category) {
    return 'You spend the most in $category category. You can review your expenses in this category.';
  }

  @override
  String get greatJob => 'Great!';

  @override
  String get greatJobMessage => 'Your savings rate is at an ideal level. Keep it up!';

  @override
  String get uploadPdfDescription => 'Upload your bank statements in PDF format';

  @override
  String get fileSelected => 'File Selected';

  @override
  String get processingFile => 'Processing file...';

  @override
  String get fileProcessed => 'File processed successfully';

  @override
  String get thisMonth => 'This Month';

  @override
  String get thisYear => 'This Year';

  @override
  String get budget => 'Budget';

  @override
  String get budgetRemaining => 'Budget Remaining';

  @override
  String get budgetExceeded => 'Budget Exceeded';

  @override
  String get monthlyComparison => 'Monthly Comparison';

  @override
  String get searchTransactions => 'Search transactions...';

  @override
  String get noTransactionsFound => 'No transactions found';

  @override
  String get vsLastMonth => 'vs Last Month';

  @override
  String get vsLastWeek => 'vs Last Week';

  @override
  String get vsLastYear => 'vs Last Year';

  @override
  String get averageDailySpending => 'Avg Daily';

  @override
  String get biggestExpense => 'Biggest';

  @override
  String get totalTransactions => 'Transactions';

  @override
  String get mostUsedCategory => 'Most Used';

  @override
  String get topCategories => 'Top Categories';

  @override
  String get quickStats => 'Quick Stats';

  @override
  String get increasedBy => 'Increased by';

  @override
  String get decreasedBy => 'Decreased by';

  @override
  String get monthlyTrends => 'Monthly Trends';

  @override
  String get categoryTrends => 'Category Trends';

  @override
  String get weeklyPatterns => 'Weekly Patterns';

  @override
  String get incomeVsExpenses => 'Income vs Expenses';

  @override
  String get budgetTracking => 'Budget Tracking';

  @override
  String get setBudget => 'Set Budget';

  @override
  String get budgetVsActual => 'Budget vs Actual';

  @override
  String get overBudget => 'Over Budget';

  @override
  String get underBudget => 'Under Budget';

  @override
  String get onTrack => 'On Track';

  @override
  String get spendingPatterns => 'Spending Patterns';

  @override
  String get peakSpendingDays => 'Peak Spending Days';

  @override
  String get yearOverYear => 'Year over Year';

  @override
  String get forecast => 'Forecast';

  @override
  String get predictedSpending => 'Predicted Spending';

  @override
  String get categoryDetails => 'Category Details';

  @override
  String get averageTransaction => 'Avg Transaction';

  @override
  String get transactionCount => 'Transaction Count';

  @override
  String get biggestTransaction => 'Biggest Transaction';

  @override
  String get last12Months => 'Last 12 Months';

  @override
  String get averageSpendingByDay => 'Average Spending by Day';

  @override
  String get mostSpendingOn => 'Most spending on';

  @override
  String get remaining => 'Remaining';

  @override
  String get used => 'Used';

  @override
  String budgetFor(String category) {
    return 'Budget for $category';
  }

  @override
  String get currentPeriod => 'Current Period';

  @override
  String get previousPeriod => 'Previous Period';

  @override
  String get approachingBudget => 'Approaching Budget';

  @override
  String get login => 'Login';

  @override
  String get register => 'Register';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get name => 'Name';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get dontHaveAccount => 'Don\'t have an account?';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get signIn => 'Sign In';

  @override
  String get signUp => 'Sign Up';

  @override
  String get signOut => 'Sign Out';

  @override
  String get invalidEmail => 'Please enter a valid email';

  @override
  String get passwordTooShort => 'Password must be at least 6 characters';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get loginFailed => 'Login failed. Please check your credentials.';

  @override
  String get registrationFailed => 'Registration failed. Please try again.';

  @override
  String get welcomeBack => 'Welcome Back';

  @override
  String get welcomeMessage => 'Sign in to continue';

  @override
  String get createAccount => 'Create Account';

  @override
  String get createAccountMessage => 'Sign up to get started';

  @override
  String get signOutConfirm => 'Are you sure you want to sign out?';

  @override
  String get cancel => 'Cancel';

  @override
  String get username => 'Username';

  @override
  String get firstName => 'First Name';

  @override
  String get lastName => 'Last Name';

  @override
  String get optional => 'Optional';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get changePassword => 'Change Password';

  @override
  String get currentPassword => 'Current Password';

  @override
  String get newPassword => 'New Password';

  @override
  String get save => 'Save';

  @override
  String get profileUpdated => 'Profile updated successfully';

  @override
  String get updateFailed => 'Failed to update profile';

  @override
  String get passwordChanged => 'Password changed successfully';

  @override
  String get passwordChangeFailed => 'Failed to change password';

  @override
  String get currentPasswordRequired => 'Current password is required';
}
