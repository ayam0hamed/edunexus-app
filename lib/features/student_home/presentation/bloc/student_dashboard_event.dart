import 'package:equatable/equatable.dart';

sealed class StudentDashboardEvent extends Equatable {
  const StudentDashboardEvent();

  @override
  List<Object?> get props => [];
}

class LoadDashboardEvent extends StudentDashboardEvent {
  const LoadDashboardEvent();
}

class RefreshDashboardEvent extends StudentDashboardEvent {
  const RefreshDashboardEvent();
}
