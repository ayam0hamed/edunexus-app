import 'package:equatable/equatable.dart';

/// Represents a participant inside a video call meeting.
class ParticipantModel extends Equatable {
  final String id;
  final String name;
  final bool isAudioEnabled;
  final bool isVideoEnabled;
  final bool isScreenSharing;
  final bool isHandRaised;
  final String? joinedAt;

  const ParticipantModel({
    required this.id,
    required this.name,
    this.isAudioEnabled = true,
    this.isVideoEnabled = true,
    this.isScreenSharing = false,
    this.isHandRaised = false,
    this.joinedAt,
  });

  factory ParticipantModel.fromJson(Map<String, dynamic> json) {
    return ParticipantModel(
      id: json['id']?.toString() ?? json['Id']?.toString() ?? json['participantId']?.toString() ?? json['ParticipantId']?.toString() ?? '',
      name: json['name']?.toString() ??
          json['Name']?.toString() ??
          json['fullName']?.toString() ??
          json['FullName']?.toString() ??
          json['userName']?.toString() ??
          json['UserName']?.toString() ??
          '',
      isAudioEnabled: json['isAudioEnabled'] as bool? ?? json['IsAudioEnabled'] as bool? ?? true,
      isVideoEnabled: json['isVideoEnabled'] as bool? ?? json['IsVideoEnabled'] as bool? ?? true,
      isScreenSharing: json['isScreenSharing'] as bool? ?? json['IsScreenSharing'] as bool? ?? false,
      isHandRaised: json['isHandRaised'] as bool? ?? json['IsHandRaised'] as bool? ?? false,
      joinedAt: json['joinedAt']?.toString() ?? json['JoinedAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'isAudioEnabled': isAudioEnabled,
        'isVideoEnabled': isVideoEnabled,
        'isScreenSharing': isScreenSharing,
        'isHandRaised': isHandRaised,
        'joinedAt': joinedAt,
      };

  ParticipantModel copyWith({
    String? id,
    String? name,
    bool? isAudioEnabled,
    bool? isVideoEnabled,
    bool? isScreenSharing,
    bool? isHandRaised,
    String? joinedAt,
  }) {
    return ParticipantModel(
      id: id ?? this.id,
      name: name ?? this.name,
      isAudioEnabled: isAudioEnabled ?? this.isAudioEnabled,
      isVideoEnabled: isVideoEnabled ?? this.isVideoEnabled,
      isScreenSharing: isScreenSharing ?? this.isScreenSharing,
      isHandRaised: isHandRaised ?? this.isHandRaised,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        isAudioEnabled,
        isVideoEnabled,
        isScreenSharing,
        isHandRaised,
        joinedAt,
      ];
}
