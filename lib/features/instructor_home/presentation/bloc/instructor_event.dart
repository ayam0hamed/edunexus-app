import 'package:equatable/equatable.dart';

sealed class InstructorEvent extends Equatable {
  const InstructorEvent();

  @override
  List<Object?> get props => [];
}

class LoadInstructorProfileEvent extends InstructorEvent {
  final bool forceRefresh;
  const LoadInstructorProfileEvent({this.forceRefresh = false});

  @override
  List<Object?> get props => [forceRefresh];
}
