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

  // Create account screen
  String get createAccountTitle =>
      _t('Создать\nаккаунт', 'Create\nan account', 'Аккаунт\nжасау');
  String get signInWithApple =>
      _t('Войти через Apple', 'Sign in with Apple', 'Apple арқылы кіру');
  String get signUpWithGoogle => _t(
      'Регистрация через Google', 'Sign up with Google', 'Google арқылы тіркелу');
  String get continueWithEmail => _t(
      'Продолжить через email', 'Continue with email', 'Email арқылы жалғастыру');
  String get emailHint => _t('Email', 'Email', 'Email');
  String get passwordHint => _t('Пароль', 'Password', 'Құпия сөз');
  String get createAccountButton =>
      _t('Создать аккаунт', 'Create account', 'Аккаунт жасау');
  String get loadingButton => _t('Загрузка...', 'Loading...', 'Жүктелуде...');
  String get alreadyHaveAccount => _t(
      'Уже есть аккаунт? ', 'Already have an account? ', 'Аккаунтыңыз бар ма? ');
  String get logIn => _t('Войти', 'Log In', 'Кіру');

  // Login screen
  String get loginTitle =>
      _t('С\nвозвращением', 'Welcome\nback', 'Қайта\nқош келдіңіз');
  String get signInWithGoogle =>
      _t('Войти через Google', 'Sign in with Google', 'Google арқылы кіру');
  String get logInButton => _t('Войти', 'Log In', 'Кіру');
  String get dontHaveAccount => _t(
      'Нет аккаунта? ', "Don't have an account? ", 'Аккаунтыңыз жоқ па? ');
  String get signUp => _t('Регистрация', 'Sign Up', 'Тіркелу');

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
  String get sectionAccount => _t('Аккаунт', 'Account', 'Аккаунт');
  String get syncProgress => _t(
      'Синхронизация прогресса', 'Sync progress', 'Прогресті синхрондау');
  String get sectionOther => _t('Другое', 'Other', 'Басқа');
  String get supportRow =>
      _t('Помощь и поддержка', 'Help & Support', 'Көмек және қолдау');
  String get logout => _t('Выйти из аккаунта', 'Log out', 'Аккаунттан шығу');
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
