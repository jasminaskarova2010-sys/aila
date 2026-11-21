// lib/l10n/strings.dart

import 'package:flutter/widgets.dart';
import '../board/board_words.dart';
import '../survey/survey_data.dart';
import '../wardrobe/wardrobe_items.dart';
import 'app_language.dart';
import 'board_labels.dart';

class S {
  final AppLanguage lang;

  const S(this.lang);

  static S of(BuildContext context) => S(AppLocaleScope.of(context).language);

  String _t(String ru, String en, String kk) {
    switch (lang) {
      case AppLanguage.en:
        return en;
      case AppLanguage.kk:
        return kk;
      case AppLanguage.ru:
        return ru;
    }
  }

  // Onboarding
  String get onboardingPrefix =>
      _t('Учись каждый день\nвместе с ', 'Learn Everyday\nWith ', '');
  String get onboardingSuffix => _t('!', '', ' -мен бірге\nкүнде үйрен!');
  String get onboardingGetStarted => _t('Начать', 'Get Started', 'Бастау');

  // Child profile screen
  String get profileTitle =>
      _t('Профиль ребёнка', 'Child profile', 'Бала профилі');
  String get profileNewTitle =>
      _t('Новый профиль', 'New profile', 'Жаңа профиль');
  String get profileEditTitle =>
      _t('Изменить профиль', 'Edit profile', 'Профильді өзгерту');
  String get profileSubtitle => _t(
    'Эти данные хранятся только на этом устройстве.',
    'This information is stored on this device only.',
    'Бұл деректер тек осы құрылғыда сақталады.',
  );
  String get profileNameLabel =>
      _t('Имя ребёнка', "Child's name", 'Баланың аты');
  String get profileNameHint =>
      _t('Можно не заполнять', 'Optional', 'Міндетті емес');
  String get profileAgeLabel => _t('Возраст, лет', 'Age, years', 'Жасы');
  String get unnamedChild => _t('Без имени', 'No name', 'Атсыз');
  String profileAge(int age) => _t('Возраст: $age', 'Age: $age', 'Жасы: $age');
  String get saveButton => _t('Сохранить', 'Save', 'Сақтау');
  String get continueButton => _t('Продолжить', 'Continue', 'Жалғастыру');
  String get cancelButton => _t('Отмена', 'Cancel', 'Болдырмау');

  // Parent PIN
  String get pinSetupTitle =>
      _t('PIN родителя', 'Parent PIN', 'Ата-ана PIN коды');
  String get pinSetupBody => _t(
    'Придумайте 4 цифры. PIN закрывает настройки и родительский раздел, чтобы ребёнок случайно их не изменил.',
    'Choose 4 digits. The PIN protects settings and the parent section so the child does not change them by accident.',
    'Төрт сан ойлап табыңыз. PIN баптаулар мен ата-ана бөлімін бала кездейсоқ өзгертпеуі үшін қорғайды.',
  );
  String get pinConfirmBody => _t(
    'Введите этот PIN ещё раз',
    'Enter the same PIN again',
    'Осы PIN кодты қайта енгізіңіз',
  );
  String get pinMismatch => _t(
    'PIN не совпал. Придумайте его заново.',
    'The PINs did not match. Please choose it again.',
    'PIN сәйкес келмеді. Қайта ойлап табыңыз.',
  );
  String get pinEntryTitle =>
      _t('Для взрослых', 'For grown-ups', 'Ересектерге арналған');
  String get pinEntryBody => _t(
    'Введите PIN родителя',
    'Enter the parent PIN',
    'Ата-ана PIN кодын енгізіңіз',
  );
  String get pinWrong => _t(
    'PIN не подошёл. Попробуйте ещё раз.',
    'That PIN did not match. Try again.',
    'PIN сәйкес келмеді. Қайталап көріңіз.',
  );
  String get pinForgot =>
      _t('Забыли PIN?', 'Forgot PIN?', 'PIN кодты ұмыттыңыз ба?');
  String get pinResetTitle =>
      _t('Сброс PIN', 'Reset PIN', 'PIN кодты қалпына келтіру');
  String pinResetQuestion(int a, int b) => _t(
    'Чтобы задать новый PIN, решите пример:\n$a × $b = ?',
    'To set a new PIN, solve:\n$a × $b = ?',
    'Жаңа PIN орнату үшін мысалды шешіңіз:\n$a × $b = ?',
  );
  String get pinResetWrong => _t(
    'Ответ не подошёл. Вот другой пример.',
    'That answer did not match. Here is another one.',
    'Жауап сәйкес келмеді. Міне, басқа мысал.',
  );
  String get answerHint => _t('Ответ', 'Answer', 'Жауап');
  String get checkButton => _t('Проверить', 'Check', 'Тексеру');

  // Home tab
  String greeting(String name) =>
      _t('Привет, $name!', 'Hi, $name!', 'Сәлем, $name!');
  String get readyForToday => _t(
    'Готовы к сегодняшнему дню?',
    'Ready for today?',
    'Бүгінге дайынсың ба?',
  );
  String get startJourneyCard => _t(
    'Давай начнём\nнаше путешествие!',
    "Let's start\nour journey!",
    'Саяхатымызды\nбастайық!',
  );
  String get journeyOfDay =>
      _t('Путешествие дня', "Today's journey", 'Күндізгі саяхат');
  String activitiesCount(int done, int total) => _t(
    '$done / $total активностей',
    '$done / $total activities',
    '$done / $total тапсырма',
  );
  String get startJourneyButton =>
      _t('НАЧАТЬ ПУТЕШЕСТВИЕ', 'START MY JOURNEY', 'САЯХАТТЫ БАСТАУ');
  String get boardTitle =>
      _t('Доска общения', 'Communication board', 'Қарым-қатынас тақтасы');
  String get pecsSubtitle => _t(
    'Общение с помощью картинок',
    'Communicate with pictures',
    'Суреттер арқылы қарым-қатынас',
  );
  String get startingJourneySnackbar =>
      _t('Начинаем путешествие', 'Starting the journey', 'Саяхат басталады');
  String get defaultUserName => _t('друг', 'friend', 'дос');

  // Games flow
  String get sessionDoneTitle =>
      _t('Занятие завершено! 🎉', 'Session complete! 🎉', 'Сабақ аяқталды! 🎉');
  String sessionDoneBody(int stars) => stars > 0
      ? _t(
          'Путешествие на сегодня пройдено! Получено звёзд: $stars ⭐. Отличная работа!',
          "You reached the end of today's journey and earned $stars ⭐. Great work!",
          'Сен бүгінгі саяхаттың соңына жетіп, $stars ⭐ жинадың. Жарайсың!',
        )
      : _t(
          'Путешествие на сегодня пройдено. Отличная работа!',
          "You reached the end of today's journey. Great work!",
          'Сен бүгінгі саяхаттың соңына жеттің. Жарайсың!',
        );
  String get sessionDoneOk => _t('Отлично!', 'Great!', 'Тамаша!');

  // Speak game (practice with a parent)
  String get practiceWithParent => _t(
    'Тренировка вместе с родителем',
    'Practice together with a parent',
    'Ата-анамен бірге жаттығу',
  );
  String get speakListen => _t('Послушать', 'Listen', 'Тыңдау');
  String get speakTryRepeat =>
      _t('Попробуй повторить', 'Try saying it', 'Қайталап көр');
  String get speakParentHint => _t(
    'Взрослый: отметьте, как получилось. Оба ответа подходят.',
    'Grown-up: tap how it went. Both answers are fine.',
    'Ересек адам: қалай болғанын белгілеңіз. Екі жауап та дұрыс.',
  );
  String get speakDone => _t('Получилось', 'We did it', 'Шықты');
  String get speakLater =>
      _t('Попробуем потом', 'Try later', 'Кейін байқаймыз');
  String get speakLaterSnackbar => _t(
    'Хорошо, вернёмся к этому позже',
    "Okay, we'll come back to it later",
    'Жарайды, кейінірек оралайық',
  );

