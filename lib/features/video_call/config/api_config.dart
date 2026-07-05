/// Central configuration for all Video Call API endpoints.
class VideoCallConfig {
  // ── Base URLs ──────────────────────────────────────────────────────────
  static const String baseUrl = 'https://edunexus.runasp.net';
  static const String apiBase = '$baseUrl/api';
  static const String sfuBaseUrl = 'https://sfu.64.226.125.250.sslip.io';
  static const String signalrHubUrl = '$baseUrl/meetingHub';

  // ── REST endpoints ────────────────────────────────────────────────────
  // Meetings
  static const String meetingsCreate = '/api/Meetings/create';
  static const String meetingsActive = '/api/Meetings/active';
  static String meetingsById(String id) => '/api/Meetings/$id';
  static String meetingsJoin(String id) => '/api/Meetings/$id/join';
  static String meetingsLeave(String id) => '/api/Meetings/$id/leave';
  static String meetingsEnd(String id) => '/api/Meetings/$id/end';
  static String meetingsParticipants(String id) =>
      '/api/Meetings/$id/participants';

  // Media toggles
  static const String toggleAudio = '/api/Meetings/toggle-audio';
  static const String toggleVideo = '/api/Meetings/toggle-video';

  // WebRTC / SFU
  static const String iceConfig = '/api/webrtc/ice-config';
  static String sfuJoin(String meetingId) => '/api/sfu/join/$meetingId';
  static String sfuConsume(String meetingId) => '/api/sfu/consume/$meetingId';
  static const String sfuConnectSend = '/api/sfu/connect-send';
  static const String sfuProduce = '/api/sfu/produce';

  // Chat
  static String chatHistory(String meetingId) =>
      '/api/Meetings/$meetingId/chat';

  // Quiz
  static const String quizCreate = '/api/Quiz/create';
  static String quizStart(String sessionId) => '/api/Quiz/$sessionId/start';
  static String quizStop(String sessionId) => '/api/Quiz/$sessionId/stop';
  static const String quizAnswer = '/api/Quiz/answer';
  static String quizResults(String sessionId) =>
      '/api/Quiz/$sessionId/results';
}
