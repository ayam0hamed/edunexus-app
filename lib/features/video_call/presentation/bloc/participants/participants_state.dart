import 'package:equatable/equatable.dart';
import 'package:grad_project/features/video_call/data/models/participant_model.dart';

class ParticipantsState extends Equatable {
  final List<ParticipantModel> participants;
  final String? pinnedParticipantId;

  const ParticipantsState({
    required this.participants,
    this.pinnedParticipantId,
  });

  ParticipantsState copyWith({
    List<ParticipantModel>? participants,
    String? pinnedParticipantId,
  }) {
    return ParticipantsState(
      participants: participants ?? this.participants,
      pinnedParticipantId: pinnedParticipantId ?? this.pinnedParticipantId,
    );
  }

  @override
  List<Object?> get props => [participants, pinnedParticipantId];
}
