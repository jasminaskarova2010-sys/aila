# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Aila — a Flutter learning app for children with ASD (autism spectrum disorder) and speech delay. It combines short interactive mini-games (social stories, sequencing, choice tasks), a PECS-style communication board, a visual "journey" map, a wardrobe/rewards system, and a star-currency economy. UI text is localized (RU/EN/KK) and all screens follow a consistent pastel, rounded, low-stimulation visual style intentionally chosen for ASD-friendliness (no flashing elements, no harsh colors, no decorative visual noise inside learning content).

This is not a licensed/official PECS implementation — avoid calling it that in UI or docs; it is "PECS-style" communication cards.

## Принципы продукта

Работа идёт по ТЗ MVP: [docs/TZ_AILA_MVP.md](docs/TZ_AILA_MVP.md) — строго по одному этапу, план показывается владелице и выполняется только после ответа «делай». Владелица не программист: отчёты по-русски, простыми словами. В конце этапа — `flutter analyze lib/` без ошибок, коммит `Этап N: <кратко>`, отчёт «что сделано / как проверить / что осталось». Принципы ниже действуют на всех этапах:

| # | Принцип | В коде |
| --- | --- | --- |
| П1 | Ребёнок начинает общение сам | Нет голосовых/мигающих подсказок «нажми сюда», нет торопящих таймеров |
| П2 | На каждое сообщение отвечает взрослый | После озвучки фразы — крупная подсказка для взрослого на 2–3 с |
| П3 | Речь поощряется, но не требуется | Ничего не блокируется, если ребёнок молчит |
| П4 | Предсказуемость | Карточки не меняют место сами, никаких случайных перестановок на доске |
| П5 | Спокойная обратная связь | Без красного и звуков «неправильно»; на доске не бывает ошибок |
| П6 | Безопасность ребёнка | Настройки, покупки, ссылки и журнал — только за PIN родителя |
| П7 | Приватность | Все данные только на устройстве, ничего не отправляется в сеть |
| П8 | Работа без интернета | Картинки, озвучка и контент хранятся локально |
| П9 | Торговая марка | Слово «PECS» не используется в интерфейсе: «Доска общения», «Карточки» |
| П10 | Без emoji | Ни в учебном контенте, ни на карточках (см. Visual content policy ниже) |
| П11 | Карточки по лицензии | Основной набор выбрала владелица: Mulberry Symbols (CC BY-SA 4.0), в ТЗ был ARASAAC. Слова, которых нет в Mulberry, — из ARASAAC (CC BY-NC-SA, некоммерческое): без платы/подписок/рекламы, атрибуция обязательна. Набор подключается через один слой `PictogramRepository`, настройка `kPictogramSet` |
| П12 | Тихий визуальный стиль | Пастельная палитра, скруглённые формы, без мигания |

## Commands

```bash
flutter pub get             # install dependencies after editing pubspec.yaml
flutter analyze lib/        # static analysis — run after every change, must be clean (infos like deprecated withOpacity are pre-existing and OK)
flutter run -d macos        # run on macOS desktop (primary dev target used in this repo)
flutter devices             # list available run targets
flutter build apk --release # тестовая сборка для Android: build/app/outputs/flutter-apk/app-release.apk
flutter test                # widget/unit tests in test/, по файлу на этап (stage1_test.dart … stage5_test.dart, extras_test.dart)
```

There is no CI config. `flutter_tts` has no test implementation — tests that open screens using TTS mock the `flutter_tts` MethodChannel.

Android SDK стоит в `~/Library/Android/sdk`, JDK 17 в `~/Library/Java/JavaVirtualMachines`, эмулятор `aila_test`. Файл для Android подписан служебным ключом `~/.android/debug.keystore`: для пилота можно, для Google Play нужны свой ключ и идентификатор вместо `com.example.aila_app`. Аудит — `docs/AUDIT.md`, инструкция для семей — `docs/PILOT_GUIDE.md`, шаги для iPhone — `docs/IOS_TESTFLIGHT.md`.

