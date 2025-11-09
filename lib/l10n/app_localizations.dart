import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr')
  ];

  /// The application name
  ///
  /// In en, this message translates to:
  /// **'SpendWise'**
  String get appName;

  /// The application slogan
  ///
  /// In en, this message translates to:
  /// **'Spend smarter. Save wiser.'**
  String get appSlogan;

  /// No description provided for @hello.
  ///
  /// In en, this message translates to:
  /// **'Hello'**
  String get hello;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @upload.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get upload;

  /// No description provided for @analytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analytics;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @income.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get income;

  /// No description provided for @expenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expenses;

  /// No description provided for @savings.
  ///
  /// In en, this message translates to:
  /// **'Savings'**
  String get savings;

  /// No description provided for @recentTransactions.
  ///
  /// In en, this message translates to:
  /// **'Recent Transactions'**
  String get recentTransactions;

  /// No description provided for @expenseBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Expense Breakdown'**
  String get expenseBreakdown;

  /// No description provided for @uploadStatement.
  ///
  /// In en, this message translates to:
  /// **'Upload Bank Statement'**
  String get uploadStatement;

  /// No description provided for @selectFile.
  ///
  /// In en, this message translates to:
  /// **'Select File'**
  String get selectFile;

  /// No description provided for @uploadedFiles.
  ///
  /// In en, this message translates to:
  /// **'Uploaded Files'**
  String get uploadedFiles;

  /// No description provided for @noFileUploaded.
  ///
  /// In en, this message translates to:
  /// **'No file uploaded yet'**
  String get noFileUploaded;

  /// No description provided for @uploadedFilesDescription.
  ///
  /// In en, this message translates to:
  /// **'Uploaded PDFs will appear here'**
  String get uploadedFilesDescription;

  /// No description provided for @moneyFlow.
  ///
  /// In en, this message translates to:
  /// **'Money Flow'**
  String get moneyFlow;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data yet'**
  String get noData;

  /// No description provided for @uploadDataMessage.
  ///
  /// In en, this message translates to:
  /// **'Upload data to see money flow'**
  String get uploadDataMessage;

  /// No description provided for @categoryDistribution.
  ///
  /// In en, this message translates to:
  /// **'Category Distribution'**
  String get categoryDistribution;

  /// No description provided for @noCategory.
  ///
  /// In en, this message translates to:
  /// **'No categories yet'**
  String get noCategory;

  /// No description provided for @categoryDescription.
  ///
  /// In en, this message translates to:
  /// **'Expense categories will appear here'**
  String get categoryDescription;

  /// No description provided for @spendingTrends.
  ///
  /// In en, this message translates to:
  /// **'Spending Trends'**
  String get spendingTrends;

  /// No description provided for @last7Days.
  ///
  /// In en, this message translates to:
  /// **'Last 7 Days'**
  String get last7Days;

  /// No description provided for @insights.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get insights;

  /// No description provided for @savingsRecommendations.
  ///
  /// In en, this message translates to:
  /// **'Savings Recommendations'**
  String get savingsRecommendations;

  /// No description provided for @noInsights.
  ///
  /// In en, this message translates to:
  /// **'No insights yet'**
  String get noInsights;

  /// No description provided for @insightsDescription.
  ///
  /// In en, this message translates to:
  /// **'Savings recommendations require data'**
  String get insightsDescription;

  /// No description provided for @user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @on.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get on;

  /// No description provided for @off.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get off;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @turkish.
  ///
  /// In en, this message translates to:
  /// **'Turkish'**
  String get turkish;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @uploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading...'**
  String get uploading;

  /// No description provided for @processing.
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get processing;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @food.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get food;

  /// No description provided for @transport.
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get transport;

  /// No description provided for @shopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get shopping;

  /// No description provided for @bills.
  ///
  /// In en, this message translates to:
  /// **'Bills'**
  String get bills;

  /// No description provided for @entertainment.
  ///
  /// In en, this message translates to:
  /// **'Entertainment'**
  String get entertainment;

  /// No description provided for @health.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get health;

  /// No description provided for @education.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get education;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @lowSavingsRate.
  ///
  /// In en, this message translates to:
  /// **'Low Savings Rate'**
  String get lowSavingsRate;

  /// No description provided for @lowSavingsMessage.
  ///
  /// In en, this message translates to:
  /// **'You are saving {percentage}% of your income. You should aim for at least 20%.'**
  String lowSavingsMessage(String percentage);

  /// No description provided for @excessiveSpending.
  ///
  /// In en, this message translates to:
  /// **'Excessive Spending'**
  String get excessiveSpending;

  /// No description provided for @excessiveSpendingMessage.
  ///
  /// In en, this message translates to:
  /// **'Your expenses exceed your income. We recommend making a budget plan.'**
  String get excessiveSpendingMessage;

  /// No description provided for @highestSpendingCategory.
  ///
  /// In en, this message translates to:
  /// **'Highest Spending Category'**
  String get highestSpendingCategory;

  /// No description provided for @highestSpendingMessage.
  ///
  /// In en, this message translates to:
  /// **'You spend the most in {category} category. You can review your expenses in this category.'**
  String highestSpendingMessage(String category);

  /// No description provided for @greatJob.
  ///
  /// In en, this message translates to:
  /// **'Great!'**
  String get greatJob;

  /// No description provided for @greatJobMessage.
  ///
  /// In en, this message translates to:
  /// **'Your savings rate is at an ideal level. Keep it up!'**
  String get greatJobMessage;

  /// No description provided for @uploadPdfDescription.
  ///
  /// In en, this message translates to:
  /// **'Upload your bank statements in PDF format'**
  String get uploadPdfDescription;

  /// No description provided for @fileSelected.
  ///
  /// In en, this message translates to:
  /// **'File Selected'**
  String get fileSelected;

  /// No description provided for @processingFile.
  ///
  /// In en, this message translates to:
  /// **'Processing file...'**
  String get processingFile;

  /// No description provided for @fileProcessed.
  ///
  /// In en, this message translates to:
  /// **'File processed successfully'**
  String get fileProcessed;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// No description provided for @thisYear.
  ///
  /// In en, this message translates to:
  /// **'This Year'**
  String get thisYear;

  /// No description provided for @budget.
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get budget;

  /// No description provided for @budgetRemaining.
  ///
  /// In en, this message translates to:
  /// **'Budget Remaining'**
  String get budgetRemaining;

  /// No description provided for @budgetExceeded.
  ///
  /// In en, this message translates to:
  /// **'Budget Exceeded'**
  String get budgetExceeded;

  /// No description provided for @monthlyComparison.
  ///
  /// In en, this message translates to:
  /// **'Monthly Comparison'**
  String get monthlyComparison;

  /// No description provided for @searchTransactions.
  ///
  /// In en, this message translates to:
  /// **'Search transactions...'**
  String get searchTransactions;

  /// No description provided for @noTransactionsFound.
  ///
  /// In en, this message translates to:
  /// **'No transactions found'**
  String get noTransactionsFound;

  /// No description provided for @vsLastMonth.
  ///
  /// In en, this message translates to:
  /// **'vs Last Month'**
  String get vsLastMonth;

  /// No description provided for @vsLastWeek.
  ///
  /// In en, this message translates to:
  /// **'vs Last Week'**
  String get vsLastWeek;

  /// No description provided for @vsLastYear.
  ///
  /// In en, this message translates to:
  /// **'vs Last Year'**
  String get vsLastYear;

  /// No description provided for @averageDailySpending.
  ///
  /// In en, this message translates to:
  /// **'Avg Daily'**
  String get averageDailySpending;

  /// No description provided for @biggestExpense.
  ///
  /// In en, this message translates to:
  /// **'Biggest'**
  String get biggestExpense;

  /// No description provided for @totalTransactions.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get totalTransactions;

  /// No description provided for @mostUsedCategory.
  ///
  /// In en, this message translates to:
  /// **'Most Used'**
  String get mostUsedCategory;

  /// No description provided for @topCategories.
  ///
  /// In en, this message translates to:
  /// **'Top Categories'**
  String get topCategories;

  /// No description provided for @quickStats.
  ///
  /// In en, this message translates to:
  /// **'Quick Stats'**
  String get quickStats;

  /// No description provided for @increasedBy.
  ///
  /// In en, this message translates to:
  /// **'Increased by'**
  String get increasedBy;

  /// No description provided for @decreasedBy.
  ///
  /// In en, this message translates to:
  /// **'Decreased by'**
  String get decreasedBy;

  /// No description provided for @monthlyTrends.
  ///
  /// In en, this message translates to:
  /// **'Monthly Trends'**
  String get monthlyTrends;

  /// No description provided for @categoryTrends.
  ///
  /// In en, this message translates to:
  /// **'Category Trends'**
  String get categoryTrends;

  /// No description provided for @weeklyPatterns.
  ///
  /// In en, this message translates to:
  /// **'Weekly Patterns'**
  String get weeklyPatterns;

  /// No description provided for @incomeVsExpenses.
  ///
  /// In en, this message translates to:
  /// **'Income vs Expenses'**
  String get incomeVsExpenses;

  /// No description provided for @budgetTracking.
  ///
  /// In en, this message translates to:
  /// **'Budget Tracking'**
  String get budgetTracking;

  /// No description provided for @setBudget.
  ///
  /// In en, this message translates to:
  /// **'Set Budget'**
  String get setBudget;

  /// No description provided for @budgetVsActual.
  ///
  /// In en, this message translates to:
  /// **'Budget vs Actual'**
  String get budgetVsActual;

  /// No description provided for @overBudget.
  ///
  /// In en, this message translates to:
  /// **'Over Budget'**
  String get overBudget;

  /// No description provided for @underBudget.
  ///
  /// In en, this message translates to:
  /// **'Under Budget'**
  String get underBudget;

  /// No description provided for @onTrack.
  ///
  /// In en, this message translates to:
  /// **'On Track'**
  String get onTrack;

  /// No description provided for @spendingPatterns.
  ///
  /// In en, this message translates to:
  /// **'Spending Patterns'**
  String get spendingPatterns;

  /// No description provided for @peakSpendingDays.
  ///
  /// In en, this message translates to:
  /// **'Peak Spending Days'**
  String get peakSpendingDays;

  /// No description provided for @yearOverYear.
  ///
  /// In en, this message translates to:
  /// **'Year over Year'**
  String get yearOverYear;

  /// No description provided for @forecast.
  ///
  /// In en, this message translates to:
  /// **'Forecast'**
  String get forecast;

  /// No description provided for @predictedSpending.
  ///
  /// In en, this message translates to:
  /// **'Predicted Spending'**
  String get predictedSpending;

  /// No description provided for @categoryDetails.
  ///
  /// In en, this message translates to:
  /// **'Category Details'**
  String get categoryDetails;

  /// No description provided for @averageTransaction.
  ///
  /// In en, this message translates to:
  /// **'Avg Transaction'**
  String get averageTransaction;

  /// No description provided for @transactionCount.
  ///
  /// In en, this message translates to:
  /// **'Transaction Count'**
  String get transactionCount;

  /// No description provided for @biggestTransaction.
  ///
  /// In en, this message translates to:
  /// **'Biggest Transaction'**
  String get biggestTransaction;

  /// No description provided for @last12Months.
  ///
  /// In en, this message translates to:
  /// **'Last 12 Months'**
  String get last12Months;

  /// No description provided for @averageSpendingByDay.
  ///
  /// In en, this message translates to:
  /// **'Average Spending by Day'**
  String get averageSpendingByDay;

  /// No description provided for @mostSpendingOn.
  ///
  /// In en, this message translates to:
  /// **'Most spending on'**
  String get mostSpendingOn;

  /// No description provided for @remaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get remaining;

  /// No description provided for @used.
  ///
  /// In en, this message translates to:
  /// **'Used'**
  String get used;

  /// No description provided for @budgetFor.
  ///
  /// In en, this message translates to:
  /// **'Budget for {category}'**
  String budgetFor(String category);

  /// No description provided for @currentPeriod.
  ///
  /// In en, this message translates to:
  /// **'Current Period'**
  String get currentPeriod;

  /// No description provided for @previousPeriod.
  ///
  /// In en, this message translates to:
  /// **'Previous Period'**
  String get previousPeriod;

  /// No description provided for @approachingBudget.
  ///
  /// In en, this message translates to:
  /// **'Approaching Budget'**
  String get approachingBudget;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get invalidEmail;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordTooShort;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed. Please check your credentials.'**
  String get loginFailed;

  /// No description provided for @registrationFailed.
  ///
  /// In en, this message translates to:
  /// **'Registration failed. Please try again.'**
  String get registrationFailed;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// No description provided for @welcomeMessage.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue'**
  String get welcomeMessage;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @createAccountMessage.
  ///
  /// In en, this message translates to:
  /// **'Sign up to get started'**
  String get createAccountMessage;

  /// No description provided for @signOutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get signOutConfirm;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastName;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optional;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdated;

  /// No description provided for @updateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update profile'**
  String get updateFailed;

  /// No description provided for @passwordChanged.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully'**
  String get passwordChanged;

  /// No description provided for @passwordChangeFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to change password'**
  String get passwordChangeFailed;

  /// No description provided for @currentPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Current password is required'**
  String get currentPasswordRequired;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'tr': return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