  // Bottom nav / main screen
  String get navHome => _t('Главная', 'Home', 'Басты бет');
  String get navJourney => _t('Путешествие', 'Journey', 'Саяхат');

  // Journey tab
  String get wardrobeLabel => _t('Гардероб', 'Wardrobe', 'Киім шкафы');
  String get wardrobeSnackbar => _t(
    'Гардероб — скоро здесь',
    'Wardrobe — coming soon',
    'Киім шкафы — жақында',
  );
  String get journeySection =>
      _t('Раздел 2, Занятие 17', 'Section 2, Lesson 17', '2-бөлім, 17-сабақ');
  String get journeyLessonTitle =>
      _t('Опиши свой дом', 'Describe your home', 'Үйіңді сипатта');
  String get lessonListSnackbar => _t(
    'Список занятий — скоро здесь',
    'Lesson list — coming soon',
    'Сабақтар тізімі — жақында',
  );
  String get lessonUnlockedSnackbar => _t(
    'Занятие скоро будет доступно',
    'This lesson will be available soon',
    'Сабақ жақында қолжетімді болады',
  );
  String get lessonLockedSnackbar => _t(
    'Занятие ещё не открыто',
    'This lesson is not unlocked yet',
    'Сабақ әлі ашылмаған',
  );

  // Settings screen
  String get settingsTitle => _t('Настройки', 'Settings', 'Баптаулар');
  String get settingsSubtitle => _t(
    'Управляй приложением и делай его удобнее для себя!',
    'Manage the app and make it more comfortable for you!',
    'Қолданбаны басқарып, өзіңе ыңғайлы ет!',
  );
  String get sectionGeneral => _t('Общее', 'General', 'Жалпы');
  String get sound =>
      _t('Звук верного ответа', 'Correct answer sound', 'Дұрыс жауап дыбысы');
  String get music => _t(
    'Спокойная музыка в играх',
    'Calm music in games',
    'Ойындағы тыныш әуен',
  );
  String get vibration => _t(
    'Лёгкая вибрация при верном ответе',
    'Light vibration on a correct answer',
    'Дұрыс жауапта жеңіл діріл',
  );
  String get sectionProfiles =>
      _t('Профили детей', 'Child profiles', 'Балалар профильдері');
  String get addProfile =>
      _t('Добавить профиль', 'Add profile', 'Профиль қосу');
  String get editProfile => _t(
    'Изменить текущий профиль',
    'Edit current profile',
    'Ағымдағы профильді өзгерту',
  );
  String get changePin => _t('Сменить PIN', 'Change PIN', 'PIN кодты өзгерту');
  String get sectionOther => _t('Другое', 'Other', 'Басқа');
  String get supportRow =>
      _t('Помощь и поддержка', 'Help & Support', 'Көмек және қолдау');
  String get sectionLanguage => _t('Язык', 'Language', 'Тіл');

  // Info screen
  String get infoTitle =>
      _t('О приложении', 'About the App', 'Қолданба туралы');
  String get infoSubtitle => _t(
    'Для родителей и специалистов',
    'For parents and specialists',
    'Ата-аналар мен мамандарға',
  );
  String get infoPurposeTitle =>
      _t('Для чего Айла', 'What Aila is for', 'Айла не үшін керек');
  String get infoPurposeBody => _t(
    'Айла помогает ребёнку с аутизмом или задержкой речи общаться с помощью карточек с картинками: просить, отвечать, рассказывать о том, что вокруг. В приложении есть доска общения, короткие игры и подсказки для взрослых. Доска усложняется постепенно, вместе с ребёнком.',
    'Aila helps a child with autism or speech delay communicate using picture cards: to ask, to answer, to talk about the world around them. The app has a communication board, short games and hints for adults. The board grows gradually, together with the child.',
    'Айла аутизмі немесе сөйлеу тежелісі бар балаға суретті карточкалар арқылы қарым-қатынас жасауға көмектеседі: сұрауға, жауап беруге, айналасы туралы айтуға. Қолданбада қарым-қатынас тақтасы, қысқа ойындар және ересектерге кеңестер бар. Тақта бала өскен сайын біртіндеп күрделенеді.',
  );
  String get infoNotReplaceTitle => _t(
    'Не заменяет занятий со специалистом',
    'Does not replace sessions with a specialist',
    'Маманмен сабақтарды алмастырмайды',
  );
  String get infoNotReplaceBody => _t(
    'Айла не лечит и не ставит диагнозов. Это дополнительный инструмент для занятий дома. Если у вас есть вопросы о развитии ребёнка, обратитесь к логопеду или дефектологу.',
    'Aila does not treat anything or make diagnoses. It is an additional tool for practice at home. If you have questions about your child\'s development, talk to a speech therapist or a special education teacher.',
    'Айла емдемейді және диагноз қоймайды. Бұл үйдегі сабақтарға арналған қосымша құрал. Баланың дамуы туралы сұрақтарыңыз болса, логопедке немесе дефектологқа жүгініңіз.',
  );
  String get infoPrivacyTitle =>
      _t('Конфиденциальность', 'Privacy', 'Құпиялылық');
  String get infoPrivacyBody => _t(
    'Все данные хранятся только на этом устройстве и никуда не передаются. Приложению не нужен интернет, в нём нет рекламы и учётных записей. Отчёт попадёт к другим людям, только если вы сами им поделитесь. На iPhone данные могут попасть в резервную копию iCloud, если она у вас включена.',
    'All data is stored only on this device and is not sent anywhere. The app does not need the internet and has no ads or accounts. The report reaches other people only if you share it yourself. On iPhone, data may be included in your iCloud backup if you have it turned on.',
    'Барлық деректер тек осы құрылғыда сақталады және ешқайда жіберілмейді. Қолданбаға интернет керек емес, онда жарнама мен тіркелгі жоқ. Есеп басқа адамдарға сіз өзіңіз бөліскенде ғана жетеді. iPhone-да деректер iCloud резервтік көшірмесіне түсуі мүмкін, егер ол қосулы болса.',
  );

  // Support screen
  String get supportTitle =>
      _t('Помощь и поддержка', 'Help & Support', 'Көмек және қолдау');
  String get supportSubtitle => _t(
    'Мы всегда на связи и готовы помочь!',
    "We're always here to help!",
    'Біз әрдайым байланыстамыз және көмектесуге дайынбыз!',
  );
  String get phone1Label => _t('Телефон (1)', 'Phone (1)', 'Телефон (1)');
  String get phone2Label => _t('Телефон (2)', 'Phone (2)', 'Телефон (2)');
  String get emailLabel => _t('Email', 'Email', 'Email');
  String get supportTip => _t(
    'Если у вас возникли вопросы, пожелания или проблемы — напишите или позвоните нам. Мы обязательно вам поможем!',
    "If you have any questions, suggestions, or issues — write or call us. We'll be happy to help!",
    'Сұрақтарыңыз, тілектеріңіз немесе мәселелеріңіз болса — бізге жазыңыз немесе қоңырау шалыңыз. Біз міндетті түрде көмектесеміз!',
  );
  String get numberCopied =>
      _t('Номер скопирован', 'Number copied', 'Нөмір көшірілді');
  String get emailCopied =>
      _t('Email скопирован', 'Email copied', 'Email көшірілді');

