abstract final class ApiEndpoints {
  static const String baseUrl = 'https://such-platypus-pox.ngrok-free.dev';

  // Auth
  static const String register = '/api/v1/auth/register';
  static const String login = '/api/v1/auth/login';
  static const String refresh = '/api/v1/auth/refresh';
  static const String me = '/api/v1/auth/me';

  // Profile
  static const String users = '/api/v1/users';
  static const String myInterests = '/api/v1/users/me/interests';
  static const String myPhotos = '/api/v1/users/me/photos';

  // Posts
  static const String posts = '/api/v1/posts';

  // Matching
  static const String matches = '/api/v1/matches';

  // Chat
  static const String conversations = '/api/v1/conversations';

  // Events
  static const String events = '/api/v1/events';

  // Notifications
  static const String notifications = '/api/v1/notifications';
}
