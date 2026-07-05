import 'package:equatable/equatable.dart';
import '../../data/models/dashboard_model.dart';

sealed class StudentDashboardState extends Equatable {
  const StudentDashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardInitial extends StudentDashboardState {
  const DashboardInitial();
}

class DashboardLoading extends StudentDashboardState {
  const DashboardLoading();
}

class DashboardLoaded extends StudentDashboardState {
  final DashboardModel dashboard;

  const DashboardLoaded(this.dashboard);

  @override
  List<Object?> get props => [dashboard];
}

class DashboardError extends StudentDashboardState {
  final String message;

  const DashboardError(this.message);

  @override
  List<Object?> get props => [message];
}