  // Доска общения
  String boardLabel(BoardWord word) =>
      word.customLabel ?? boardWordLabel(word.id, lang);
  String boardCategoryName(BoardCategory category) {
    switch (category) {
      case BoardCategory.home:
        return _t('Домой', 'Home', 'Басты');
      case BoardCategory.food:
        return _t('Еда', 'Food', 'Тамақ');
      case BoardCategory.drinks:
        return _t('Напитки', 'Drinks', 'Сусындар');
      case BoardCategory.toys:
        return _t('Игрушки', 'Toys', 'Ойыншықтар');
      case BoardCategory.actions:
        return _t('Действия', 'Actions', 'Әрекеттер');
      case BoardCategory.people:
        return _t('Люди', 'People', 'Адамдар');
      case BoardCategory.places:
        return _t('Места', 'Places', 'Орындар');
      case BoardCategory.feelings:
        return _t('Чувства', 'Feelings', 'Сезімдер');
      case BoardCategory.descriptions:
        return _t('Описания', 'Descriptions', 'Сипаттамалар');
      case BoardCategory.starters:
        return _t('Начало фразы', 'Phrase starters', 'Сөйлем басы');
    }
  }

  String get boardSay => _t('Сказать', 'Say', 'Айту');
  String get boardErase => _t('Стереть', 'Erase', 'Өшіру');
  String get boardAsk => _t('Задать вопрос', 'Ask a question', 'Сұрақ қою');
  String get boardAskSee =>
      _t('Что ты видишь?', 'What do you see?', 'Не көріп тұрсың?');
  String get boardQuestionWant =>
      _t('Что ты хочешь?', 'What do you want?', 'Не қалайсың?');
  String hintRequest(String what) => _t(
    'Ребёнок просит: $what. Дайте и назовите вслух',
    'Your child is asking for: $what. Give it and say the word aloud',
    'Бала сұрап тұр: $what. Беріңіз де, дауыстап атаңыз',
  );
  String hintComment(String what) => _t(
    'Ребёнок говорит: $what. Ответьте ему',
    'Your child says: $what. Answer them',
    'Бала айтып тұр: $what. Оған жауап беріңіз',
  );
  String get noVoiceMessage => _t(
    'На этом устройстве нет голоса для выбранного языка, поэтому синтез речи может молчать или говорить с акцентом. Запишите свой голос для карточек: Настройки → Доска общения → Мои карточки.',
    'This device has no voice for the selected language, so speech may be silent or accented. Record your own voice for cards: Settings → Communication board → My cards.',
    'Бұл құрылғыда таңдалған тілге дауыс жоқ, сондықтан сөйлеу естілмеуі немесе акцентпен болуы мүмкін. Карточкаларға өз дауысыңызды жазыңыз: Баптаулар → Қарым-қатынас тақтасы → Менің карточкаларым.',
  );

  // Настройки доски
  String get boardSettingsSubtitle => _t(
    'Что ребёнок видит на доске',
    'What your child sees on the board',
    'Бала тақтада не көреді',
  );
  String get boardPhaseSection => _t('Фаза', 'Phase', 'Кезең');
  String boardPhaseName(BoardPhase phase) {
    switch (phase) {
      case BoardPhase.iiiA:
        return _t(
          'III-A: две карточки',
          'III-A: two cards',
          'III-A: екі карточка',
        );
      case BoardPhase.iiiB:
        return _t(
          'III-B: больше карточек',
          'III-B: more cards',
          'III-B: көбірек карточка',
        );
      case BoardPhase.iv:
        return _t(
          'IV: фраза «Я хочу»',
          'IV: "I want" phrase',
          'IV: «Мен қалаймын» сөйлемі',
        );
      case BoardPhase.ivPlus:
        return _t('IV+: описания', 'IV+: descriptions', 'IV+: сипаттамалар');
      case BoardPhase.v:
        return _t(
          'V: ответ на вопрос',
          'V: answering a question',
          'V: сұраққа жауап',
        );
      case BoardPhase.vi:
        return _t(
          'VI: рассказ о том, что вокруг',
          'VI: talking about the world',
          'VI: айналаны әңгімелеу',
        );
    }
  }

  String boardPhaseHint(BoardPhase phase) {
    switch (phase) {
      case BoardPhase.iiiA:
        return _t(
          'Любимый предмет и нейтральный. Нажатие сразу озвучивает слово.',
          'A favourite item and a neutral one. A tap speaks the word right away.',
          'Сүйікті зат және бейтарап зат. Басқанда сөз бірден айтылады.',
        );
      case BoardPhase.iiiB:
        return _t(
          'От 3 до 20 карточек, категории открываются переключателем.',
          'From 3 to 20 cards, categories are opened with a switch.',
          '3-тен 20-ға дейін карточка, санаттар ауыстырғышпен ашылады.',
        );
      case BoardPhase.iv:
        return _t(
          'Полоска фразы, «Я хочу» уже стоит первой.',
          'A phrase strip with "I want" already in place.',
          'Сөйлем жолағы, «Мен қалаймын» бірінші тұрады.',
        );
      case BoardPhase.ivPlus:
        return _t(
          'Открываются описания: «Я хочу большой красный мяч».',
          'Descriptions open: "I want a big red ball".',
          'Сипаттамалар ашылады: «Мен үлкен қызыл доп қалаймын».',
        );
      case BoardPhase.v:
        return _t(
          'Появляется кнопка «Задать вопрос» для взрослого.',
          'An "Ask a question" button appears for the adult.',
          'Ересекке «Сұрақ қою» түймесі шығады.',
        );
      case BoardPhase.vi:
        return _t(
          'Открываются «Я вижу», «Я слышу», «Это» и вопрос «Что ты видишь?».',
          'Opens "I see", "I hear", "This is" and the question "What do you see?".',
          '«Мен көремін», «Мен естимін», «Бұл» және «Не көріп тұрсың?» сұрағы ашылады.',
        );
    }
  }

  String get adultHintLabel =>
      _t('Подсказка взрослому', 'Hint for the adult', 'Ересекке кеңес');
  String get adultHintBody => _t(
    'Плашка на 2–3 секунды после фразы',
    'A banner for 2–3 seconds after a phrase',
    'Сөйлемнен кейін 2–3 секундтық жазу',
  );
  String boardCardCountLabel(int count) => _t(
    'Карточек на экране: $count',
    'Cards on screen: $count',
    'Экрандағы карточка: $count',
  );
  String get boardCategoriesSwitch =>
      _t('Открыть категории', 'Open categories', 'Санаттарды ашу');
  String get favoritesSection =>
      _t('Любимые предметы', 'Favourite items', 'Сүйікті заттар');
  String get favoritesHint => _t(
    'Видны на главной странице доски, первый идёт в фазу III-A.',
    'Shown on the board home page; the first one is used in phase III-A.',
    'Тақтаның басты бетінде көрінеді, біріншісі III-A кезеңінде қолданылады.',
  );
  String get myCardsSection =>
      _t('Мои карточки', 'My cards', 'Менің карточкаларым');
  String get myCardsEmpty => _t(
    'Добавьте фото вещей и людей из жизни ребёнка.',
    "Add photos of things and people from your child's life.",
    'Бала өміріндегі заттар мен адамдардың суретін қосыңыз.',
  );
  String get addCard => _t('Добавить карточку', 'Add a card', 'Карточка қосу');
  String get parentMediaNoSpace => _t(
    'Не хватает места в памяти браузера. Удалите ненужные карточки или установите приложение.',
    'Not enough browser storage. Delete cards you do not need or install the app.',
    'Браузер жадында орын жетпейді. Қажетсіз карточкаларды өшіріңіз немесе қосымшаны орнатыңыз.',
  );
  String get showHideSection =>
      _t('Показать или скрыть', 'Show or hide', 'Көрсету немесе жасыру');
  String get showHideHint => _t(
    'Карточки не удаляются: ребёнок привыкает к их расположению.',
    'Cards are never deleted: children get used to where they are.',
    'Карточкалар өшірілмейді: бала олардың орнына үйренеді.',
  );
  String get showCategory =>
      _t('Показывать категорию', 'Show this category', 'Санатты көрсету');

