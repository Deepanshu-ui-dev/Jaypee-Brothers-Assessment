class AppStrings {
  AppStrings._();

  static const String appName = 'FinTrack';
  static const String tagline = 'Your personal finance companion';

  // Auth
  static const String login = 'Sign In';
  static const String register = 'Create Account';
  static const String forgotPassword = 'Forgot Password';
  static const String logout = 'Sign Out';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm Password';
  static const String name = 'Full Name';
  static const String sendResetLink = 'Send Reset Link';
  static const String resetEmailSent = 'Password reset email sent!';
  static const String dontHaveAccount = "Don't have an account? ";
  static const String alreadyHaveAccount = 'Already have an account? ';
  static const String signUp = 'Sign Up';
  static const String signIn = 'Sign In';

  // Navigation
  static const String dashboard = 'Dashboard';
  static const String transactions = 'Transactions';
  static const String analytics = 'Analytics';
  static const String categories = 'Categories';
  static const String settings = 'Settings';

  // Transactions
  static const String addTransaction = 'Add Transaction';
  static const String editTransaction = 'Edit Transaction';
  static const String deleteTransaction = 'Delete Transaction';
  static const String income = 'Income';
  static const String expense = 'Expense';
  static const String amount = 'Amount';
  static const String category = 'Category';
  static const String date = 'Date';
  static const String note = 'Note (optional)';
  static const String save = 'Save Transaction';
  static const String cancel = 'Cancel';
  static const String delete = 'Delete';

  // Dashboard
  static const String totalBalance = 'Total Balance';
  static const String recentTransactions = 'Recent Transactions';
  static const String spendingByCategory = 'Spending by Category';
  static const String noTransactions = 'No transactions yet';
  static const String addFirst = 'Add your first transaction to get started';

  // Analytics
  static const String monthlyOverview = 'Monthly Overview';
  static const String categoryBreakdown = 'Category Breakdown';
  static const String saved = 'Saved';
  static const String savingsRate = 'Savings Rate';

  // Settings
  static const String profile = 'Profile';
  static const String preferences = 'Preferences';
  static const String darkMode = 'Dark Mode';
  static const String dailyReminder = 'Daily Reminder';
  static const String currency = 'Currency';
  static const String data = 'Data';
  static const String exportCsv = 'Export CSV';
  static const String biometricLock = 'Biometric Lock';
  static const String dangerZone = 'Account';

  // Date groups
  static const String today = 'TODAY';
  static const String yesterday = 'YESTERDAY';

  // Validation
  static const String fieldRequired = 'This field is required';
  static const String invalidEmail = 'Enter a valid email address';
  static const String passwordTooShort = 'Password must be at least 6 characters';
  static const String passwordsDoNotMatch = 'Passwords do not match';
  static const String invalidAmount = 'Enter a valid amount greater than 0';

  // Error
  static const String genericError = 'Something went wrong. Please try again.';

  // Currency
  static const String currencySymbol = '₹';
}
