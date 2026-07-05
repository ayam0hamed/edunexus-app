import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:grad_project/features/meetings/domain/repositories/meeting_repository.dart';
import 'package:grad_project/features/meetings/data/models/meeting_model.dart';
import 'meeting_event.dart';
import 'meeting_state.dart';

class MeetingBloc extends Bloc<MeetingEvent, MeetingState> {
  final MeetingRepository meetingRepository;
  
  // In-memory list to store created meetings if we want to share them
  List<MeetingModel> _cachedMeetings = [];

  MeetingBloc({required this.meetingRepository}) : super(const MeetingInitial()) {
    on<LoadMeetingsEvent>(_onLoadMeetings);
    on<CreateMeetingEvent>(_onCreateMeeting);
    on<RefreshMeetingsEvent>(_onRefreshMeetings);
  }

  Future<void> _onLoadMeetings(
    LoadMeetingsEvent event,
    Emitter<MeetingState> emit,
  ) async {
    // If not loaded yet, show loading state
    if (state is! MeetingLoaded || event.forceRefresh) {
      emit(const MeetingLoading());
    }

    try {
      debugPrint('MeetingBloc: Loading dashboard stats and profile...');
      
      // Load profile and counts in parallel
      final results = await Future.wait([
        meetingRepository.getProfile(),
        meetingRepository.getStudentsCount().catchError((e) {
          debugPrint('MeetingBloc: Error loading students count: $e');
          return 0;
        }),
        meetingRepository.getMeetingsCount().catchError((e) {
          debugPrint('MeetingBloc: Error loading meetings count: $e');
          return 0;
        }),
      ]);

      final profile = results[0] as Map<String, dynamic>;
      final studentsCount = results[1] as int;
      final meetingsCount = results[2] as int;

      final instructorId = profile['id']?.toString() ?? '';
      final instructorName = profile['fullName']?.toString() ?? '';

      // Get meetings cached in repo
      final meetings = meetingRepository.getMeetings();
      _cachedMeetings = meetings;

      emit(MeetingLoaded(
        studentsCount: studentsCount,
        meetingsCount: meetingsCount,
        instructorId: instructorId,
        instructorName: instructorName,
        meetings: List.from(meetings),
      ));
    } catch (e) {
      debugPrint('MeetingBloc: Error during LoadMeetingsEvent: ${e.toString()}');
      emit(MeetingError(e.toString()));
    }
  }

  Future<void> _onCreateMeeting(
    CreateMeetingEvent event,
    Emitter<MeetingState> emit,
  ) async {
    final currentState = state;
    String instructorId = '';
    String instructorName = '';

    if (currentState is MeetingLoaded) {
      instructorId = currentState.instructorId;
      instructorName = currentState.instructorName;
    } else {
      // Fetch profile if not loaded
      try {
        final profile = await meetingRepository.getProfile();
        instructorId = profile['id']?.toString() ?? '';
        instructorName = profile['fullName']?.toString() ?? '';
      } catch (e) {
        emit(MeetingError('Could not fetch profile before creating meeting: ${e.toString()}'));
        return;
      }
    }

    emit(const MeetingLoading());

    try {
      debugPrint('MeetingBloc: Creating meeting named: ${event.meetingTitle}');
      final newMeeting = await meetingRepository.createMeeting(
        meetingName: event.meetingTitle,
        courseTitle: event.courseTitle,
        date: event.date,
        time: event.time,
        duration: event.duration,
        maxAttendees: event.maxAttendees,
        userId: instructorId,
        userName: instructorName,
      );

      // Add to local cache list in bloc in case dynamic cast fails
      if (!_cachedMeetings.contains(newMeeting)) {
        _cachedMeetings.insert(0, newMeeting);
      }

      emit(const MeetingSuccess('Meeting created successfully.'));
    } catch (e) {
      debugPrint('MeetingBloc: Failed to create meeting: ${e.toString()}');
      emit(MeetingError(e.toString()));
    }
  }

  Future<void> _onRefreshMeetings(
    RefreshMeetingsEvent event,
    Emitter<MeetingState> emit,
  ) async {
    add(const LoadMeetingsEvent(forceRefresh: false));
  }
}