  // Новая карточка
  String get cardPhoto => _t('Фото', 'Photo', 'Сурет');
  String get cardFromCamera => _t('Камера', 'Camera', 'Камера');
  String get cardFromGallery => _t('Галерея', 'Gallery', 'Галерея');
  String get cardLabel => _t('Подпись', 'Label', 'Жазу');
  String get cardLabelHint =>
      _t('Например: Мишка', 'For example: Teddy', 'Мысалы: Аюшық');
  String get cardCategory => _t('Категория', 'Category', 'Санат');
  String get cardVoice => _t(
    'Ваш голос (необязательно)',
    'Your voice (optional)',
    'Сіздің дауысыңыз (міндетті емес)',
  );
  String get cardVoiceHint => _t(
    'Запись родного голоса лучше синтеза речи.',
    'A familiar voice is better than synthetic speech.',
    'Таныс дауыс синтезден жақсы.',
  );
  String get cardRecord => _t('Записать', 'Record', 'Жазу');
  String get cardStopRecord => _t('Остановить', 'Stop', 'Тоқтату');
  String get cardRecordAgain =>
      _t('Записать заново', 'Record again', 'Қайта жазу');
  String get cardPlay => _t('Послушать', 'Listen', 'Тыңдау');
  String get cardNoMic => _t(
    'Нет доступа к микрофону. Разрешите его в настройках устройства.',
    'No microphone access. Allow it in the device settings.',
    'Микрофонға рұқсат жоқ. Құрылғы баптауларында рұқсат беріңіз.',
  );

  // О приложении
  String get infoPictogramsTitle =>
      _t('Пиктограммы', 'Pictograms', 'Пиктограммалар');
  String get infoPictogramsBody => _t(
    'Mulberry Symbols: © Steve Lee, лицензия CC BY-SA 4.0.\n\nАвтор пиктограмм: Sergio Palao. Источник: ARASAAC (https://arasaac.org). Лицензия: CC BY-NC-SA. Собственность: Правительство Арагона.',
    'Mulberry Symbols: © Steve Lee, CC BY-SA 4.0 license.\n\nPictograms author: Sergio Palao. Source: ARASAAC (https://arasaac.org). License: CC BY-NC-SA. Owner: Government of Aragon.',
    'Mulberry Symbols: © Steve Lee, CC BY-SA 4.0 лицензиясы.\n\nПиктограммалар авторы: Sergio Palao. Дереккөз: ARASAAC (https://arasaac.org). Лицензия: CC BY-NC-SA. Меншік иесі: Арагон үкіметі.',
  );

  // Опрос родителя. ЧЕРНОВИК: тексты должен проверить специалист.
  String get surveyTitle =>
      _t('Опрос для родителя', 'Parent survey', 'Ата-анаға сауалнама');
  String surveyQuestion(int index) {
    switch (index) {
      case 0:
        return _t(
          'Ребёнок сам даёт вам картинку или предмет, чтобы получить то, что хочет?',
          'Does your child give you a picture or an object on their own to get what they want?',
          'Бала қалағанын алу үшін сізге суретті немесе затты өзі бере ме?',
        );
      case 1:
        return _t(
          'Ребёнок сам подходит к вам или к своим карточкам, даже если вы в другом конце комнаты?',
          'Does your child come to you or to their cards on their own, even if you are across the room?',
          'Сіз бөлменің екінші жағында болсаңыз да, бала сізге немесе карточкаларына өзі келе ме?',
        );
      case 2:
        return _t(
          'Если перед ребёнком две картинки, он выбирает ту, что изображает нужную вещь?',
          'When there are two pictures in front of your child, do they choose the one showing what they need?',
          'Баланың алдында екі сурет болса, ол керек затты көрсететінін таңдай ма?',
        );
      case 3:
        return _t(
          'Ребёнок находит нужную картинку среди 5 и больше или на другой странице?',
          'Does your child find the right picture among 5 or more, or on another page?',
          'Бала керек суретті 5 немесе одан көп сурет арасынан не басқа беттен таба ма?',
        );
      case 4:
        return _t(
          'Ребёнок составляет из двух картинок фразу «Я хочу + предмет»?',
          'Does your child build the phrase "I want + item" from two pictures?',
          'Бала екі суреттен «Мен қалаймын + зат» сөйлемін құрай ма?',
        );
      case 5:
        return _t(
          'Ребёнок добавляет к просьбе цвет, размер или действие («большой мяч»)?',
          'Does your child add a colour, size or action to a request ("big ball")?',
          'Бала өтінішіне түсті, өлшемді немесе әрекетті қоса ма («үлкен доп»)?',
        );
      case 6:
        return _t(
          'Ребёнок отвечает картинками или словами на вопрос «Что ты хочешь?»',
          'Does your child answer the question "What do you want?" with pictures or words?',
          'Бала «Не қалайсың?» сұрағына суреттермен немесе сөзбен жауап бере ме?',
        );
      default:
        return _t(
          'Ребёнок сам рассказывает о том, что видит или слышит («я вижу собаку»)?',
          'Does your child talk on their own about what they see or hear ("I see a dog")?',
          'Бала көргені немесе естігені туралы өзі айта ма («мен итті көріп тұрмын»)?',
        );
    }
  }

  String surveyAnswer(SurveyAnswer answer) {
    switch (answer) {
      case SurveyAnswer.never:
        return _t('Никогда', 'Never', 'Ешқашан');
      case SurveyAnswer.sometimes:
        return _t('Иногда', 'Sometimes', 'Кейде');
      case SurveyAnswer.almostAlways:
        return _t('Почти всегда', 'Almost always', 'Әрдайым дерлік');
    }
  }

