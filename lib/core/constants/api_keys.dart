/// API Keys được inject qua --dart-define khi build.
///
/// Cách dùng:
///   flutter run --dart-define=VIRUSTOTAL_API_KEY=xxx --dart-define=IMGBB_API_KEY=yyy
///   flutter build apk --dart-define=VIRUSTOTAL_API_KEY=xxx --dart-define=IMGBB_API_KEY=yyy
///
/// Nếu không truyền --dart-define, giá trị mặc định sẽ được dùng.
class ApiKeys {
  ApiKeys._();

  static const String virustotalApiKey = String.fromEnvironment(
    'ef5fe0a25e8dcf56d76b0c0ab0d8e8153fda1f05b5d664cec943b733424cc719',
    defaultValue: '',
  );

  static const String imgbbApiKey = String.fromEnvironment(
    '3569b38e357045ceed58dfadfd649b2e',
    defaultValue: '',
  );
}
