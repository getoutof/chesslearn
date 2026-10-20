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
| `pubspec.yaml` | Имя, версия приложения (`version: X.Y.Z+N`), **версия Flutter** (`environment.flutter`), `default-flavor`, зависимости, ассеты | мы | да | нет |
| `pubspec.lock` | Точные версии зависимостей | генерируется `flutter pub get`, **хранится в git** | только через `flutter pub` | нет |
| `analysis_options.yaml` | Правила анализатора и линтера: `flutter_lints` + `strict-casts`, `strict-raw-types` и доп. правила | мы | да | нет |
| `.metadata` | Ревизия Flutter, из которой создан проект; нужна `flutter migrate` | Flutter | **нет** | нет |
| `.gitignore` | Что не попадает в git | мы (основа от Flutter) | да | нет |
| `.github/workflows/ci.yml` | CI: проверки (формат, анализ, тесты, язык комментариев), сборка Android (dev) и iOS (dev, prod). Имена jobs — обязательные проверки для `main`: переименовали job — обновите защиту ветки | мы | да | собирает оба |
| `tool/check_comments.dart` | Проверка, что комментарии в нашем коде на русском; списки проверяемых путей (`ownPaths`, `mixedPaths`) — в нём | мы | да | нет |
| `tool/remote.env.example` | Пример настроек подключения к билд-машине | мы | да | нет |
| `tool/remote.env` | Ваши настройки подключения к билд-машине | мы, **не в git** | да | — |

## Android (`android/`)

| Файл | Зачем | Кто управляет | Менять? | dev/prod |
|---|---|---|---|---|
| `app/build.gradle.kts` | **Главный файл Android:** `applicationId`, версии SDK, **flavors dev/prod**, название, подпись | мы | да, внимательно | **да**: id, название, подпись |
| `build.gradle.kts` | Репозитории, общая папка сборки `build/` | Flutter | редко | нет |
| `settings.gradle.kts` | Версии Android Gradle Plugin и Kotlin, подключение Flutter SDK | Flutter | при обновлении Flutter | нет |
| `gradle.properties` | Память для Gradle (`-Xmx8G`), AndroidX, флаги совместимости | мы | да | нет |
| `gradle/wrapper/gradle-wrapper.properties` | Версия Gradle | Flutter | при обновлении Flutter | нет |
| `app/src/main/AndroidManifest.xml` | Разрешения, главная Activity, ориентация; название — `@string/app_name` из flavor | мы | да | нет |
| `app/src/debug/AndroidManifest.xml`, `profile/…` | Разрешение `INTERNET` для hot reload — **только** в debug/profile | Flutter | нет | нет |
| `app/src/main/res/values*/styles.xml`, `drawable*/launch_background.xml` | Тема и фон при запуске | мы | да (сплэш) | нет |
| `app/src/main/res/mipmap-*/ic_launcher.png` | Иконка | мы | да (иконка) | можно |
| `app/src/main/kotlin/…/MainActivity.kt` | Точка входа Android | Flutter | только для нативного кода | нет |
| `local.properties` | Путь к Flutter SDK и Android SDK на машине | генерируется | — | — |
| `key.properties`, `*.jks`, `*.keystore` | Ключ подписи релиза | мы, **никогда не в git** | — | только prod |

## iOS (`ios/`)

| Файл | Зачем | Кто управляет | Менять? | dev/prod |
|---|---|---|---|---|
| `Runner.xcodeproj/project.pbxproj` | **Главный файл iOS:** конфигурации `Debug/Release/Profile-{dev,prod}`, bundle id и `APP_DISPLAY_NAME` для каждой, минимальная iOS, устройства, подпись | мы (через Xcode) | да, внимательно | **да**: bundle id, название, подпись |
| `Runner/Info.plist` | Ориентации экрана, разрешения; название — `$(APP_DISPLAY_NAME)` из конфигурации | мы | да | нет |
| `Runner.xcodeproj/xcshareddata/xcschemes/*.xcscheme` | Схемы сборки: `dev`, `prod` (их использует `--flavor`), `Runner` (от шаблона) | мы (через Xcode) | при добавлении flavors | да |
| `Flutter/Debug.xcconfig`, `Flutter/Release.xcconfig` | Подключают сгенерированный `Generated.xcconfig` | Flutter | нет | нет |
| `Flutter/AppFrameworkInfo.plist` | Метаданные Flutter-фреймворка | Flutter | нет | нет |
| `Runner.xcworkspace/*`, `*/xcshareddata/*.plist`, `*.xcsettings` | Служебные файлы Xcode | Flutter / Xcode | нет | нет |
| `Runner/AppDelegate.swift`, `SceneDelegate.swift`, `Runner-Bridging-Header.h` | Точка входа iOS | Flutter | только для нативного кода | нет |
| `Runner/Base.lproj/*.storyboard` | Экран запуска и главный экран | Flutter | экран запуска — да | нет |
| `Runner/Assets.xcassets/*` | Иконка и картинка запуска | мы | да (иконка) | можно |
| `RunnerTests/RunnerTests.swift` | Нативные iOS-тесты | мы | при необходимости | нет |
| `Flutter/Generated.xcconfig`, `Podfile.lock`, `Pods/` | Сгенерировано Flutter / CocoaPods | генерируется | — | — |

## Flavors: dev и prod

