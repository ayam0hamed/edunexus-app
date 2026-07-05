import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:grad_project/core/routing/app_routes.dart';
import 'package:grad_project/features/meetings/data/models/meeting_model.dart';
import 'package:grad_project/features/meetings/presentation/bloc/meeting_bloc.dart';
import 'package:grad_project/features/meetings/presentation/bloc/meeting_event.dart';
import 'package:grad_project/features/meetings/presentation/bloc/meeting_state.dart';
import 'package:grad_project/features/instructor_home/data/models/instructor_profile_model.dart';
import 'package:grad_project/features/instructor_home/presentation/bloc/instructor_bloc.dart';
import 'package:grad_project/features/instructor_home/presentation/bloc/instructor_event.dart';
import 'package:grad_project/features/instructor_home/presentation/bloc/instructor_state.dart';
import 'package:grad_project/features/video_call/presentation/bloc/video_call/video_call_cubit.dart';
import 'package:grad_project/features/video_call/presentation/bloc/video_call/video_call_state.dart';

class InstructorScreen extends StatelessWidget {
  const InstructorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<InstructorBloc>(
          create: (_) => GetIt.I<InstructorBloc>()..add(const LoadInstructorProfileEvent()),
        ),
        BlocProvider<MeetingBloc>(
          create: (_) => GetIt.I<MeetingBloc>()..add(const LoadMeetingsEvent()),
        ),
        // VideoCallCubit is provided here so the BlocListener below can
        // react to VideoCallJoined and navigate directly to the Meeting Room,
        // bypassing the Lobby entirely for the instructor.
        BlocProvider<VideoCallCubit>(
          create: (_) => GetIt.I<VideoCallCubit>(),
        ),
      ],
      child: BlocListener<VideoCallCubit, VideoCallState>(
        listener: (context, state) {
          if (state is VideoCallJoined) {
            debugPrint('[Meeting] Navigating with meetingId=${state.meetingId}');
            Navigator.pushNamed(
              context,
              AppRoutes.meetingRoom,
              arguments: {
                'meetingId': state.meetingId,
                'cubit': context.read<VideoCallCubit>(),
              },
            );
          } else if (state is VideoCallError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to start meeting: ${state.message}'),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.white,
            shadowColor: const Color.fromARGB(255, 94, 92, 95),
            title: Row(
              children: [
                const ImageIcon(AssetImage('assets/images/platform.png'), size: 65),
                const SizedBox(width: 8),
                RichText(
                  text: const TextSpan(
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    children: [
                      TextSpan(
                        text: 'Edu',
                        style: TextStyle(color: Color(0xFF163D69)),
                      ),
                      TextSpan(
                        text: 'Nexus',
                        style: TextStyle(color: Color(0xFFE56C00)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined, color: Color(0xFF163D69)),
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.settings);
                },
              ),
            ],
          ),
          body: Stack(
            children: [
              // ── Main dashboard content ──────────────────────────────────
              BlocBuilder<InstructorBloc, InstructorState>(
                builder: (context, instructorState) {
                  if (instructorState is InstructorInitial || instructorState is InstructorLoading) {
                    return const Center(
                      child: CircularProgressIndicator(color: Color(0xFF163D69)),
                    );
                  }

                  if (instructorState is InstructorError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Colors.redAccent,
                              size: 48,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              instructorState.message,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: () {
                                context.read<InstructorBloc>().add(
                                      const LoadInstructorProfileEvent(forceRefresh: true),
                                    );
                                context.read<MeetingBloc>().add(
                                      const LoadMeetingsEvent(forceRefresh: true),
                                    );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF163D69),
                              ),
                              child: const Text(
                                'Try Again',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (instructorState is InstructorLoaded) {
                    return BlocBuilder<MeetingBloc, MeetingState>(
                      builder: (context, meetingState) {
                        if (meetingState is MeetingInitial || meetingState is MeetingLoading) {
                          return const Center(
                            child: CircularProgressIndicator(color: Color(0xFF163D69)),
                          );
                        }

                        if (meetingState is MeetingError) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    color: Colors.redAccent,
                                    size: 48,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    meetingState.message,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  ElevatedButton(
                                    onPressed: () {
                                      context.read<MeetingBloc>().add(
                                            const LoadMeetingsEvent(forceRefresh: true),
                                          );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF163D69),
                                    ),
                                    child: const Text(
                                      'Try Again',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        if (meetingState is MeetingLoaded) {
                          return _buildDashboardContent(
                            context,
                            meetingState,
                            instructorState.profile,
                          );
                        }

                        return const SizedBox.shrink();
                      },
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),

              // ── Loading overlay while joining a meeting ─────────────────
              // Shown when VideoCallCubit is processing the join request.
              // Prevents double-tapping and gives visual feedback.
              BlocBuilder<VideoCallCubit, VideoCallState>(
                builder: (context, callState) {
                  if (callState is VideoCallLoading) {
                    return Container(
                      color: Colors.black.withOpacity(0.3),
                      child: const Center(
                        child: CircularProgressIndicator(color: Color(0xFF163D69)),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardContent(
    BuildContext context,
    MeetingLoaded state,
    InstructorProfileModel profile,
  ) {
    final String firstName = profile.fullName.isNotEmpty
        ? profile.fullName.split(' ').first
        : 'Instructor';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Header
            Row(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage('assets/images/john.jpg'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back, $firstName',
                        style: const TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        'Manage your interactive virtual classes and lessons today',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: Colors.black.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Quick Actions
            const Text(
              'Instructor Dashboard',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF163D69),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xffECECEC),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xffB3B3B3).withOpacity(0.5),
                    blurRadius: 4,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.dashboard_customize_outlined,
                        size: 18,
                        color: Color(0xFF163D69),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Teaching Overview",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatCard(
                        icon: Icons.people_outline,
                        title: 'Students',
                        value: state.studentsCount.toString(),
                        color: const Color(0xffDAFFE2),
                      ),
                      _buildStatCard(
                        icon: Icons.video_call_outlined,
                        title: 'Meetings',
                        value: state.meetingsCount.toString(),
                        color: const Color(0xffDAF3FF),
                      ),
                      _buildStatCard(
                        icon: Icons.pending_actions_outlined,
                        title: 'Assignments',
                        value: '0',
                        color: const Color(0xffD5DDE6),
                        subtitle: 'Coming Soon',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Schedule Meeting button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await Navigator.pushNamed(
                          context,
                          AppRoutes.scheduleMeeting,
                        );
                        // Refresh dashboard after returning from schedule screen
                        if (context.mounted) {
                          context.read<MeetingBloc>().add(
                                const LoadMeetingsEvent(forceRefresh: true),
                              );
                        }
                      },
                      icon: const Icon(Icons.calendar_month_outlined,
                          color: Colors.white, size: 18),
                      label: const Text(
                        'Schedule Meeting',
                        style: TextStyle(color: Colors.white, fontSize: 13),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF163D69),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Upcoming Meetings
            const Text(
              'Upcoming Meetings',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF163D69),
              ),
            ),
            const SizedBox(height: 12),
            if (state.meetings.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  children: [
                    Icon(Icons.event_busy, size: 48, color: Colors.grey.shade400),
                    const SizedBox(height: 12),
                    Text(
                      'No upcoming meetings',
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.5),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Schedule a meeting to get started',
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.4),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              )
            else
              // Pass instructorName so each card can use the real name when joining
              ...state.meetings.map((meeting) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildUpcomingMeetingCard(
                      context,
                      meeting,
                      state.instructorName,
                    ),
                  )),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    String? subtitle,
  }) {
    return Container(
      width: 93,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFF163D69), size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              color: Colors.black.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 8,
                fontStyle: FontStyle.italic,
                color: Colors.black.withOpacity(0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  /// Builds a single meeting card.
  ///
  /// [instructorName] is the real instructor name from [MeetingLoaded.instructorName],
  /// sourced from the backend profile. It is passed directly to [joinMeeting] so
  /// we never rely on a local UUID or placeholder identity.
  Widget _buildUpcomingMeetingCard(
    BuildContext context,
    MeetingModel meeting,
    String instructorName,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: Title + Upload PDF
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.videocam, color: Color(0xFF163D69), size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meeting.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF163D69),
                      ),
                    ),
                    if (meeting.courseTitle != null &&
                        meeting.courseTitle!.isNotEmpty)
                      Text(
                        meeting.courseTitle!,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.black.withOpacity(0.5),
                        ),
                      ),
                  ],
                ),
              ),
              // Upload PDF button — pending backend implementation
              Tooltip(
                message: 'Pending backend implementation',
                child: OutlinedButton.icon(
                  onPressed: null, // Disabled
                  icon: const Icon(Icons.upload_file, size: 14),
                  label: const Text('Upload Pdf', style: TextStyle(fontSize: 11)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Course name dot indicator
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF163D69),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  meeting.courseTitle ?? 'No course',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Time / Duration / Date row
          Row(
            children: [
              Icon(Icons.access_time, size: 14, color: Colors.black.withOpacity(0.5)),
              const SizedBox(width: 4),
              Text(
                '${meeting.time ?? '--:--'}  (${meeting.duration ?? 'N/A'})',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black.withOpacity(0.6),
                ),
              ),
              const SizedBox(width: 16),
              Icon(Icons.calendar_today, size: 14, color: Colors.black.withOpacity(0.5)),
              const SizedBox(width: 4),
              Text(
                meeting.date ?? meeting.createdAt?.split('T').first ?? '',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black.withOpacity(0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Action buttons row
          Row(
            children: [
              // ── Start Meeting ────────────────────────────────────────────
              // Navigates DIRECTLY to the Meeting Room using the backend
              // meeting ID. Never uses a fake/local UUID and never goes
              // through the Lobby screen.
              ElevatedButton.icon(
                onPressed: () {
                  debugPrint('[Meeting] Start Meeting pressed');
                  debugPrint(
                    '[Meeting] Opening meeting: '
                    'meetingId=${meeting.id}, isActive=${meeting.isActive}',
                  );

                  // Guard: meeting must have a real backend ID
                  if (meeting.id.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Invalid meeting: missing ID. '
                          'Please recreate the meeting.',
                        ),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                    return;
                  }

                  // Guard: meeting must be marked active by the backend
                  if (!meeting.isActive) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('This meeting is not currently active.'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                    return;
                  }

                  final name = instructorName.isNotEmpty
                      ? instructorName
                      : 'Instructor';

                  debugPrint(
                    '[Meeting] Joining as instructor: '
                    'name=$name, meetingId=${meeting.id}',
                  );

                  // Trigger join — the BlocListener in build() detects
                  // VideoCallJoined and navigates to AppRoutes.meetingRoom.
                  context.read<VideoCallCubit>().joinMeeting(
                        meeting.id,
                        name,
                        isInstructor: true,
                      );
                },
                icon: const Icon(Icons.play_arrow, size: 16, color: Colors.white),
                label: const Text(
                  'Start Meeting',
                  style: TextStyle(fontSize: 11, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF163D69),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Copy Link — pending backend implementation
              Tooltip(
                message: 'Pending backend implementation',
                child: OutlinedButton.icon(
                  onPressed: null, // Disabled
                  icon: const Icon(Icons.copy, size: 14),
                  label: const Text('Copy Link',
                      style: TextStyle(fontSize: 11)),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 8),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Edit — pending backend implementation
              Tooltip(
                message: 'Pending backend implementation',
                child: SizedBox(
                  width: 36,
                  height: 36,
                  child: OutlinedButton(
                    onPressed: null, // Disabled
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    child: const Icon(Icons.edit_outlined, size: 16),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Delete — pending backend implementation
              Tooltip(
                message: 'Pending backend implementation',
                child: SizedBox(
                  width: 36,
                  height: 36,
                  child: OutlinedButton(
                    onPressed: null, // Disabled
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      side: const BorderSide(color: Colors.redAccent),
                    ),
                    child: const Icon(Icons.close, size: 16, color: Colors.redAccent),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
