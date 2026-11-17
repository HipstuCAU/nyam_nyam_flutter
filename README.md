# 중대한학식 — Android

이 Flutter 프로젝트는 Android 앱만 유지보수합니다. iOS 앱은 별도 네이티브 프로젝트에서 관리하며, 이 저장소의 `ios/`는 업데이트·검증 대상에서 제외합니다.

## 개발 환경

- Flutter **3.50.0 stable** / Dart **3.14.0** (`.fvmrc`)
- JDK **21** (Java/Kotlin 컴파일 대상은 17)
- Android SDK **36**, 최소 지원 **API 24 / Android 7.0**
- Android Gradle Plugin **9.3.1**, Gradle **9.5.0**, Kotlin 플러그인 **2.4.20**: Flutter 3.50 기본 템플릿 조합
- NDK는 `flutter.ndkVersion`을 따릅니다.

FVM을 사용한다면 `fvm install && fvm use` 후 아래 명령 앞에 `fvm`을 붙입니다. 직접 설치한 경우 해당 Flutter SDK의 `bin`을 PATH에 추가합니다.

`android/local.properties`는 각 컴퓨터의 `sdk.dir`, `flutter.sdk` 경로로 설정합니다. Android Studio의 내장 JDK를 사용한다면 `JAVA_HOME`을 해당 JDK 경로로 지정합니다.

루트 `.env`에 광고 ID를 준비합니다.

```dotenv
TEST_BANNER_AD_ID=ca-app-pub-3940256099942544/6300978111
RELEASE_BANNER_AD_ID=<운영 배너 광고 단위 ID>
```

Firebase 설정은 `android/app/google-services.json`을 사용합니다. 릴리스 빌드에는 기존 배포 키와 `android/key.properties`의 `storeFile`, `storePassword`, `keyAlias`, `keyPassword`가 필요합니다.

## 검증과 빌드

```sh
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
flutter build appbundle --release
```

실기기에서는 식단 조회, 배너 광고, 캠퍼스·식당 순서 저장, 포털 링크, 문의 메일 실행을 확인합니다. 릴리스 빌드는 운영 서명 키가 있는 환경에서 검증합니다.

## 라이브러리 관리

`pubspec.yaml`과 `pubspec.lock`을 함께 커밋합니다. `dependency_overrides`로 충돌을 우회하지 않습니다.

```sh
flutter pub outdated
flutter pub upgrade
# 메이저 업데이트는 변경 기록을 확인한 뒤 실행
flutter pub upgrade --major-versions
```

Firebase Core와 Firestore는 함께 업데이트합니다. 네이티브 Firebase Analytics도 `firebase_core`가 선택한 Android BoM 버전을 사용합니다. Gradle·AGP·Kotlin은 Flutter의 지원 조합을 확인하고 함께 변경합니다.

`fluttertoast` 등 일부 플러그인은 아직 Kotlin Gradle Plugin을 적용하므로 `android.builtInKotlin=false`, `android.newDsl=false` 호환 설정을 유지합니다. 전체 플러그인이 대응한 뒤 [Flutter 공식 마이그레이션 절차](https://docs.flutter.dev/release/breaking-changes/migrate-to-built-in-kotlin/for-app-developers)에 따라 전환합니다.

Dependabot 설정은 Pub 및 Android Gradle 업데이트를 매월 확인합니다. GitHub에 반영된 뒤 업데이트 PR에서 위 검증을 수행합니다. 자동 병합은 설정하지 않습니다.

2026-11-17 기준 직접 사용하는 패키지를 최신 안정 버전으로 업데이트했습니다. Flutter 3.50의 UI 분리에 맞춰 `material_ui`와 `cupertino_ui`를 사용합니다. `scroll_to_index`는 최신 버전인 3.0.1을 유지합니다. SDK가 고정한 전이 의존성은 강제로 올리지 않습니다.

참고: [Flutter SDK archive](https://docs.flutter.dev/install/archive), [Flutter 3.50 Android 기본 버전](https://github.com/flutter/flutter/blob/3.50.0/packages/flutter_tools/lib/src/android/gradle_utils.dart), [Google Mobile Ads 변경 기록](https://pub.dev/packages/google_mobile_ads/changelog), [Firebase Core 변경 기록](https://pub.dev/packages/firebase_core/changelog).

## 검증 기록 — 2026-11-17

- `flutter pub outdated`: 직접·개발 의존성 모두 최신. SDK 고정 전이 의존성 2개는 유지.
- `flutter test`: 캠퍼스·식당 순서 읽기, 캠퍼스 변경 저장, 드래그 재정렬 저장 3개 통과.
- `flutter analyze`: 오류 0개. 기존 경고 9개와 정보 14개는 유지.
- 디버그 APK 빌드, `.env` 자산 포함, 16KB ZIP 정렬 검사 통과.
- Android 16 / API 36 에뮬레이터에서 앱 시작, Firestore 식단 조회, 테스트 배너 표시 확인.
- `cd android && ./gradlew :app:minifyReleaseWithR8`: 릴리스 컴파일·R8 최적화 통과. 운영 키가 없어 서명된 APK/AAB 생성은 검증하지 않음.