**Android:** в манифесте нет разрешения INTERNET и стоит `allowBackup="false"`, чтобы данные не уходили в облако (П7), а `TTS_SERVICE` в `<queries>` нужен озвучке на Android 11+. Не убирать.

**Озвучка:** `flutter_tts` на macOS падает, если начать фразу раньше `awaitSpeakCompletion(true)`. Говорить только через `BoardSpeech`: он ждёт настройки. Автотесты этого не поймают, для проверки нужен запуск на настоящем устройстве.

### Running the app during development

This repo is developed/tested primarily via `flutter run -d macos`, backgrounded with output piped to a log file, then polled until `Built build/...` or `BUILD FAILED` appears, e.g.:

```bash
flutter run -d macos 2>&1 | tee /tmp/flutter_run.log &
# poll for "Built build" / "BUILD FAILED" / "error:" in the log, then verify the process is alive
pgrep -x "aila_app"
```

To restart after code changes, kill the running binary first: `pkill -x "aila_app"`, then re-run. Hot reload/restart via the `flutter run` keypress interface also works if the process is still attached to a terminal.

macOS entitlements note: `macos/Runner/*.entitlements` have `com.apple.security.app-sandbox` **disabled**. This was originally done for Firebase Auth's Keychain access (Firebase has since been removed) and because no paid Apple Developer Team signing identity is configured. Do not re-enable sandboxing or add `keychain-access-groups`/`com.apple.developer.applesignin` entitlements without a real signing team, or the build will fail with "has entitlements that require signing with a development certificate."

## Architecture

### Navigation shell

`main.dart` loads `AppState` from disk (`await AppState.load()`) before `runApp`, then wraps the app in two app-wide `InheritedNotifier` scopes — `AppLocaleScope` (current language) and `AppStateScope` (profiles/stars/outfits/settings/PIN). `_MyAppState` listens to `AppState` and keeps the UI language equal to the active child profile's language. The start screen depends on saved state: no profile → `OnboardingScreen` → `ProfileFormScreen(firstRun: true)` → `PinSetupScreen` → `MainScreen`; profile but no PIN → `PinSetupScreen`; otherwise `MainScreen`.

There is **no account/login, no Firebase, no network** (TZ П7, "Что НЕ входит в MVP"): email/password screens, `firebase_*`, `google_sign_in`, `sign_in_with_apple` were removed in stage 1. Don't reintroduce them.

**Parent PIN gate (`lib/parent/pin_screens.dart`)**: every adult-only screen (settings and anything reachable only from it: profiles, language, info, support contacts; later the parent section, links, journal) must be opened via `openParentArea(context, builder)`, never a bare `Navigator.push`. It shows `PinEntryScreen` and replaces it with the target on the correct PIN. Forgotten PIN → a random `a × b` multiplication challenge → `PinSetupScreen(isReset: true)` (protection from the child, not from an adult). `lib/parent/profile_form_screen.dart` creates/edits child profiles (name optional, age 2–12, language).

**Айла на главном экране** (`lib/widgets/aila_hello.dart`): анимация из видео владелицы с убранным фоном, `assets/aila_hello.png` (APNG, 63 кадра). Проигрывается один раз при открытии и по нажатию, постоянного движения нет (П12). Новое видео на белом фоне превращается в такой файл скриптом `tool/cutout_video.swift` (инструкция в его начале); `ffmpeg` на этом Mac нет.

`MainScreen` hosts the bottom nav with an `IndexedStack` of three tabs: `HomeTab`, `JourneyTab`, `WardrobeScreen`.

### Global state (`lib/state/app_state.dart`)

`AppState` (a `ChangeNotifier` exposed via `AppStateScope.of(context)`) is the single source of truth. It holds a list of `ChildProfile`s plus the active profile id, the parent PIN and device-wide settings (sound/music/vibration). **Per profile**: name, age, language, stars, owned/equipped outfits, completed game indices — getters like `stars`/`isOwned`/`isGameCompleted` read the active profile. Everything is saved on-device as one JSON blob in `shared_preferences` (key `aila_state_v1`) on every mutation via `_changed()`; add new persisted fields to both `toJson`/`fromJson` (with defaults, so old saves still load).

