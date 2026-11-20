// Контакты поддержки не хранятся в коде, чтобы не попасть в открытый репозиторий.
// Они подставляются при сборке из файла support_contacts.json (он в .gitignore):
//   flutter run -d macos --dart-define-from-file=support_contacts.json
// Образец файла: support_contacts.example.json. Пустой контакт не показывается.

const kSupportPhone1 = String.fromEnvironment('AILA_SUPPORT_PHONE1');
const kSupportPhone2 = String.fromEnvironment('AILA_SUPPORT_PHONE2');
const kSupportEmail = String.fromEnvironment('AILA_SUPPORT_EMAIL');
