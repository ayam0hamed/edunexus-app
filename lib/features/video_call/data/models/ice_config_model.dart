import 'package:equatable/equatable.dart';

/// STUN/TURN server configuration returned by the backend.
class IceConfigResponse extends Equatable {
  final List<IceServerModel> iceServers;
  final int iceCandidatePoolSize;

  const IceConfigResponse({
    required this.iceServers,
    this.iceCandidatePoolSize = 0,
  });

  factory IceConfigResponse.fromJson(Map<String, dynamic> json) {
    final servers = json['iceServers'];
    return IceConfigResponse(
      iceServers: servers is List
          ? servers
              .whereType<Map<String, dynamic>>()
              .map(IceServerModel.fromJson)
              .toList()
          : const [],
      iceCandidatePoolSize: json['iceCandidatePoolSize'] as int? ?? 0,
    );
  }

  @override
  List<Object?> get props => [iceServers, iceCandidatePoolSize];
}

/// A single STUN/TURN ICE server entry.
class IceServerModel extends Equatable {
  final List<String> urls;
  final String? username;
  final String? credential;

  const IceServerModel({
    required this.urls,
    this.username,
    this.credential,
  });

  factory IceServerModel.fromJson(Map<String, dynamic> json) {
    final rawUrls = json['urls'];
    List<String> parsedUrls;
    if (rawUrls is List) {
      parsedUrls = rawUrls.map((e) => e.toString()).toList();
    } else if (rawUrls is String) {
      parsedUrls = [rawUrls];
    } else {
      parsedUrls = const [];
    }

    return IceServerModel(
      urls: parsedUrls,
      username: json['username']?.toString(),
      credential: json['credential']?.toString(),
    );
  }

  /// Convert to flutter_webrtc's expected map format.
  Map<String, dynamic> toWebRtcMap() => {
        'urls': urls,
        if (username != null) 'username': username,
        if (credential != null) 'credential': credential,
      };

  @override
  List<Object?> get props => [urls, username, credential];
}