`deleteProfile(id)` удаляет профиль и его журнал; файлы карточек родителя удаляет экран настроек через `ParentMedia.deleteFiles`. Если профилей не осталось, приложение возвращается к приветствию.

Stars are honest: `completeGame(index, reward)` awards stars only on the **first** completion of a step **за день** and returns whether it did; replays the same day give nothing. «Путешествие дня» начинается заново каждый день (`journeyDate`, часы `AppState.clock` подменяются в тестах). Лимит игр в день (`gameLimitMinutes`, 0 — без лимита) считает время в `GamesFlowScreen`; после лимита — `GameLimitScreen`, начатое задание не обрывается, доска общения не ограничивается. `GamesFlowScreen` calls it with `kStarsPerGame` (50) and shows the "+50" snackbar only when stars were actually awarded.

### Localization (`lib/l10n/`)

Hand-rolled, not `flutter gen-l10n`/ARB-based. `AppLanguage` enum (ru/en/kk) + `LocaleController` (ChangeNotifier) live in `app_language.dart`. All user-facing strings are getters/methods on the `S` class in `strings.dart`, selected via `S.of(context)` which reads the current `AppLanguage` from `AppLocaleScope`. When adding UI text, add a new getter to `S` with all three language branches rather than hardcoding strings in widgets.

### Games (`lib/games/`)

`game_models.dart` defines `GameStep` (one config class for all kinds: `choice`, `order`, `categorize`, `speak`, `findPicture`, `buildPhrase`) and `buildGameSteps(S, BoardModel)` / `gameStepsFor(context)`: задания дня собираются под язык и профиль. Новых констант с текстами заданий не заводить: все тексты через `S`. `GameStep.id` — постоянный номер задания, по нему хранится прохождение (`completeGame(id)`), порядок и номер на экране (`index`) могут меняться. `GamesFlowScreen` идёт по заданиям, показывает перерыв (`BreakScreen`, таймера нет) после `breakAfterTasks` заданий (3–5, настройка родителя) и держит одну `BoardSpeech` на все экраны: озвучка на языке профиля, без голоса — сообщение родителю. Все экраны построены на общем `GameShell`. `journey_titles_sheet.dart` lets the user jump to any step via `GamesFlowScreen(startIndex: i)`, где `i` — позиция в списке для текущего профиля.

**Звук в играх** (`game_audio.dart`): спокойная музыка, пока открыты игры, мягкий звук и лёгкая вибрация в момент верного ответа (панель «Молодец!» в `GameShell`). Каждое — своим переключателем в настройках. Звуки собраны скриптом `tool/make_sounds.py` (лицензий нет), в тестах `GameAudio.enabled = false` (`test/flutter_test_config.dart`). Айла хвалит по-разному по номеру задания (`_AilaPraise`). Задание «Куда смотрит Айла?» убрано по просьбе владелицы.

**Перерыв** (`break_screen.dart`): ребёнок выбирает вкусняшку из шести карточек (еда и напитки, которые родитель не скрыл; сначала мороженое, печенье, яблоко, банан, сок, молоко), ему говорят «Покажи родителям: это твоя награда!». Всё на экране озвучено через общую `BoardSpeech`: заголовок, просьба выбрать, название карточки и сообщение; нажатие на сообщение повторяет озвучку. Порядок карточек постоянный (П4). Награду выдаёт родитель сам, приложение её не отслеживает.

**Выражения Айлы** (`lib/widgets/aila_face.dart`, `assets/aila/*.png`, 12 штук): вырезаны из листа стикеров скриптом `tool/cut_sheet.swift` (запуск — в начале файла). Каждое показывается в своём месте: похвала после верного ответа по номеру задания (`_AilaPraise`: радость, подмигивание, сердечко, машет), сон на перерыве и в экране лимита игр, сердечко в конце путешествия. Грустное и злое выражения (`worried`, `angry`) в игре не показываются: на неверный ответ Айла не огорчается (П5).