  String get surveyDisclaimer => _t(
    'Это не диагноз и не медицинская оценка. Опрос помогает выбрать, с чего начать. Если сомневаетесь, обратитесь к логопеду или дефектологу.',
    'This is not a diagnosis or a medical assessment. The survey helps you choose where to start. If in doubt, talk to a speech therapist or a special education teacher.',
    'Бұл диагноз емес және медициналық бағалау емес. Сауалнама неден бастауды таңдауға көмектеседі. Күмәндансаңыз, логопедке немесе дефектологқа жүгініңіз.',
  );
  String get surveyLater =>
      _t('Пройти позже', 'Take it later', 'Кейінірек өту');
  String get surveyRecommended => _t(
    'Рекомендуем начать с фазы',
    'We recommend starting with phase',
    'Осы кезеңнен бастауды ұсынамыз',
  );
  String get surveyChosen =>
      _t('Выбранная фаза', 'Chosen phase', 'Таңдалған кезең');
  String get surveyChangeManually => _t(
    'Изменить фазу вручную',
    'Change the phase manually',
    'Кезеңді қолмен өзгерту',
  );
  String get surveySpecialistBody => _t(
    'Сейчас ребёнку важнее научиться отдавать карточку взрослому из рук в руки. Это лучше делать с напечатанными карточками и специалистом.',
    'Right now it is more important for your child to learn to hand a card to an adult. This is best done with printed cards and a specialist.',
    'Қазір балаға карточканы ересекке қолдан қолға беруді үйрену маңыздырақ. Мұны басылған карточкалармен және маманмен жасаған дұрыс.',
  );
  String get surveyOpenBoardAnyway => _t(
    'Всё равно открыть доску',
    'Open the board anyway',
    'Бәрібір тақтаны ашу',
  );
  String get surveyOpen =>
      _t('Пройти опрос', 'Take the survey', 'Сауалнамадан өту');
  String get surveyRepeat => _t(
    'Пройти опрос заново?',
    'Take the survey again?',
    'Сауалнамадан қайта өтесіз бе?',
  );
  String get printCards => _t(
    'Распечатать набор карточек',
    'Print the card set',
    'Карточкалар жинағын басып шығару',
  );
  String get printFailed => _t(
    'Не удалось открыть окно печати. Попробуйте ещё раз.',
    'Could not open the print window. Please try again.',
    'Басып шығару терезесі ашылмады. Қайталап көріңіз.',
  );
  String phaseLearning(BoardPhase phase) {
    switch (phase) {
      case BoardPhase.iiiA:
        return _t(
          'Ребёнок будет учиться выбирать нужную картинку из двух.',
          'Your child will learn to choose the right picture out of two.',
          'Бала екі суреттен керегін таңдауды үйренеді.',
        );
      case BoardPhase.iiiB:
        return _t(
          'Ребёнок будет учиться находить нужную картинку среди многих.',
          'Your child will learn to find the right picture among many.',
          'Бала керек суретті көптің ішінен табуды үйренеді.',
        );
      case BoardPhase.iv:
        return _t(
          'Ребёнок будет учиться составлять фразу «Я хочу + предмет».',
          'Your child will learn to build the phrase "I want + item".',
          'Бала «Мен қалаймын + зат» сөйлемін құруды үйренеді.',
        );
      case BoardPhase.ivPlus:
        return _t(
          'Ребёнок будет учиться добавлять к просьбе цвет и размер.',
          'Your child will learn to add a colour and size to a request.',
          'Бала өтінішіне түс пен өлшемді қосуды үйренеді.',
        );
      case BoardPhase.v:
        return _t(
          'Ребёнок будет учиться отвечать на вопрос «Что ты хочешь?».',
          'Your child will learn to answer the question "What do you want?".',
          'Бала «Не қалайсың?» сұрағына жауап беруді үйренеді.',
        );
      case BoardPhase.vi:
        return _t(
          'Ребёнок будет учиться рассказывать о том, что видит и слышит.',
          'Your child will learn to talk about what they see and hear.',
          'Бала көргені мен естігені туралы айтуды үйренеді.',
        );
    }
  }

  // Совет на сегодня. ЧЕРНОВИК: тексты должен проверить специалист.
  String get tipTitle => _t('Совет на сегодня', "Today's tip", 'Бүгінгі кеңес');
  String phaseTip(BoardPhase phase) {
    switch (phase) {
      case BoardPhase.iiiA:
        return _t(
          'Положите рядом любимую вещь ребёнка и нейтральную. Когда ребёнок нажмёт на карточку, сразу дайте то, что на ней, и назовите вслух. Если выбрал нейтральную, тоже спокойно дайте её, без замечаний.',
          "Put your child's favourite item next to a neutral one. When your child taps a card, give them what is on it right away and name it aloud. If they chose the neutral one, calmly give that too, without comment.",
          'Баланың сүйікті заты мен бейтарап затты қатар қойыңыз. Бала карточканы басқанда, ондағы затты бірден беріп, дауыстап атаңыз. Бейтарап затты таңдаса, оны да ескертусіз, сабырмен беріңіз.',
        );
      case BoardPhase.iiiB:
        return _t(
          'Начните с небольшого числа карточек и добавляйте понемногу, когда ребёнок уверенно находит нужную. Не переставляйте карточки без причины. Дайте предмет сразу, как только ребёнок его выбрал.',
          'Start with a small number of cards and add a few more once your child finds the right one confidently. Do not move cards around without a reason. Give the item as soon as your child chooses it.',
          'Аз карточкадан бастап, бала керегін сенімді тапқанда, біртіндеп қосыңыз. Карточкалардың орнын себепсіз ауыстырмаңыз. Бала таңдаған затты бірден беріңіз.',
        );
      case BoardPhase.iv:
        return _t(
          'Оставьте любимую вещь на виду, но вне досягаемости. Ждите, пока ребёнок сам соберёт фразу. Не говорите «скажи», просто ответьте на фразу.',
          'Leave a favourite item in sight but out of reach. Wait for your child to build the phrase on their own. Do not say "say it", simply respond to the phrase.',
          'Сүйікті затты көрінетін, бірақ қол жетпейтін жерге қойыңыз. Баланың сөйлемді өзі құрауын күтіңіз. «Айт» демеңіз, сөйлемге жай ғана жауап беріңіз.',
        );
      case BoardPhase.ivPlus:
        return _t(
          'Держите рядом похожие вещи: большой и маленький мяч, красную и синюю чашку. Дождитесь, пока ребёнок сам добавит описание. Дайте именно то, что он попросил, и повторите фразу вслух.',
          'Keep similar items close: a big and a small ball, a red and a blue cup. Wait for your child to add a description on their own. Give exactly what they asked for and repeat the phrase aloud.',
          'Ұқсас заттарды жақын ұстаңыз: үлкен және кішкентай доп, қызыл және көк кесе. Баланың сипаттаманы өзі қосуын күтіңіз. Ол сұрағанын дәл беріп, сөйлемді дауыстап қайталаңыз.',
        );
      case BoardPhase.v:
        return _t(
          'В спокойный момент нажмите «Задать вопрос» и подождите несколько секунд, не подсказывая. Когда ребёнок ответит фразой, сразу дайте предмет. Просьбы без вопроса тоже выполняйте.',
          'At a calm moment, tap "Ask a question" and wait a few seconds without prompting. When your child answers with a phrase, give the item right away. Respond to requests made without a question too.',
          'Тыныш сәтте «Сұрақ қою» түймесін басып, ештеңе айтпай бірнеше секунд күтіңіз. Бала сөйлеммен жауап бергенде, затты бірден беріңіз. Сұрақсыз айтылған өтініштерді де орындаңыз.',
        );
      case BoardPhase.vi:
        return _t(
          'Когда рядом есть что-то интересное, нажмите «Что ты видишь?». Отвечайте разговором, а не предметом: «Да, это собака! Большая». Не требуйте ответа каждый раз.',
          'When there is something interesting nearby, tap "What do you see?". Respond with conversation, not an item: "Yes, it is a dog! A big one". Do not expect an answer every time.',
          'Жақын жерде қызық нәрсе болса, «Не көріп тұрсың?» түймесін басыңыз. Затпен емес, әңгімемен жауап беріңіз: «Иә, бұл ит! Үлкен екен». Әр кезде жауап талап етпеңіз.',
        );
    }
  }

  // Игры. Казахские тексты должен проверить носитель языка.
  String get gameTryAgain =>
      _t('Попробуй ещё раз', 'Try again', 'Тағы байқап көр');
  String get gameChooseRight => _t(
    'Выбери правильный вариант.',
    'Choose the right option.',
    'Дұрыс нұсқаны таңда.',
  );
  String get gameWellDone => _t('Молодец!', 'Well done!', 'Жарайсың!');
  String get gameGreat => _t('Отлично!', 'Great!', 'Тамаша!');
  String get gameGreatWork =>
      _t('Отличная работа!', 'Great work!', 'Керемет жұмыс!');
  String get gameClever => _t('Умница!', 'Clever!', 'Ақылдысың!');
  String get gameListening =>
      _t('Я тебя слушаю!', "I'm listening!", 'Мен сені тыңдап тұрмын!');

