import 'package:equatable/equatable.dart';

class ParticipantJoinedPayload extends Equatable {
  final String participantId;
  final String fullName;
  final bool isAudioEnabled;
  final bool isVideoEnabled;
  final bool isScreenSharing;
  final bool isHandRaised;

  const ParticipantJoinedPayload({
    required this.participantId,
    required this.fullName,
    required this.isAudioEnabled,
    required this.isVideoEnabled,
    required this.isScreenSharing,
    required this.isHandRaised,
  });

  factory ParticipantJoinedPayload.fromJson(Map<String, dynamic> json) {
    return ParticipantJoinedPayload(
      participantId: json['participantId']?.toString() ?? json['id']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? json['name']?.toString() ?? json['userName']?.toString() ?? 'Unknown',
      isAudioEnabled: json['isAudioEnabled'] as bool? ?? true,
      isVideoEnabled: json['isVideoEnabled'] as bool? ?? true,
      isScreenSharing: json['isScreenSharing'] as bool? ?? false,
      isHandRaised: json['isHandRaised'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [
        participantId,
        fullName,
        isAudioEnabled,
        isVideoEnabled,
        isScreenSharing,
        isHandRaised,
      ];
}

class MediaTogglePayload extends Equatable {
  final String participantId;
  final bool enabled;

  const MediaTogglePayload({required this.participantId, required this.enabled});

  factory MediaTogglePayload.fromJson(Map<String, dynamic> json) {
    return MediaTogglePayload(
      participantId: json['participantId']?.toString() ?? '',
      enabled: json['enabled'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [participantId, enabled];
}

class HandRaisedPayload extends Equatable {
  final String participantId;
  final String fullName;
  final bool raised;

  const HandRaisedPayload({
    required this.participantId,
    required this.fullName,
    required this.raised,
  });

  factory HandRaisedPayload.fromJson(Map<String, dynamic> json) {
    return HandRaisedPayload(
      participantId: json['participantId']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      raised: json['raised'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [participantId, fullName, raised];
}

class ReactionPayload extends Equatable {
  final String emoji;
  final String fullName;

  const ReactionPayload({required this.emoji, required this.fullName});

  factory ReactionPayload.fromJson(Map<String, dynamic> json) {
    return ReactionPayload(
      emoji: json['emoji']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
    );
  }

  @override
  List<Object?> get props => [emoji, fullName];
}

class KickedPayload extends Equatable {
  final String participantId;
  final String fullName;

  const KickedPayload({required this.participantId, required this.fullName});

  factory KickedPayload.fromJson(Map<String, dynamic> json) {
    return KickedPayload(
      participantId: json['participantId']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
    );
  }

  @override
  List<Object?> get props => [participantId, fullName];
}

class LockTogglePayload extends Equatable {
  final bool locked;
  final String toggledBy;

  const LockTogglePayload({required this.locked, required this.toggledBy});

  factory LockTogglePayload.fromJson(Map<String, dynamic> json) {
    return LockTogglePayload(
      locked: json['locked'] as bool? ?? false,
      toggledBy: json['toggledBy']?.toString() ?? '',
    );
  }

  @override
  List<Object?> get props => [locked, toggledBy];
}

class ChatTogglePayload extends Equatable {
  final bool enabled;
  final String toggledBy;

  const ChatTogglePayload({required this.enabled, required this.toggledBy});

  factory ChatTogglePayload.fromJson(Map<String, dynamic> json) {
    return ChatTogglePayload(
      enabled: json['enabled'] as bool? ?? false,
      toggledBy: json['toggledBy']?.toString() ?? '',
    );
  }

  @override
  List<Object?> get props => [enabled, toggledBy];
}

class ProducerCreatedPayload extends Equatable {
  final String producerId;
  final String participantId;
  final String kind;
  final Map<String, dynamic> appData;
  final String fullName;

  const ProducerCreatedPayload({
    required this.producerId,
    required this.participantId,
    required this.kind,
    required this.appData,
    required this.fullName,
  });

  factory ProducerCreatedPayload.fromJson(Map<String, dynamic> json) {
    return ProducerCreatedPayload(
      producerId: json['producerId']?.toString() ?? '',
      participantId: json['participantId']?.toString() ?? '',
      kind: json['kind']?.toString() ?? 'video',
      appData: (json['appData'] ?? <String, dynamic>{}) as Map<String, dynamic>,
      fullName: json['fullName']?.toString() ?? '',
    );
  }

  @override
  List<Object?> get props => [producerId, participantId, kind, appData, fullName];
}

class ProducerClosedPayload extends Equatable {
  final String producerId;
  final String participantId;
  final String kind;
  final Map<String, dynamic> appData;

  const ProducerClosedPayload({
    required this.producerId,
    required this.participantId,
    required this.kind,
    required this.appData,
  });

  factory ProducerClosedPayload.fromJson(Map<String, dynamic> json) {
    return ProducerClosedPayload(
      producerId: json['producerId']?.toString() ?? '',
      participantId: json['participantId']?.toString() ?? '',
      kind: json['kind']?.toString() ?? 'video',
      appData: (json['appData'] ?? <String, dynamic>{}) as Map<String, dynamic>,
    );
  }

  @override
  List<Object?> get props => [producerId, participantId, kind, appData];
}