**Игры на словах доски** (`findPicture`, `buildPhrase`, сортировка, «Что хочет сказать Айла?», «Повтори фразу») берут слова только из `BoardModel.gameObjects`/`visibleDescriptions`: скрытая родителем карточка или категория в них не появляется, а если карточек не хватает, задание пропускается. «Собери фразу» есть только с фазы IV. Задания на фото (эмоции, истории, последовательность, «Что делать?») учат ситуациям и остаются своим контентом.

The speak game is "Тренировка вместе с родителем": there is no speech recognition (out of MVP scope), so it must never auto-succeed. The app speaks `speakPhrase` via `flutter_tts` on tap of «Послушать», and the **adult** taps «Получилось» (→ normal success feedback → `onComplete`) or «Попробуем потом» (→ `onSkip`: next step, no stars, step stays uncompleted, neutral snackbar, no error state).

**Visual content policy for game steps**: each `GameStep`'s imagery resolves in priority order — real photo (`imagePath`, files under `assets/games/<category>/`) → simple vector illustration (`pictogramBuilder`, hand-drawn `CustomPainter`s in `game_pictograms.dart`, used only for neutral objects where an abstract illustration can't distort meaning) → explicit "photo needed" placeholder (`promptPlaceholderNote` → `MissingPhotoPlaceholder`) when neither exists yet. **Never fall back to emoji for instructional content** — this was a deliberate, explicit product decision. Decorative chrome (background clouds/rocket, wardrobe icons, dialog titles) is exempt from this rule and may use emoji/Material icons freely.

Тексты для ребёнка пишутся без рода («Получилось!», «Фраза собрана!», карточка «усталость»): в профиле нет пола, нельзя писать «Ты справился».

Answer feedback in games is intentionally non-alarming: wrong answers get a neutral gray/muted "Попробуй ещё раз" prompt, never a red X or red text — this was also an explicit, deliberate ASD-friendly design decision; don't reintroduce red error states.

### Доска общения (`lib/board/`, `lib/parent/board_settings_screen.dart`, `lib/parent/parent_card_form_screen.dart`)

`BoardScreen` собирается по фазе из профиля (`BoardPhase`: III-A, III-B, IV, IV+, V, VI). Сверху вниз: полоска фразы, стартовые фразы, закреплённая строка (`kPinnedWordIds`, видна на всех фазах и не скрывается), сетка, панель категорий. Звёзды за доску не начисляются.

- `board_words.dart` — ровно 60 слов `kBoardWords`, `ParentCard`. `board_model.dart` — что показать для профиля. Экран не решает это сам, порядок постоянный (П4).
- `phrase_builder.dart` — сборка фразы: русский через хранимые формы (падеж, род, формы описаний), казахский через шаблоны с глаголом в конце, английский через артикли. Описания всегда перед предметом, размер раньше цвета. Карточки родителя произносятся как записаны. Казахские тексты должен проверить носитель.
- `board_labels.dart` (в `lib/l10n/`) — подписи 60 слов на трёх языках, в экранах через `S.boardLabel`.
- `pictogram_repository.dart` — единственное место, которое знает, откуда картинка. `kPictogramSet` переключает весь набор. Сейчас 53 слова из `assets/pecs_symbols/` (Mulberry), 7 из `assets/pictograms/arasaac/` (`i_feel`, `stop`, `bye`, `thanks`, `hurts`, `me`, `cartoon`). Для ARASAAC скачаны все 60 (`dart run tool/fetch_arasaac.dart`, список и ids в `manifest.json`), приложение в сеть не ходит (П8). Атрибуция обоих наборов на экране «О приложении» — не убирать.
- `flutter_svg` не понимает `<style>` в SVG: такие файлы рисуются чёрными. При копировании нового символа из `assets/EN-symbols/` (~3400 Mulberry, в сборку не входит) перенесите цвета из `<style>` в атрибуты.
- `board_speech.dart` — озвучка на языке профиля (`flutter_tts`, скорость 0.42). Запись голоса родителя важнее синтеза. Если голоса для языка нет, родитель видит сообщение.
- `parent_media.dart` — папка с фото и записями карточек родителя. В профиле только имена файлов. Карточку можно исправить: `ParentCardFormScreen(editing: card)` → `updateParentCard`.