  String get gameFindTitle =>
      _t('Найди картинку', 'Find the picture', 'Суретті тап');
  String get gameFindSubtitle => _t(
    'Послушай слово и нажми на его карточку.',
    'Listen to the word and tap its card.',
    'Сөзді тыңдап, оның карточкасын бас.',
  );
  String gameFindPrompt(String word) =>
      _t('Найди: $word', 'Find: $word', 'Тап: $word');
  String get gameFindSuccess => _t(
    'Все картинки найдены!',
    'You found all the pictures!',
    'Сен барлық суретті таптың!',
  );

  String get gamePhraseTitle =>
      _t('Собери фразу', 'Build the phrase', 'Сөйлем құра');
  String get gamePhraseSubtitle => _t(
    'Послушай фразу и нажми нужные карточки.',
    'Listen to the phrase and tap the right cards.',
    'Сөйлемді тыңдап, керекті карточкаларды бас.',
  );
  String get gamePhraseSuccess =>
      _t('Фраза собрана!', 'You built the phrase!', 'Сен сөйлем құрадың!');

  String get gameHappyTitle =>
      _t('Кто счастлив?', 'Who is happy?', 'Кім бақытты?');
  String get gameHappySubtitle => _t(
    'Выбери мальчика, который счастлив.',
    'Choose the boy who is happy.',
    'Бақытты баланы таңда.',
  );
  String get gameHappySuccess =>
      _t('Получилось!', 'You did it!', 'Сен орындадың!');

  String get gameStoryTitle =>
      _t('Социальная история', 'Social story', 'Әлеуметтік әңгіме');
  String get gameStorySubtitle => _t(
    'Девочка пришла в магазин. Что нужно сделать?',
    'A girl came to a shop. What should she do?',
    'Қыз дүкенге келді. Не істеу керек?',
  );
  String get gameStoryWait => _t('Ждать очередь', 'Wait in line', 'Кезек күту');
  String get gameStoryShout => _t('Кричать', 'Shout', 'Айқайлау');
  String get gameStoryRun => _t('Убежать', 'Run away', 'Қашып кету');
  String get gameStorySuccess => _t(
    'Ждать очередь — это правильное и вежливое поведение!',
    'Waiting in line is the right and polite thing to do!',
    'Кезек күту — дұрыс әрі сыпайы мінез-құлық!',
  );

  String get gameLookTitle => _t(
    'Куда смотрит Айла?',
    'Where is Aila looking?',
    'Айла қайда қарап тұр?',
  );
  String get gameLookSubtitle => _t(
    'Посмотри, куда показывает Айла. Нажми на правильный предмет.',
    'See where Aila is pointing. Tap the right object.',
    'Айланың қайда көрсетіп тұрғанын қара. Дұрыс затты бас.',
  );
  String get gameLookCaption =>
      _t('Посмотри туда!', 'Look over there!', 'Анда қара!');
  String get gameLookSuccess => _t(
    'Айла показывает на самолёт! Отлично получилось!',
    'Aila is pointing at the plane! Great job!',
    'Айла ұшақты көрсетіп тұр! Сен тамаша орындадың!',
  );

  String get gameOrderTitle => _t(
    'Запомни последовательность',
    'Remember the order',
    'Ретін есте сақта',
  );
  String get gameOrderSubtitle => _t(
    'Посмотри на последовательность действий.\nЗатем повтори её.',
    'Look at the order of the actions.\nThen repeat it.',
    'Әрекеттердің ретіне қара.\nСодан кейін қайтала.',
  );
  String get gameOrderWake => _t('Проснуться', 'Wake up', 'Ояну');
  String get gameOrderTeeth =>
      _t('Почистить зубы', 'Brush teeth', 'Тіс тазалау');
  String get gameOrderBreakfast =>
      _t('Позавтракать', 'Have breakfast', 'Таңғы ас ішу');
  String get gameOrderDress => _t('Одеться', 'Get dressed', 'Киіну');
  String get gameOrderWatch =>
      _t('Смотри внимательно', 'Watch carefully', 'Мұқият қара');
  String get gameOrderRepeat => _t(
    'Теперь повтори последовательность',
    'Now repeat the order',
    'Енді ретін қайтала',
  );
  String get gameOrderReset => _t('Сбросить', 'Start over', 'Басынан бастау');
  String get gameOrderSuccess => _t(
    'Ты отлично запоминаешь последовательность!',
    'You remember the order very well!',
    'Сен ретін жақсы есте сақтайсың!',
  );

  String get gameSortTitle =>
      _t('Еда или игрушки?', 'Food or toys?', 'Тамақ па, ойыншық па?');
  String get gameSortSubtitle => _t(
    'Перетащи картинки в правильную корзину.',
    'Drag the pictures into the right basket.',
    'Суреттерді дұрыс себетке сүйреп апар.',
  );
  String get gameSortSuccess => _t(
    'Ты учишься сортировать предметы по категориям!',
    'You are learning to sort things into categories!',
    'Сен заттарды санаттарға бөлуді үйреніп жатырсың!',
  );

  String get gameSaysTitle => _t(
    'Что хочет сказать Айла?',
    'What does Aila want to say?',
    'Айла не айтқысы келеді?',
  );
  String get gameSaysSubtitle => _t(
    'Послушай фразу и выбери картинку, которая подходит.',
    'Listen to the phrase and choose the matching picture.',
    'Сөйлемді тыңдап, сәйкес суретті таңда.',
  );
  String gameSaysSuccess(String word) => _t(
    '$word — это правильно! Давай продолжим!',
    '$word is right! Let us go on!',
    '$word — дұрыс! Жалғастырайық!',
  );

  String get gameRepeatTitle =>
      _t('Повтори фразу', 'Repeat the phrase', 'Сөйлемді қайтала');
  String get gameRepeatSubtitle => _t(
    'Послушай фразу и повтори её.\nГовори чётко и спокойно.',
    'Listen to the phrase and repeat it.\nSpeak clearly and calmly.',
    'Сөйлемді тыңдап, қайтала.\nАнық әрі сабырмен сөйле.',
  );
  String get gameRepeatSuccess =>
      _t('Отлично произнесено!', 'Nicely said!', 'Тамаша айтылды!');

  String get gameDoTitle => _t('Что делать?', 'What to do?', 'Не істеу керек?');
  String get gameDoSubtitle => _t(
    'Послушай ситуацию и выбери лучший вариант.',
    'Listen to the situation and choose the best option.',
    'Жағдайды тыңдап, ең жақсы нұсқаны таңда.',
  );
  String get gameDoSpeech => _t(
    'Друг упал на площадке и заплакал. Что ты будешь делать?',
    'A friend fell on the playground and started crying. What will you do?',
    'Досың алаңда құлап, жылап қалды. Не істейсің?',
  );
  String get gameDoLaugh =>
      _t('Посмеяться и уйти', 'Laugh and walk away', 'Күліп, кетіп қалу');
  String get gameDoHelp =>
      _t('Подойти и помочь', 'Go and help', 'Жақындап, көмектесу');
  String get gameDoIgnore => _t(
    'Пройти мимо, как будто ничего не случилось',
    'Walk past as if nothing happened',
    'Ештеңе болмағандай өтіп кету',
  );
  String get gameDoSuccess => _t(
    'Подойти и помочь — это правильный выбор!',
    'Going to help is the right choice!',
    'Жақындап, көмектесу — дұрыс таңдау!',
  );

