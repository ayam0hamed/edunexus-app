import 'package:equatable/equatable.dart';

class ReactionsState extends Equatable {
  final Set<String> raisedHands; // Set of participantIds who raised hand
  final List<ReactionEvent> recentReojis; // Recent reactions

  const ReactionsState({
    required this.raisedHands,
    required this.recentReojis,
  });

  ReactionsState copyWith({
    Set<String>? raisedHands,
    List<ReactionEvent>? recentReojis,
  }) {
    return ReactionsState(
      raisedHands: raisedHands ?? this.raisedHands,
      recentReojis: recentReojis ?? this.recentReojis,
    );
  }

  @override
  List<Object?> get props => [raisedHands, recentReojis];
}

class ReactionEvent extends Equatable {
  final String id;
  final String emoji;
  final String fullName;
  final DateTime timestamp;

  const ReactionEvent({
    required this.id,
    required this.emoji,
    required this.fullName,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [id, emoji, fullName, timestamp];
}