Слово «PECS» в интерфейсе не используется (П9). Папка `assets/pecs_symbols/` сохранила старое имя.

### Опрос родителя (`lib/survey/`, `lib/parent/print_cards.dart`)

Порядок первого запуска: профиль → PIN → `SurveyScreen(firstRun: true)` → результат → `MainScreen`. Новый профиль из настроек тоже сразу идёт на опрос. Опрос можно отложить («Пройти позже») и пройти из настроек.

- `survey_data.dart` — `calculateSurveyResult`: правила расчёта фазы из ТЗ. Если на вопрос 1 или 2 ответ не «Почти всегда», опрос сразу заканчивается экраном `SurveySpecialistScreen`: остальные ответы на результат не влияют.
- Опрос сохраняет ответы и дату (`saveSurvey`), но **фазу сам не меняет**: она применяется только после подтверждения на экране результата. Со стрелкой «назад» фаза остаётся прежней.
- Вопросы (`S.surveyQuestion`) и советы (`S.phaseTip`) — **черновик**, их должен проверить специалист.
- `isSurveyDue` — через 28 дней после опроса пункт в настройках становится «Пройти опрос заново?».
- `print_cards.dart` — PDF A4 с 12 карточками (`kPrintCardIds`), подписи на языке профиля. Шрифт Roboto лежит в `assets/fonts/`, в нём есть все казахские буквы, PDF собирается без интернета. Пакет `printing` открывает окно печати.

### Журнал для пилота (`lib/journal/journal.dart`, `lib/parent/today_screen.dart`)

Только на устройстве (П7): отдельный ключ `aila_journal_v1` в `shared_preferences`, последние 5000 записей, у каждого профиля свои. Фраза записывается по «Сказать», а в фазах III — по нажатию на карточку (`logPhrase`); смена фазы — в `setBoardPhase`. Ответом считается первая фраза в течение 2 минут после кнопки вопроса (`kAnswerWindow`). «Я хочу» считается карточкой. Экран «Сегодня» (настройки, за PIN) считает спонтанные фразы и фразы из 2+ карточек за день и за 7 дней, рисует фразы по дням и частые фразы. «Собрать документ специалисту» — PDF за 4 недели (`specialist_report.dart`), имя ребёнка родитель вписывает сам. «Поделиться отчётом» — CSV через `share_plus`: разделитель `;`, метка UTF-8 для Excel, имени ребёнка нет.

### Гардероб Айлы (`lib/wardrobe_screen.dart`, `lib/wardrobe/wardrobe_items.dart`, `lib/widgets/aila_with_items.dart`)

24 аксессуара (шапки, очки, наушники, банты, ободки, короны) в `assets/wardrobe/*.png`, вырезаны из картинок владелицы скриптом `tool/cut_items.swift` (запуск — в начале файла). Каждый предмет описан в `kWardrobeItems`: цена, место на Айле (`WardrobeSlot`: в каждом месте один предмет), положение `cx/cy/width/rotation` в долях картинки Айлы (`assets/aila/aila_smile.png`). Предметы стоят на одной позе Айлы: на других выражениях положение не совпадёт. Нажатие на предмет надевает его на пробу, покупка и сохранение — одной кнопкой внизу (`AppState.purchase` + `setLook`). Образ хранится в профиле (`equippedItemIds`), старые наряды (`equippedOutfitId`) выброшены. Названия — `S.wardrobeItemName(id)` на трёх языках. Картинки исходно небольшие (~100 px), на крупных экранах слегка мягкие: если будут картинки покрупнее, пересобрать скриптом.

### Settings / static screens

«О приложении» (`info_screen.dart`) только честные тексты: назначение, «не заменяет занятий со специалистом», авторы картинок, конфиденциальность. Не добавлять обещаний лечения и несуществующих функций. `settings_screen.dart`, `info_screen.dart`, `support_screen.dart` are mostly static, localized content screens reading from `AppLocaleScope`/`AppStateScope`. Language switching happens in `settings_screen.dart` via `AppLocaleScope.of(context).setLanguage(...)`.
