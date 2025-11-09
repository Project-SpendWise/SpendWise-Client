/// API Constants - Centralized configuration for all API endpoints and base URLs
class ApiConstants {
  // Base URL - Update this to your backend URL
  static const String baseUrl = 'http://192.168.1.105:5000/api';
  
  // Authentication Endpoints
  static const String authRegister = '/auth/register';
  static const String authLogin = '/auth/login';
  static const String authMe = '/auth/me';
  static const String authChangePassword = '/auth/change-password';
  static const String authRefresh = '/auth/refresh';
  static const String authLogout = '/auth/logout';

  // File Management Endpoints
  static const String filesUpload = '/files/upload';
  static const String filesList = '/files';
  static String filesDetail(String fileId) => '/files/$fileId';
  static String filesDownload(String fileId) => '/files/$fileId/download';
  static String filesDelete(String fileId) => '/files/$fileId';

  // Statement Endpoints
  static const String statementsUpload = '/statements/upload';
  static const String statementsList = '/statements';
  static String statementDetail(String statementId) => '/statements/$statementId';
  static String statementDelete(String statementId) => '/statements/$statementId/delete';

  // Transaction Endpoints
  static const String transactions = '/transactions';
  static const String transactionsSummary = '/transactions/summary';

  // Analytics Endpoints
  static const String analyticsCategories = '/analytics/categories';
  static const String analyticsTrends = '/analytics/trends';
  static const String analyticsInsights = '/analytics/insights';
  static const String analyticsMonthlyTrends = '/analytics/monthly-trends';
  static const String analyticsCategoryTrends = '/analytics/category-trends';
  static const String analyticsWeeklyPatterns = '/analytics/weekly-patterns';
  static const String analyticsYearOverYear = '/analytics/year-over-year';
  static const String analyticsForecast = '/analytics/forecast';

  // Budget Endpoints
  static const String budgets = '/budgets';
  static const String budgetsCompare = '/budgets/compare';
  static String budgetDetail(String budgetId) => '/budgets/$budgetId';
  static String budgetDelete(String budgetId) => '/budgets/$budgetId';

  // Helper method to build full URL
  static String buildUrl(String endpoint) {
    return '$baseUrl$endpoint';
  }
}

