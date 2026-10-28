// lib/l10n/strings.dart

import 'package:flutter/widgets.dart';
import 'app_language.dart';

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
  String get onboardingSuffix =>
      _t('!', '', ' -мен бірге\nкүнде үйрен!');
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
      'Бұл деректер тек осы құрылғыда сақталады.');
  String get profileNameLabel => _t('Имя ребёнка', "Child's name", 'Баланың аты');
  String get profileNameHint =>
      _t('Можно не заполнять', 'Optional', 'Міндетті емес');
  String get profileAgeLabel => _t('Возраст, лет', 'Age, years', 'Жасы');
  String get unnamedChild => _t('Без имени', 'No name', 'Атсыз');
  String profileAge(int age) =>
      _t('Возраст: $age', 'Age: $age', 'Жасы: $age');
  String get saveButton => _t('Сохранить', 'Save', 'Сақтау');
  String get continueButton => _t('Продолжить', 'Continue', 'Жалғастыру');
  String get cancelButton => _t('Отмена', 'Cancel', 'Болдырмау');

  // Parent PIN
  String get pinSetupTitle =>
      _t('PIN родителя', 'Parent PIN', 'Ата-ана PIN коды');
  String get pinSetupBody => _t(
      'Придумайте 4 цифры. PIN закрывает настройки и родительский раздел, чтобы ребёнок случайно их не изменил.',
      'Choose 4 digits. The PIN protects settings and the parent section so the child does not change them by accident.',
      'Төрт сан ойлап табыңыз. PIN баптаулар мен ата-ана бөлімін бала кездейсоқ өзгертпеуі үшін қорғайды.');
  String get pinConfirmBody => _t('Введите этот PIN ещё раз',
      'Enter the same PIN again', 'Осы PIN кодты қайта енгізіңіз');
  String get pinMismatch => _t('PIN не совпал. Придумайте его заново.',
      'The PINs did not match. Please choose it again.',
      'PIN сәйкес келмеді. Қайта ойлап табыңыз.');
  String get pinEntryTitle =>
      _t('Для взрослых', 'For grown-ups', 'Ересектерге арналған');
  String get pinEntryBody => _t('Введите PIN родителя',
      'Enter the parent PIN', 'Ата-ана PIN кодын енгізіңіз');
  String get pinWrong => _t('PIN не подошёл. Попробуйте ещё раз.',
      'That PIN did not match. Try again.',
      'PIN сәйкес келмеді. Қайталап көріңіз.');
  String get pinForgot =>
      _t('Забыли PIN?', 'Forgot PIN?', 'PIN кодты ұмыттыңыз ба?');
  String get pinResetTitle =>
      _t('Сброс PIN', 'Reset PIN', 'PIN кодты қалпына келтіру');
  String pinResetQuestion(int a, int b) => _t(
      'Чтобы задать новый PIN, решите пример:\n$a × $b = ?',
      'To set a new PIN, solve:\n$a × $b = ?',
      'Жаңа PIN орнату үшін мысалды шешіңіз:\n$a × $b = ?');
  String get pinResetWrong => _t('Ответ не подошёл. Вот другой пример.',
      'That answer did not match. Here is another one.',
      'Жауап сәйкес келмеді. Міне, басқа мысал.');
  String get answerHint => _t('Ответ', 'Answer', 'Жауап');
  String get checkButton => _t('Проверить', 'Check', 'Тексеру');

  // Home tab
  String greeting(String name) =>
      _t('Привет, $name!', 'Hi, $name!', 'Сәлем, $name!');
  String get readyForToday => _t(
      'Готовы к сегодняшнему дню?', 'Ready for today?', 'Бүгінге дайынсың ба?');
  String get startJourneyCard => _t('Давай начнём\nнаше путешествие!',
      "Let's start\nour journey!", 'Саяхатымызды\nбастайық!');
  String get journeyOfDay =>
      _t('Путешествие дня', "Today's journey", 'Күндізгі саяхат');
  String activitiesCount(int done, int total) => _t(
      '$done / $total активностей', '$done / $total activities', '$done / $total тапсырма');
  String get startJourneyButton => _t(
      'НАЧАТЬ ПУТЕШЕСТВИЕ', 'START MY JOURNEY', 'САЯХАТТЫ БАСТАУ');
  String get pecsCards => _t('Карточки PECS', 'PECS Cards', 'PECS карточкалары');
  String get pecsSubtitle => _t('Общение с помощью картинок',
      'Communicate with pictures', 'Суреттер арқылы қарым-қатынас');
  String get profileSnackbar => _t('Профиль', 'Profile', 'Профиль');
  String get startingJourneySnackbar =>
      _t('Начинаем путешествие', 'Starting the journey', 'Саяхат басталады');
  String get defaultUserName => _t('друг', 'friend', 'дос');

  // Games flow
  String get sessionDoneTitle => _t(
      'Занятие завершено! 🎉', 'Session complete! 🎉', 'Сабақ аяқталды! 🎉');
  String sessionDoneBody(int stars) => stars > 0
      ? _t(
          'Ты дошёл до конца сегодняшнего путешествия и заработал $stars ⭐. Отличная работа!',
          "You reached the end of today's journey and earned $stars ⭐. Great work!",
          'Сен бүгінгі саяхаттың соңына жетіп, $stars ⭐ жинадың. Жарайсың!')
      : _t(
          'Ты дошёл до конца сегодняшнего путешествия. Отличная работа!',
          "You reached the end of today's journey. Great work!",
          'Сен бүгінгі саяхаттың соңына жеттің. Жарайсың!');
  String get sessionDoneOk => _t('Отлично!', 'Great!', 'Тамаша!');

  // Speak game (practice with a parent)
  String get practiceWithParent => _t('Тренировка вместе с родителем',
      'Practice together with a parent', 'Ата-анамен бірге жаттығу');
  String get speakListen => _t('Послушать', 'Listen', 'Тыңдау');
  String get speakTryRepeat =>
      _t('Попробуй повторить', 'Try saying it', 'Қайталап көр');
  String get speakParentHint => _t(
      'Взрослый: отметьте, как получилось. Оба ответа подходят.',
      'Grown-up: tap how it went. Both answers are fine.',
      'Ересек адам: қалай болғанын белгілеңіз. Екі жауап та дұрыс.');
  String get speakDone => _t('Получилось', 'We did it', 'Шықты');
  String get speakLater => _t('Попробуем потом', 'Try later', 'Кейін байқаймыз');
  String get speakLaterSnackbar => _t('Хорошо, вернёмся к этому позже',
      "Okay, we'll come back to it later", 'Жарайды, кейінірек оралайық');

  // Bottom nav / main screen
  String get navHome => _t('Главная', 'Home', 'Басты бет');
  String get navJourney => _t('Путешествие', 'Journey', 'Саяхат');

  // Journey tab
  String get wardrobeLabel => _t('Гардероб', 'Wardrobe', 'Киім шкафы');
  String get wardrobeSnackbar => _t('Гардероб — скоро здесь',
      'Wardrobe — coming soon', 'Киім шкафы — жақында');
  String get journeySection =>
      _t('Раздел 2, Занятие 17', 'Section 2, Lesson 17', '2-бөлім, 17-сабақ');
  String get journeyLessonTitle =>
      _t('Опиши свой дом', 'Describe your home', 'Үйіңді сипатта');
  String get lessonListSnackbar => _t('Список занятий — скоро здесь',
      'Lesson list — coming soon', 'Сабақтар тізімі — жақында');
  String get lessonUnlockedSnackbar => _t('Занятие скоро будет доступно',
      'This lesson will be available soon', 'Сабақ жақында қолжетімді болады');
  String get lessonLockedSnackbar => _t('Занятие ещё не открыто',
      'This lesson is not unlocked yet', 'Сабақ әлі ашылмаған');

  // Settings screen
  String get settingsTitle => _t('Настройки', 'Settings', 'Баптаулар');
  String get settingsSubtitle => _t(
      'Управляй приложением и делай его удобнее для себя!',
      'Manage the app and make it more comfortable for you!',
      'Қолданбаны басқарып, өзіңе ыңғайлы ет!');
  String get sectionGeneral => _t('Общее', 'General', 'Жалпы');
  String get sound => _t('Звук', 'Sound', 'Дыбыс');
  String get music => _t('Музыка', 'Music', 'Музыка');
  String get vibration => _t('Вибрация', 'Vibration', 'Дірілдеу');
  String get sectionProfiles =>
      _t('Профили детей', 'Child profiles', 'Балалар профильдері');
  String get addProfile => _t('Добавить профиль', 'Add profile', 'Профиль қосу');
  String get editProfile => _t('Изменить текущий профиль',
      'Edit current profile', 'Ағымдағы профильді өзгерту');
  String get changePin => _t('Сменить PIN', 'Change PIN', 'PIN кодты өзгерту');
  String get sectionOther => _t('Другое', 'Other', 'Басқа');
  String get supportRow =>
      _t('Помощь и поддержка', 'Help & Support', 'Көмек және қолдау');
  String get sectionLanguage => _t('Язык', 'Language', 'Тіл');

  // Info screen
  String get infoTitle => _t('О приложении', 'About the App', 'Қолданба туралы');
  String get infoSubtitle => _t(
      'Узнай больше о Aila', 'Learn more about Aila', 'Aila туралы көбірек біл');
  String get infoHowItWorksTitle =>
      _t('Как работает Aila', 'How Aila works', 'Aila қалай жұмыс істейді');
  String get infoHowItWorksBody => _t(
      'Обучение в приложении проходит в формате мини-игр, интерактивных заданий и визуальных карточек. Ребёнок изучает слова, эмоции, предметы, действия и бытовые ситуации через изображения, озвучку, повторение слов и игровые сценарии. Голосовое взаимодействие помогает тренировать речь, произношение и коммуникативные навыки в комфортной и безопасной среде. Искусственный интеллект анализирует прогресс ребёнка и адаптирует задания под его уровень развития.',
      "Learning in the app happens through mini-games, interactive tasks, and visual cards. The child learns words, emotions, objects, actions, and everyday situations through images, voice, word repetition, and game scenarios. Voice interaction helps develop speech, pronunciation, and communication skills in a comfortable and safe environment. Artificial intelligence analyzes the child's progress and adapts tasks to their developmental level.",
      'Қолданбадағы оқыту мини-ойындар, интерактивті тапсырмалар және көрнекі карточкалар түрінде өтеді. Бала суреттер, дыбыстау, сөздерді қайталау және ойын сценарийлері арқылы сөздерді, эмоцияларды, заттарды, әрекеттерді және тұрмыстық жағдайларды үйренеді. Дауыстық өзара әрекеттесу сөйлеу тілін, дұрыс айтылымды және қарым-қатынас дағдыларын қолайлы әрі қауіпсіз ортада дамытуға көмектеседі. Жасанды интеллект баланың прогресін талдап, тапсырмаларды оның даму деңгейіне бейімдейді.');
  String get infoAiStarTitle =>
      _t('AI-звёздочка Aila', 'Aila the AI star', 'AI-жұлдызша Aila');
  String get infoAiStarBody => _t(
      'Главная особенность приложения — живая AI-звёздочка Aila, которая становится другом и помощником ребёнка. Она поддерживает ребёнка, помогает выполнять задания, общается с ним и мотивирует продолжать обучение, превращая развитие навыков в увлекательную игру.',
      "The app's key feature is Aila — a living AI star that becomes the child's friend and helper. She supports the child, helps complete tasks, talks with them, and motivates them to keep learning, turning skill development into an engaging game.",
      'Қолданбаның басты ерекшелігі — баланың досы әрі көмекшісіне айналатын жанды AI-жұлдызша Aila. Ол баланы қолдайды, тапсырмаларды орындауға көмектеседі, онымен сөйлеседі және оқуды жалғастыруға ынталандырады, дағдыларды дамытуды қызықты ойынға айналдырады.');
  String get infoRewardsTitle => _t(
      'Награды и мотивация', 'Rewards and motivation', 'Марапаттар мен ынталандыру');
  String get infoRewardsBody => _t(
      'За выполнение заданий ребёнок получает награды, может кастомизировать Aila и открывать новые игровые элементы, что повышает вовлечённость и интерес к обучению.',
      "For completing tasks, the child receives rewards, can customize Aila, and unlock new game elements, which increases engagement and interest in learning.",
      'Тапсырмаларды орындағаны үшін бала марапаттар алады, Aila-ны өзгерте алады және жаңа ойын элементтерін аша алады, бұл оқуға деген қызығушылық пен қатысуды арттырады.');
  String get infoSpecialistsTitle => _t(
      'Работа со специалистами', 'Working with specialists', 'Мамандармен жұмыс');
  String get infoSpecialistsBody => _t(
      'Платформа также предусматривает возможность дистанционного подключения специалистов для отслеживания прогресса ребёнка и корректировки программы развития.',
      "The platform also allows specialists to connect remotely to track the child's progress and adjust the development program.",
      'Платформа сонымен қатар баланың прогресін бақылап, даму бағдарламасын түзету үшін мамандарды қашықтан қосу мүмкіндігін қарастырады.');
  String get infoDisclaimerTitle => _t('Дисклеймер', 'Disclaimer', 'Ескерту');
  String get infoDisclaimerBody => _t(
      'На данный момент проект находится на стадии разработки, поэтому некоторые функции и механики могут изменяться и дорабатываться совместно со специалистами — логопедами, психологами и дефектологами — на основе их рекомендаций и практического опыта.',
      'The project is currently in development, so some features and mechanics may change and be refined together with specialists — speech therapists, psychologists, and special education teachers — based on their recommendations and practical experience.',
      'Қазіргі уақытта жоба әзірлену сатысында, сондықтан кейбір функциялар мен механикалар логопедтер, психологтар және дефектологтар сияқты мамандардың ұсыныстары мен тәжірибесі негізінде өзгеруі және жетілдірілуі мүмкін.');
  String get infoImportantTitle => _t('Важно', 'Important', 'Маңызды');
  String get infoImportantBody => _t(
      'Aila не заменяет профессиональную коррекционную помощь и работу со специалистами. Платформа создаётся как дополнительный инструмент поддержки для детей и семей, которые не всегда имеют возможность регулярно посещать коррекционные занятия.',
      "Aila does not replace professional corrective help and work with specialists. The platform is designed as an additional support tool for children and families who don't always have the opportunity to regularly attend corrective classes.",
      'Aila мамандардың кәсіби түзету көмегі мен жұмысын алмастырмайды. Платформа түзету сабақтарына үнемі қатыса алмайтын балалар мен отбасылар үшін қосымша қолдау құралы ретінде жасалған.');

  // Support screen
  String get supportTitle =>
      _t('Помощь и поддержка', 'Help & Support', 'Көмек және қолдау');
  String get supportSubtitle => _t('Мы всегда на связи и готовы помочь!',
      "We're always here to help!", 'Біз әрдайым байланыстамыз және көмектесуге дайынбыз!');
  String get phone1Label => _t('Телефон (1)', 'Phone (1)', 'Телефон (1)');
  String get phone2Label => _t('Телефон (2)', 'Phone (2)', 'Телефон (2)');
  String get emailLabel => _t('Email', 'Email', 'Email');
  String get supportTip => _t(
      'Если у вас возникли вопросы, пожелания или проблемы — напишите или позвоните нам. Мы обязательно вам поможем!',
      "If you have any questions, suggestions, or issues — write or call us. We'll be happy to help!",
      'Сұрақтарыңыз, тілектеріңіз немесе мәселелеріңіз болса — бізге жазыңыз немесе қоңырау шалыңыз. Біз міндетті түрде көмектесеміз!');
  String get numberCopied => _t('Номер скопирован', 'Number copied', 'Нөмір көшірілді');
  String get emailCopied => _t('Email скопирован', 'Email copied', 'Email көшірілді');
}
