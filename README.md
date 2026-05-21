# Bulocation Mobile

Bulocation mobil uygulaması; QR tabanlı başlangıç, indoor navigation, kurum/yerleşke/bina/kat seçimi, yayınlanmış harita görüntüleme, rota çizimi ve otopark doluluk takibi için geliştirilmiş Flutter istemcisidir.

Uygulamanın ana amacı yalnızca otopark yönetimi değildir. Otopark, indoor navigation deneyiminin önemli modlarından biridir.

## Temel Akışlar

- Oturum açma, kayıt olma, Google ile giriş ve oturum yenileme
- İlk açılış kullanım rehberi
- Ana ekrandan hızlı QR okutma
- QR referansı ile scan context çözme ve ilgili yayınlanmış kat haritasını açma
- Manuel kurum, yerleşke, bina ve kat seçimi
- Harita üzerinde pan, zoom, recenter, rota ve park alanı gösterimi
- Facility-aware alt panel: otopark, hastane, AVM ve diğer bina modları
- SignalR ile canlı park doluluk güncellemeleri

## Gereksinimler

- Flutter 3.41 veya üzeri
- Dart 3.11 veya üzeri
- Android Studio / Xcode platform araçları
- Windows Android build için `JAVA_HOME` değerinin Android Studio JBR/JDK konumuna ayarlanması. Örnek: `C:\Program Files\Android\Android Studio\jbr`
- Çalışan Bulocation API

## Kurulum

```bash
flutter pub get
flutter analyze
flutter test
```

## Çalıştırma

Geliştirme ortamı için:

```bash
flutter run \
  --dart-define=BASE_HOST=http://10.0.2.2:5011 \
  --dart-define=APP_SECRET=local-dev-secret
```

Production veya staging için `BASE_HOST` mutlaka HTTPS olmalıdır:

```bash
flutter run --release \
  --dart-define=BASE_HOST=https://api.bulocation.com \
  --dart-define=APP_SECRET=... \
  --dart-define=GOOGLE_SERVER_CLIENT_ID=...
```

`APP_SECRET` mobil binary içine gömüldüğü için gerçek bir gizli anahtar gibi kabul edilmemelidir. API tarafında JWT, public endpoint sınırları, rate limit ve gerekirse kısa ömürlü QR/SignalR token modeliyle desteklenmelidir.

## Proje Yapısı

```txt
lib/
  app/
    app_session_controller.dart
  core/
    api_client.dart
  models/
    auth_models.dart
    exceptions.dart
    facility_models.dart
    graph_data.dart
  screens/
    app_shell.dart
    home_overview_screen.dart
    home_guide_screen.dart
    home_screen.dart
    login_screen.dart
    register_screen.dart
    profile_screen.dart
    map/
    home/
    auth/
    profile/
  services/
    auth_service.dart
    facility_service.dart
    parking_service.dart
    pathfinding_service.dart
    session_storage.dart
  widgets/
    floor_plan_widget.dart
    embedded_scanner.dart
    bottom_bar.dart
    parking_panel/
    floor_plan/
```

Not: `home_screen.dart` şu an harita ekranını barındırır. İleride dosya adı `map_screen.dart` olarak düzeltilmelidir.

## API Konfigürasyonu

`lib/main.dart` içindeki `AppConfig` şu dart define değerlerini kullanır:

| Değer | Açıklama |
| --- | --- |
| `BASE_HOST` | API ve SignalR host adresi. Örnek: `https://api.bulocation.com` |
| `APP_SECRET` | API gateway/app-secret header değeri. |
| `GOOGLE_SERVER_CLIENT_ID` | Google sign-in backend doğrulaması için server client id. |

Türetilen adresler:

| Adres | Kullanım |
| --- | --- |
| `$BASE_HOST/api` | REST API |
| `$BASE_HOST/hubs/parking` | SignalR parking occupancy hub |

## Platform Notları

Android:

- `applicationId`: `com.bulocation.app`
- Kamera ve internet izinleri tanımlıdır.
- Release signing debug key kullanmaz. Store build öncesi `android/key.properties.example` dosyasını `android/key.properties` olarak kopyalayıp gerçek keystore değerleriyle doldurun.

iOS:

- Display name: `Bulocation`
- Bundle identifier: `com.bulocation.app`
- Kamera kullanım açıklaması tanımlıdır.
- Signing ve Apple Developer Team ayarı Xcode üzerinden ayrıca yapılmalıdır.

## Kalite Kontrolleri

Her anlamlı değişiklikten sonra:

```bash
flutter analyze
flutter test
```

Windows ortamında Gradle doğrudan çalıştırılacaksa:

```powershell
$env:JAVA_HOME='C:\Program Files\Android\Android Studio\jbr'
$env:Path="$env:JAVA_HOME\bin;$env:Path"
```

Release öncesi ayrıca:

```bash
flutter build apk --release \
  --dart-define=BASE_HOST=https://api.bulocation.com \
  --dart-define=APP_SECRET=...

flutter build ios --release \
  --dart-define=BASE_HOST=https://api.bulocation.com \
  --dart-define=APP_SECRET=...
```

## Production Öncesi Kalanlar

- Android release keystore değerlerinin güvenli CI/store ortamında tanımlanması
- iOS signing yapılandırması
- Google sign-in Android/iOS native konfigürasyonu
- QR -> scan context -> published map -> route akışı için integration/widget testleri
- SignalR için production token stratejisi
- Büyük kurum listelerinde ana ekran veri yükleme stratejisinin optimize edilmesi