  // Перерыв
  String get breakTitle => _t('Время перерыва', 'Break time', 'Үзіліс уақыты');
  String get breakBody => _t(
    'Для взрослого: отдохните вместе. Когда ребёнок будет готов, нажмите «Продолжить».',
    'For the adult: rest together. When your child is ready, tap "Continue".',
    'Ересекке: бірге демалыңыз. Бала дайын болғанда, «Жалғастыру» түймесін басыңыз.',
  );
  String get breakAfterLabel => _t(
    'Перерыв после заданий',
    'Break after tasks',
    'Тапсырмалардан кейін үзіліс',
  );

  // Экран «Сегодня» и отчёт
  String get todayTitle => _t('Сегодня', 'Today', 'Бүгін');
  String get todayDay => _t('За сегодня', 'Today', 'Бүгін');
  String get todayWeek => _t('За 7 дней', 'Last 7 days', 'Соңғы 7 күн');
  String get todaySpontaneous => _t(
    'спонтанных фраз',
    'spontaneous phrases',
    'өз бетінше айтылған сөйлем',
  );
  String get todayMultiCard =>
      _t('фраз из 2+ карточек', 'phrases of 2+ cards', '2+ карточкалы сөйлем');
  String get todayExplanation => _t(
    'Спонтанная фраза: ребёнок сказал сам, а не ответил на вопрос в течение 2 минут. «Я хочу» тоже считается карточкой. Данные хранятся только на этом устройстве.',
    'A spontaneous phrase is one your child said on their own, not an answer to a question within 2 minutes. "I want" counts as a card too. The data stays only on this device.',
    'Өз бетінше айтылған сөйлем: бала 2 минут ішіндегі сұраққа жауап бермей, өзі айтқан сөйлем. «Мен қалаймын» да карточка болып саналады. Деректер тек осы құрылғыда сақталады.',
  );
  String get todayShare =>
      _t('Поделиться отчётом', 'Share the report', 'Есеппен бөлісу');
  String get todayEmpty => _t(
    'Отчёт появится, когда ребёнок скажет первую фразу на доске.',
    'The report will appear after the first phrase on the board.',
    'Есеп бала тақтада алғашқы сөйлемін айтқанда пайда болады.',
  );
  String get todayShareFailed => _t(
    'Не удалось поделиться отчётом. Попробуйте ещё раз.',
    'Could not share the report. Please try again.',
    'Есеппен бөлісу мүмкін болмады. Қайталап көріңіз.',
  );
  List<String> get csvHeaders => [
    _t('Дата и время', 'Date and time', 'Күні мен уақыты'),
    _t('Тип', 'Type', 'Түрі'),
    _t('Фраза', 'Phrase', 'Сөйлем'),
    _t('Карточек', 'Cards', 'Карточка саны'),
    _t('Как сказано', 'How it was said', 'Қалай айтылды'),
    _t('Фаза', 'Phase', 'Кезең'),
  ];
  String get csvPhrase => _t('фраза', 'phrase', 'сөйлем');
  String get csvPhaseChange => _t('смена фазы', 'phase change', 'кезең ауысуы');
  String get csvAnswer =>
      _t('ответ на вопрос', 'answer to a question', 'сұраққа жауап');
  String get csvSpontaneous => _t('спонтанно', 'spontaneous', 'өз бетінше');

  // Удаление профиля
  String get deleteProfile => _t(
    'Удалить текущий профиль',
    'Delete current profile',
    'Ағымдағы профильді жою',
  );
  String deleteProfileTitle(String name) => _t(
    'Удалить профиль «$name»?',
    'Delete the profile "$name"?',
    '«$name» профилін жою керек пе?',
  );
  String get deleteProfileBody => _t(
    'Удалятся звёзды, наряды, пройденные задания, карточки родителя с фото и голосом и журнал этого ребёнка. Отменить это нельзя.',
    "This child's stars, outfits, completed tasks, parent cards with photos and voice, and journal will be deleted. This cannot be undone.",
    'Осы баланың жұлдыздары, киімдері, орындалған тапсырмалары, суреті мен дауысы бар ата-ана карточкалары және журналы жойылады. Мұны қайтару мүмкін емес.',
  );
  String get deleteButton => _t('Удалить', 'Delete', 'Жою');

  // Гардероб
  String get wardrobeTitle =>
      _t('Гардероб Айлы', "Aila's wardrobe", 'Айланың киім шкафы');
  String get wardrobeSubtitle => _t(
    'Выбирай и наряжай Айлу!',
    'Choose an outfit for Aila!',
    'Айлаға киім таңда!',
  );
  String get wardrobeReset => _t('Сбросить', 'Reset', 'Тастау');
  String get wardrobeSaved =>
      _t('Образ сохранён', 'Look saved', 'Образ сақталды');
  String get wardrobeNotEnoughStars =>
      _t('Недостаточно звёзд', 'Not enough stars', 'Жұлдыз жеткіліксіз');
  String get wardrobeOwned => _t('Есть', 'Owned', 'Бар');
  String wardrobeItemName(String id) {
    switch (id) {
      case 'hat_bucket':
        return _t('Панама', 'Bucket hat', 'Панама');
      case 'hat_beret':
        return _t('Берет', 'Beret', 'Берет');
      case 'hat_beanie':
        return _t('Шапка с помпоном', 'Beanie', 'Помпонды бөрік');
      case 'hat_cap':
        return _t('Кепка', 'Cap', 'Кепка');
      case 'glasses_flower':
        return _t('Очки-цветочки', 'Flower glasses', 'Гүл көзілдірік');
      case 'glasses_black':
        return _t('Тёмные очки', 'Sunglasses', 'Қара көзілдірік');
      case 'glasses_heart':
        return _t('Очки-сердечки', 'Heart glasses', 'Жүрек көзілдірік');
      case 'glasses_round':
        return _t('Круглые очки', 'Round glasses', 'Дөңгелек көзілдірік');
      case 'phones_purple':
        return _t(
          'Фиолетовые наушники',
          'Purple headphones',
          'Күлгін құлаққап',
        );
      case 'phones_cat':
        return _t(
          'Наушники с ушками',
          'Cat-ear headphones',
          'Мысық құлақты құлаққап',
        );
      case 'phones_blue':
        return _t('Голубые наушники', 'Blue headphones', 'Көгілдір құлаққап');
      case 'phones_cream':
        return _t(
          'Кремовые наушники',
          'Cream headphones',
          'Кілегей түсті құлаққап',
        );
      case 'bow_purple':
        return _t('Фиолетовый бант', 'Purple bow', 'Күлгін бант');
      case 'bow_pink':
        return _t('Розовый бант', 'Pink bow', 'Қызғылт бант');
      case 'bow_cream':
        return _t('Кремовый бант', 'Cream bow', 'Кілегей түсті бант');
      case 'bow_plaid':
        return _t('Бант в клетку', 'Plaid bow', 'Шаршы бант');
      case 'star_clip':
        return _t('Заколка-звёздочка', 'Star clip', 'Жұлдызша түйреуіш');
      case 'band_cat':
        return _t(
          'Ободок с ушками',
          'Cat-ear headband',
          'Мысық құлақты белдік',
        );
      case 'band_heart':
        return _t('Ободок с сердечками', 'Heart headband', 'Жүрекшелі белдік');
      case 'band_flowers':
        return _t('Веночек', 'Flower crown', 'Гүл шоқ');
      case 'band_bunny':
        return _t(
          'Ободок с зайчьими ушками',
          'Bunny headband',
          'Қоян құлақты белдік',
        );
      case 'crown_gold':
        return _t('Золотая корона', 'Golden crown', 'Алтын тәж');
      case 'tiara':
        return _t('Диадема', 'Tiara', 'Диадема');
      case 'sleep_mask':
        return _t('Маска для сна', 'Sleep mask', 'Ұйқы маскасы');
      default:
        return id;
    }
  }