| | dev | prod |
|---|---|---|
| Назначение | Разработка, тестовые сборки | Сторы |
| Android `applicationId` | `io.github.getoutof.chesslearn.dev` | `io.github.getoutof.chesslearn` |
| iOS bundle id | `io.github.getoutof.chesslearn.dev` | `io.github.getoutof.chesslearn` |
| Название | ChessLearn Dev | ChessLearn |
| Подпись Android | debug-ключ (и для release) | release-ключ из `android/key.properties` |
| Подпись iOS | автоматическая (Xcode) | автоматическая (Xcode), команда разработчика — #23 |

Разные id — dev и prod ставятся на один телефон рядом.

```bash
flutter run                              # dev (default-flavor в pubspec.yaml)
flutter build apk --release              # dev, подписан debug-ключом
flutter build apk --release --flavor prod
flutter build appbundle --flavor prod    # для Google Play
flutter build ipa --flavor prod          # для App Store (нужен Mac)
```

Во время работы приложения flavor доступен как `appFlavor` (`package:flutter/services.dart`).

**Где задаётся:**

- Android — `productFlavors` в `android/app/build.gradle.kts`;
- iOS — конфигурации `*-dev` / `*-prod` в `project.pbxproj` (`PRODUCT_BUNDLE_IDENTIFIER`, `APP_DISPLAY_NAME`) и схемы `dev.xcscheme` / `prod.xcscheme`;
- конфигурации без суффикса (`Debug`/`Release`/`Profile`) и схема `Runner` остались от шаблона: используются только при сборке из Xcode без flavor.

> Когда появятся плагины с нативным кодом (например, Stockfish), Flutter создаст `ios/Podfile`. В нём нужно сопоставить
> конфигурации `Debug-*` → `:debug`, `Profile-*`/`Release-*` → `:release`.

### Ключ подписи Android (prod)

Сборка `prod` в release **падает**, если нет `android/key.properties`, — чтобы боевая сборка никогда не ушла с debug-ключом.

`android/key.properties` (в `.gitignore`, в git не хранится):

```properties
storePassword=...
keyPassword=...
keyAlias=upload
storeFile=/абсолютный/путь/к/upload-keystore.jks
```

Keystore и пароли хранятся вне репозитория, с резервной копией: потеря ключа — потеря возможности обновлять приложение
(с Play App Signing upload-ключ можно сбросить через поддержку Google).

## Ключевые значения

| Параметр | Значение | Где |
|---|---|---|
| Android `applicationId` / `namespace` | `io.github.getoutof.chesslearn` (+ `.dev` для dev) | `android/app/build.gradle.kts` |
| iOS bundle id | `io.github.getoutof.chesslearn` (+ `.dev` для dev) | `project.pbxproj` → `PRODUCT_BUNDLE_IDENTIFIER` |
| Flutter | 3.47.7 | `pubspec.yaml` → `environment.flutter` |
| Устройства iOS | только iPhone | `TARGETED_DEVICE_FAMILY = 1` |
| Ориентация | только портрет | `AndroidManifest.xml` → `screenOrientation`, `Info.plist` → `UISupportedInterfaceOrientations` |
| Версия | из `pubspec.yaml` (`version`) → `versionName`/`versionCode`, `CFBundleShortVersionString`/`CFBundleVersion` | |
| Android minSdk / targetSdk / compileSdk | 24 / 36 / 36 (берутся из Flutter) | `flutter.minSdkVersion` и т.д. |
| Android NDK | 28.2.13676358 (из Flutter) | `flutter.ndkVersion` |
| iOS минимальная версия | 15.0 | `IPHONEOS_DEPLOYMENT_TARGET` |
| Java / Kotlin JVM target | 17 | `android/app/build.gradle.kts` |
| AGP / Kotlin / Gradle | 9.1.0 / 2.4.0 / 9.3.1 | `settings.gradle.kts`, `gradle-wrapper.properties` |

> **Важно:** `applicationId` и bundle id после публикации в сторах менять **нельзя** — это будет другое приложение.

## Результаты аудита заготовки

Что было сразу после `flutter create` (Flutter 3.47.7) и что сделано.

| # | Проблема | Риск | Статус |
|---|---|---|---|
| 1 | Release подписывается **debug-ключом** | Google Play не примет; обновление другим ключом не встанет | ✅ prod — только release-ключ, без него сборка падает. Сам ключ — #28 |
| 2 | Название: Android `chesslearn`, iOS `Chesslearn` | Разные имена на платформах | ✅ ChessLearn / ChessLearn Dev |
| 3 | Нет разделения dev/prod | Тестовую и боевую сборки нельзя поставить рядом | ✅ flavors dev/prod |
| 4 | Разрешены все ориентации | Интерфейс рассчитан на портрет | ✅ только портрет |
| 5 | iOS для iPhone и iPad | Скриншоты и вёрстка под iPad | ✅ только iPhone |
| 6 | Версия Flutter не зафиксирована | Разные машины соберут разными версиями | ✅ `environment.flutter` в `pubspec.yaml` |
| 7 | В release-манифесте нет `INTERNET` | Понадобится для онлайн-функций | ⏳ добавить вместе с первой онлайн-функцией (#20, #17) |
| 8 | Gradle просит 8 ГБ памяти (`-Xmx8G`) | Не соберётся на слабой машине | ⏳ оставлено: билд-машина и CI справляются |
