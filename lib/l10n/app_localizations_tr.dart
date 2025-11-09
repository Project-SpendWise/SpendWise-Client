// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appName => 'SpendWise';

  @override
  String get appSlogan => 'Daha akıllı harca. Daha bilgece biriktir.';

  @override
  String get hello => 'Merhaba';

  @override
  String get home => 'Ana Sayfa';

  @override
  String get upload => 'Yükle';

  @override
  String get analytics => 'Analiz';

  @override
  String get profile => 'Profil';

  @override
  String get income => 'Gelir';

  @override
  String get expenses => 'Gider';

  @override
  String get savings => 'Tasarruf';

  @override
  String get recentTransactions => 'Son İşlemler';

  @override
  String get expenseBreakdown => 'Harcama Dağılımı';

  @override
  String get uploadStatement => 'Banka Ekstresi Yükle';

  @override
  String get selectFile => 'Dosya Seç';

  @override
  String get uploadedFiles => 'Yüklenen Dosyalar';

  @override
  String get noFileUploaded => 'Henüz dosya yüklenmedi';

  @override
  String get uploadedFilesDescription => 'Yüklediğiniz PDF\'ler burada görünecek';

  @override
  String get moneyFlow => 'Para Akışı';

  @override
  String get noData => 'Henüz veri yok';

  @override
  String get uploadDataMessage => 'Para akışını görmek için veri yükleyin';

  @override
  String get categoryDistribution => 'Kategori Dağılımı';

  @override
  String get noCategory => 'Henüz kategori yok';

  @override
  String get categoryDescription => 'Harcama kategorileri burada görünecek';

  @override
  String get spendingTrends => 'Harcama Trendleri';

  @override
  String get last7Days => 'Son 7 Gün';

  @override
  String get insights => 'İçgörüler';

  @override
  String get savingsRecommendations => 'Tasarruf Önerileri';

  @override
  String get noInsights => 'Henüz içgörü yok';

  @override
  String get insightsDescription => 'Tasarruf önerileri için veri gerekli';

  @override
  String get user => 'Kullanıcı';

  @override
  String get darkMode => 'Karanlık Mod';

  @override
  String get notifications => 'Bildirimler';

  @override
  String get on => 'Açık';

  @override
  String get off => 'Kapalı';

  @override
  String get system => 'Sistem';

  @override
  String get about => 'Hakkında';

  @override
  String get version => 'Sürüm';

  @override
  String get logout => 'Çıkış Yap';

  @override
  String get language => 'Dil';

  @override
  String get english => 'İngilizce';

  @override
  String get turkish => 'Türkçe';

  @override
  String get today => 'Bugün';

  @override
  String get yesterday => 'Dün';

  @override
  String get loading => 'Yükleniyor...';

  @override
  String get uploading => 'Yükleniyor...';

  @override
  String get processing => 'İşleniyor...';

  @override
  String get success => 'Başarılı';

  @override
  String get error => 'Hata';

  @override
  String get food => 'Gıda';

  @override
  String get transport => 'Ulaşım';

  @override
  String get shopping => 'Alışveriş';

  @override
  String get bills => 'Faturalar';

  @override
  String get entertainment => 'Eğlence';

  @override
  String get health => 'Sağlık';

  @override
  String get education => 'Eğitim';

  @override
  String get other => 'Diğer';

  @override
  String get lowSavingsRate => 'Düşük Tasarruf Oranı';

  @override
  String lowSavingsMessage(String percentage) {
    return 'Gelirinizin %$percentage\'ini tasarruf ediyorsunuz. En az %20 hedeflemelisiniz.';
  }

  @override
  String get excessiveSpending => 'Aşırı Harcama';

  @override
  String get excessiveSpendingMessage => 'Harcamalarınız gelirinizi aşıyor. Bütçe planlaması yapmanızı öneririz.';

  @override
  String get highestSpendingCategory => 'En Yüksek Harcama Kategorisi';

  @override
  String highestSpendingMessage(String category) {
    return '$category kategorisinde en çok harcama yapıyorsunuz. Bu kategorideki harcamalarınızı gözden geçirebilirsiniz.';
  }

  @override
  String get greatJob => 'Harika!';

  @override
  String get greatJobMessage => 'Tasarruf oranınız ideal seviyede. Bu şekilde devam edin!';

  @override
  String get uploadPdfDescription => 'PDF formatındaki banka ekstrelerinizi yükleyin';

  @override
  String get fileSelected => 'Dosya Seçildi';

  @override
  String get processingFile => 'Dosya işleniyor...';

  @override
  String get fileProcessed => 'Dosya başarıyla işlendi';

  @override
  String get thisMonth => 'Bu Ay';

  @override
  String get thisYear => 'Bu Yıl';

  @override
  String get budget => 'Bütçe';

  @override
  String get budgetRemaining => 'Kalan Bütçe';

  @override
  String get budgetExceeded => 'Bütçe Aşıldı';

  @override
  String get monthlyComparison => 'Aylık Karşılaştırma';

  @override
  String get searchTransactions => 'İşlem ara...';

  @override
  String get noTransactionsFound => 'İşlem bulunamadı';

  @override
  String get vsLastMonth => 'Geçen Aya Göre';

  @override
  String get vsLastWeek => 'Geçen Haftaya Göre';

  @override
  String get vsLastYear => 'Geçen Yıla Göre';

  @override
  String get averageDailySpending => 'Günlük Ort.';

  @override
  String get biggestExpense => 'En Büyük';

  @override
  String get totalTransactions => 'İşlemler';

  @override
  String get mostUsedCategory => 'En Çok Kullanılan';

  @override
  String get topCategories => 'En Çok Harcananlar';

  @override
  String get quickStats => 'Hızlı İstatistikler';

  @override
  String get increasedBy => 'Arttı';

  @override
  String get decreasedBy => 'Azaldı';

  @override
  String get monthlyTrends => 'Aylık Trendler';

  @override
  String get categoryTrends => 'Kategori Trendleri';

  @override
  String get weeklyPatterns => 'Haftalık Desenler';

  @override
  String get incomeVsExpenses => 'Gelir vs Gider';

  @override
  String get budgetTracking => 'Bütçe Takibi';

  @override
  String get setBudget => 'Bütçe Belirle';

  @override
  String get budgetVsActual => 'Bütçe vs Gerçek';

  @override
  String get overBudget => 'Bütçe Aşıldı';

  @override
  String get underBudget => 'Bütçe Altında';

  @override
  String get onTrack => 'Hedefte';

  @override
  String get spendingPatterns => 'Harcama Desenleri';

  @override
  String get peakSpendingDays => 'En Çok Harcama Günleri';

  @override
  String get yearOverYear => 'Yıllık Karşılaştırma';

  @override
  String get forecast => 'Tahmin';

  @override
  String get predictedSpending => 'Tahmini Harcama';

  @override
  String get categoryDetails => 'Kategori Detayları';

  @override
  String get averageTransaction => 'Ort. İşlem';

  @override
  String get transactionCount => 'İşlem Sayısı';

  @override
  String get biggestTransaction => 'En Büyük İşlem';

  @override
  String get last12Months => 'Son 12 Ay';

  @override
  String get averageSpendingByDay => 'Güne Göre Ortalama Harcama';

  @override
  String get mostSpendingOn => 'En çok harcama';

  @override
  String get remaining => 'Kalan';

  @override
  String get used => 'Harcanan';

  @override
  String budgetFor(String category) {
    return '$category için bütçe';
  }

  @override
  String get currentPeriod => 'Mevcut Dönem';

  @override
  String get previousPeriod => 'Önceki Dönem';

  @override
  String get approachingBudget => 'Bütçeye Yaklaşıyor';

  @override
  String get login => 'Giriş Yap';

  @override
  String get register => 'Kayıt Ol';

  @override
  String get email => 'E-posta';

  @override
  String get password => 'Şifre';

  @override
  String get name => 'İsim';

  @override
  String get confirmPassword => 'Şifreyi Onayla';

  @override
  String get forgotPassword => 'Şifremi Unuttum?';

  @override
  String get dontHaveAccount => 'Hesabınız yok mu?';

  @override
  String get alreadyHaveAccount => 'Zaten hesabınız var mı?';

  @override
  String get signIn => 'Giriş Yap';

  @override
  String get signUp => 'Kayıt Ol';

  @override
  String get signOut => 'Çıkış Yap';

  @override
  String get invalidEmail => 'Lütfen geçerli bir e-posta girin';

  @override
  String get passwordTooShort => 'Şifre en az 6 karakter olmalıdır';

  @override
  String get passwordsDoNotMatch => 'Şifreler eşleşmiyor';

  @override
  String get loginFailed => 'Giriş başarısız. Lütfen bilgilerinizi kontrol edin.';

  @override
  String get registrationFailed => 'Kayıt başarısız. Lütfen tekrar deneyin.';

  @override
  String get welcomeBack => 'Tekrar Hoş Geldiniz';

  @override
  String get welcomeMessage => 'Devam etmek için giriş yapın';

  @override
  String get createAccount => 'Hesap Oluştur';

  @override
  String get createAccountMessage => 'Başlamak için kayıt olun';

  @override
  String get signOutConfirm => 'Çıkış yapmak istediğinize emin misiniz?';

  @override
  String get cancel => 'İptal';

  @override
  String get username => 'Kullanıcı Adı';

  @override
  String get firstName => 'Ad';

  @override
  String get lastName => 'Soyad';

  @override
  String get optional => 'İsteğe Bağlı';

  @override
  String get editProfile => 'Profili Düzenle';

  @override
  String get changePassword => 'Şifre Değiştir';

  @override
  String get currentPassword => 'Mevcut Şifre';

  @override
  String get newPassword => 'Yeni Şifre';

  @override
  String get save => 'Kaydet';

  @override
  String get profileUpdated => 'Profil başarıyla güncellendi';

  @override
  String get updateFailed => 'Profil güncellenemedi';

  @override
  String get passwordChanged => 'Şifre başarıyla değiştirildi';

  @override
  String get passwordChangeFailed => 'Şifre değiştirilemedi';

  @override
  String get currentPasswordRequired => 'Mevcut şifre gereklidir';
}