  // Лимит игр
  String get limitLabel =>
      _t('Лимит игр в день', 'Daily game limit', 'Күніне ойын шегі');
  String get limitOff => _t('Без лимита', 'No limit', 'Шексіз');
  String limitMinutes(int m) => _t('$m мин', '$m min', '$m мин');
  String limitPlayedToday(int m) => _t(
    'Сегодня в играх: $m мин. Доска общения работает всегда.',
    'Played today: $m min. The communication board always works.',
    'Бүгін ойында: $m мин. Қарым-қатынас тақтасы әрдайым жұмыс істейді.',
  );
  String get limitTitle => _t(
    'На сегодня игры закончились',
    'No more games today',
    'Бүгінге ойын бітті',
  );
  String get limitBody => _t(
    'Айла отдыхает. Завтра будут новые задания. Доска общения работает всегда.',
    'Aila is resting. New tasks tomorrow. The communication board always works.',
    'Айла демалып жатыр. Ертең жаңа тапсырмалар болады. Қарым-қатынас тақтасы әрдайым жұмыс істейді.',
  );
  String get limitHome => _t('На главную', 'Back home', 'Басты бетке');

  // Экран «Сегодня»: график и частые фразы
  String get todayChartTitle => _t(
    'Фраз в день за 7 дней',
    'Phrases per day, last 7 days',
    'Соңғы 7 күндегі сөйлемдер',
  );
  String get todayTopPhrases =>
      _t('Чаще всего говорит', 'Says most often', 'Жиі айтады');
  String weekdayShort(int weekday) {
    const ru = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
    const en = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
    const kk = ['Дс', 'Сс', 'Ср', 'Бс', 'Жм', 'Сн', 'Жс'];
    return _t(ru[weekday - 1], en[weekday - 1], kk[weekday - 1]);
  }

  // Документ для специалиста
  String get reportButton => _t(
    'Собрать документ специалисту',
    'Make a report for the specialist',
    'Маманға құжат жинау',
  );
  String get reportTitle => _t(
    'Отчёт для специалиста',
    'Report for the specialist',
    'Маманға арналған есеп',
  );
  String reportCreated(String date) => _t(
    'Создан в приложении Айла $date',
    'Created in the Aila app on $date',
    'Айла қолданбасында жасалды: $date',
  );
  String get reportChild => _t('Ребёнок', 'Child', 'Бала');
  String get reportName => _t(
    'Имя (впишите сами)',
    'Name (fill in yourself)',
    'Аты (өзіңіз жазыңыз)',
  );
  String get reportLanguage => _t('Язык', 'Language', 'Тіл');
  String get reportPhase =>
      _t('Фаза доски общения', 'Communication board phase', 'Тақта кезеңі');
  String get reportNoSurvey => _t(
    'Опрос ещё не пройден.',
    'The survey has not been taken yet.',
    'Сауалнама әлі өтілмеген.',
  );
  String reportSurveyDate(String date) =>
      _t('Пройден $date', 'Taken on $date', 'Өтілген күні: $date');
  String get reportSurveyShort => _t(
    'Опрос завершён досрочно: на вопрос 1 или 2 ответ был не «Почти всегда».',
    'The survey ended early: question 1 or 2 was not answered "Almost always".',
    'Сауалнама ерте аяқталды: 1 немесе 2-сұраққа «Әрдайым дерлік» деп жауап берілмеді.',
  );
  String get reportWeeks => _t(
    'Фразы на доске за 4 недели',
    'Board phrases, last 4 weeks',
    'Соңғы 4 аптадағы сөйлемдер',
  );
  String get reportWeek => _t('Неделя', 'Week', 'Апта');
  String get reportAll => _t('Всего фраз', 'All phrases', 'Барлық сөйлем');
  String get reportAnswers =>
      _t('ответов на вопрос', 'answers to a question', 'сұраққа жауап');
  String get reportTopPhrases => _t(
    'Частые фразы за 4 недели',
    'Frequent phrases, last 4 weeks',
    '4 аптадағы жиі сөйлемдер',
  );
  String get reportPhaseChanges =>
      _t('Смена фазы', 'Phase changes', 'Кезең ауысуы');
  String get reportDisclaimer => _t(
    'Данные собраны приложением Айла на устройстве семьи. Это не медицинский документ и не диагноз. Спонтанная фраза: ребёнок сказал сам, а не ответил на вопрос в течение 2 минут. «Я хочу» считается карточкой.',
    'Data collected by the Aila app on the family\'s device. This is not a medical document or a diagnosis. A spontaneous phrase is one the child said on their own, not an answer to a question within 2 minutes. "I want" counts as a card.',
    'Деректерді Айла қолданбасы отбасы құрылғысында жинады. Бұл медициналық құжат не диагноз емес. Өз бетінше сөйлем — бала 2 минут ішіндегі сұраққа жауап бермей, өзі айтқан сөйлем. «Мен қалаймын» карточка болып саналады.',
  );
  String languageName(AppLanguage language) {
    switch (language) {
      case AppLanguage.ru:
        return 'Русский';
      case AppLanguage.kk:
        return 'Қазақша';
      case AppLanguage.en:
        return 'English';
    }
  }

  String get editCard =>
      _t('Изменить карточку', 'Edit card', 'Карточканы өзгерту');
  String get editCardHint => _t(
    'Нажмите на карточку, чтобы изменить фото, подпись или голос.',
    'Tap a card to change its photo, label or voice.',
    'Суретін, жазуын не дауысын өзгерту үшін карточканы басыңыз.',
  );

  String get breakChoose => _t(
    'Выбери, что тебе нравится',
    'Choose what you like',
    'Ұнайтынын таңда',
  );
  String get breakShowParent => _t(
    'Покажи родителям: это твоя награда!',
    'Show your parents: this is your reward!',
    'Ата-анаңа көрсет: бұл сенің сыйлығың!',
  );
  String get breakRestOnly => _t('Давай отдохнём', "Let's rest", 'Демалайық');

  String get wardrobeAll => _t('Всё', 'All', 'Барлығы');
  String wardrobeCategory(WardrobeCategory category) {
    switch (category) {
      case WardrobeCategory.hats:
        return _t('Шапки', 'Hats', 'Бөріктер');
      case WardrobeCategory.glasses:
        return _t('Очки', 'Glasses', 'Көзілдіріктер');
      case WardrobeCategory.headphones:
        return _t('Наушники', 'Headphones', 'Құлаққаптар');
      case WardrobeCategory.bows:
        return _t('Банты', 'Bows', 'Бантар');
      case WardrobeCategory.headbands:
        return _t('Ободки', 'Headbands', 'Белдіктер');
      case WardrobeCategory.crowns:
        return _t('Короны', 'Crowns', 'Тәждер');
    }
  }

  String wardrobeBuy(int price) =>
      _t('Купить за $price', 'Buy for $price', '$price-ға алу');
  String get wardrobeSaveLook =>
      _t('Сохранить образ', 'Save look', 'Образды сақтау');
  String get wardrobeTakeOff => _t('Снять всё', 'Take all off', 'Бәрін шешу');
}
