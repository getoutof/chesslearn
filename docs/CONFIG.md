# Карта конфигурации

Что за файлы лежат в проекте, кто ими управляет и можно ли их менять.
Обновляйте этот документ в том же PR, в котором меняете конфиг.

**Кто управляет:**

- **мы** — файл наш, меняем осознанно, каждое изменение — в ревью;
- **Flutter** — создан `flutter create`, обновляется через `flutter upgrade` / `flutter create .`; вручную не правим;
- **генерируется** — появляется при сборке, в git не хранится.

**dev/prod** — отличается ли значение между тестовой и боевой сборкой.

## Проект (Dart / Flutter)

| Файл | Зачем | Кто управляет | Менять? | dev/prod |
|---|---|---|---|---|
| `pubspec.yaml` | Имя, версия приложения (`version: X.Y.Z+N`), зависимости, ассеты | мы | да | нет |
| `pubspec.lock` | Точные версии зависимостей | генерируется `flutter pub get`, **хранится в git** | только через `flutter pub` | нет |
| `analysis_options.yaml` | Правила анализатора и линтера | мы | да | нет |
| `.metadata` | Ревизия Flutter, из которой создан проект; нужна `flutter migrate` | Flutter | **нет** | нет |
| `.gitignore` | Что не попадает в git | мы (основа от Flutter) | да | нет |

## Android (`android/`)

| Файл | Зачем | Кто управляет | Менять? | dev/prod |
|---|---|---|---|---|
| `app/build.gradle.kts` | **Главный файл Android:** `applicationId`, версии SDK, подпись, типы сборок | мы | да, внимательно | **да**: id, подпись |
| `build.gradle.kts` | Репозитории, общая папка сборки `build/` | Flutter | редко | нет |
| `settings.gradle.kts` | Версии Android Gradle Plugin и Kotlin, подключение Flutter SDK | Flutter | при обновлении Flutter | нет |
| `gradle.properties` | Память для Gradle (`-Xmx8G`), AndroidX, флаги совместимости | мы | да | нет |
| `gradle/wrapper/gradle-wrapper.properties` | Версия Gradle | Flutter | при обновлении Flutter | нет |
| `app/src/main/AndroidManifest.xml` | Название приложения, разрешения, главная Activity | мы | да | **да**: название |
| `app/src/debug/AndroidManifest.xml`, `profile/…` | Разрешение `INTERNET` для hot reload — **только** в debug/profile | Flutter | нет | нет |
| `app/src/main/res/values*/styles.xml`, `drawable*/launch_background.xml` | Тема и фон при запуске | мы | да (сплэш) | нет |
| `app/src/main/res/mipmap-*/ic_launcher.png` | Иконка | мы | да (иконка) | можно |
| `app/src/main/kotlin/…/MainActivity.kt` | Точка входа Android | Flutter | только для нативного кода | нет |
| `local.properties` | Путь к Flutter SDK и Android SDK на машине | генерируется | — | — |
| `key.properties`, `*.jks`, `*.keystore` | Ключ подписи релиза | мы, **никогда не в git** | — | только prod |

## iOS (`ios/`)

| Файл | Зачем | Кто управляет | Менять? | dev/prod |
|---|---|---|---|---|
| `Runner.xcodeproj/project.pbxproj` | **Главный файл iOS:** bundle id, минимальная iOS, устройства, конфигурации сборки, подпись | мы (через Xcode) | да, внимательно | **да**: bundle id, подпись |
| `Runner/Info.plist` | Название, ориентации экрана, разрешения | мы | да | **да**: название |
| `Runner.xcodeproj/xcshareddata/xcschemes/*.xcscheme` | Схемы сборки (какая конфигурация для Run/Archive) | мы (через Xcode) | при добавлении flavors | да |
| `Flutter/Debug.xcconfig`, `Flutter/Release.xcconfig` | Подключают сгенерированный `Generated.xcconfig` | Flutter | нет | нет |
| `Flutter/AppFrameworkInfo.plist` | Метаданные Flutter-фреймворка | Flutter | нет | нет |
| `Runner.xcworkspace/*`, `*/xcshareddata/*.plist`, `*.xcsettings` | Служебные файлы Xcode | Flutter / Xcode | нет | нет |
| `Runner/AppDelegate.swift`, `SceneDelegate.swift`, `Runner-Bridging-Header.h` | Точка входа iOS | Flutter | только для нативного кода | нет |
| `Runner/Base.lproj/*.storyboard` | Экран запуска и главный экран | Flutter | экран запуска — да | нет |
| `Runner/Assets.xcassets/*` | Иконка и картинка запуска | мы | да (иконка) | можно |
| `RunnerTests/RunnerTests.swift` | Нативные iOS-тесты | мы | при необходимости | нет |
| `Flutter/Generated.xcconfig`, `Podfile.lock`, `Pods/` | Сгенерировано Flutter / CocoaPods | генерируется | — | — |

## Ключевые значения

| Параметр | Значение | Где |
|---|---|---|
| Android `applicationId` / `namespace` | `io.github.getoutof.chesslearn` | `android/app/build.gradle.kts` |
| iOS bundle id | `io.github.getoutof.chesslearn` | `project.pbxproj` → `PRODUCT_BUNDLE_IDENTIFIER` |
| Версия | из `pubspec.yaml` (`version`) → `versionName`/`versionCode`, `CFBundleShortVersionString`/`CFBundleVersion` | |
| Android minSdk / targetSdk / compileSdk | 24 / 36 / 36 (берутся из Flutter) | `flutter.minSdkVersion` и т.д. |
| Android NDK | 28.2.13676358 (из Flutter) | `flutter.ndkVersion` |
| iOS минимальная версия | 15.0 | `IPHONEOS_DEPLOYMENT_TARGET` |
| Java / Kotlin JVM target | 17 | `android/app/build.gradle.kts` |
| AGP / Kotlin / Gradle | 9.1.0 / 2.4.0 / 9.3.1 | `settings.gradle.kts`, `gradle-wrapper.properties` |

> **Важно:** `applicationId` и bundle id после публикации в сторах менять **нельзя** — это будет другое приложение.

## Результаты аудита заготовки

Состояние сразу после `flutter create` (Flutter 3.47.7). Исправляется в следующем PR.

| # | Проблема | Риск |
|---|---|---|
| 1 | Release подписывается **debug-ключом** (`signingConfig = signingConfigs.getByName("debug")`) | Google Play не примет; обновление другим ключом не встанет |
| 2 | Название: Android `chesslearn`, iOS `Chesslearn` | Некрасиво в лаунчере, разные имена на платформах |
| 3 | Нет разделения dev/prod | Тестовую и боевую сборки нельзя поставить рядом |
| 4 | Разрешены все ориентации | Шахматный интерфейс рассчитан на портрет |
| 5 | iOS собирается для iPhone и iPad (`TARGETED_DEVICE_FAMILY = "1,2"`) | App Store потребует скриншоты и вёрстку под iPad |
| 6 | Версия Flutter нигде не зафиксирована в проекте | Разные машины соберут разными версиями |
| 7 | В release-манифесте нет `INTERNET` | Понадобится для онлайн-функций (#20, #17) |
