import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:grad_project/core/routing/app_routes.dart';
import 'package:grad_project/features/student_home/data/models/course_model.dart';
import 'package:grad_project/features/student_home/presentation/bloc/student_dashboard_bloc.dart';
import 'package:grad_project/features/student_home/presentation/bloc/student_dashboard_event.dart';
import 'package:grad_project/features/student_home/presentation/bloc/student_dashboard_state.dart';
import 'package:grad_project/features/video_call/presentation/bloc/video_call/video_call_cubit.dart';
import 'package:grad_project/features/video_call/presentation/bloc/video_call/video_call_state.dart';
import 'package:grad_project/features/video_call/presentation/screens/meeting_room_screen.dart';

class StudentScreen extends StatefulWidget {
  const StudentScreen({super.key});

  @override
  State<StudentScreen> createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen> {
  final TextEditingController meetingIdController = TextEditingController();
  bool _isJoining = false;

  @override
  void dispose() {
    meetingIdController.dispose();
    super.dispose();
  }

  Future<void> _joinMeeting(String meetingId, String userName) async {
    if (meetingId.trim().isEmpty) return;

    setState(() => _isJoining = true);

    final cubit = GetIt.I<VideoCallCubit>();

    await cubit.joinMeeting(meetingId.trim(), userName);

    if (!mounted) return;

    setState(() => _isJoining = false);

    if (cubit.state is VideoCallJoined) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: cubit,
            child: MeetingRoomScreen(meetingId: meetingId.trim()),
          ),
        ),
      );
    } else if (cubit.state is VideoCallError) {
      final errorState = cubit.state as VideoCallError;
      // Extract a cleaner message from the error
      final rawMessage = errorState.message;
      final String displayMessage;
      if (rawMessage.contains('Meeting not found or inactive')) {
        displayMessage =
            'Meeting not found or has already ended.\nPlease check the Meeting ID and try again.';
      } else if (rawMessage.contains('Failed to join meeting')) {
        // Try to show the backend message if embedded
        final backendMsg = rawMessage.replaceFirst(
          'Failed to join meeting: ',
          '',
        );
        displayMessage = backendMsg.isNotEmpty ? backendMsg : rawMessage;
      } else {
        displayMessage = rawMessage;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  displayMessage,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      body: BlocProvider<StudentDashboardBloc>(
        create: (_) =>
            GetIt.I<StudentDashboardBloc>()..add(const LoadDashboardEvent()),
        child: BlocBuilder<StudentDashboardBloc, StudentDashboardState>(
          builder: (context, state) {
            if (state is DashboardInitial || state is DashboardLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF163D69)),
              );
            }

            if (state is DashboardError) {
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
                        state.message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          context.read<StudentDashboardBloc>().add(
                            const RefreshDashboardEvent(),
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

            if (state is DashboardLoaded) {
              final dashboard = state.dashboard;
              final String fullName = dashboard.profile.fullName;
              final String firstName = fullName.isNotEmpty
                  ? fullName.split(' ').first
                  : 'Student';
              final String welcomeSubText =
                  dashboard.profile.welcomeText ??
                  "Let's continue your learning journey and your goals today";

              final coursesCount = dashboard.courses.length;

              return RefreshIndicator(
                color: const Color(0xFF163D69),
                onRefresh: () async {
                  final bloc = context.read<StudentDashboardBloc>();
                  bloc.add(const RefreshDashboardEvent());
                  await bloc.stream.firstWhere(
                    (s) => s is DashboardLoaded || s is DashboardError,
                  );
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Welcome Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const CircleAvatar(
                            radius: 25,
                            backgroundImage: AssetImage(
                              'assets/images/john.jpg',
                            ),
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
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                Text(
                                  welcomeSubText,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black.withOpacity(0.6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Learning Overview
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xffECECEC),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xffB3B3B3).withOpacity(0.4),
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
                                Image.asset(
                                  'assets/images/overview.png',
                                  width: 15,
                                  height: 15,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "Learning Overview",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black.withOpacity(0.8),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Your learning performance",
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.black.withOpacity(0.6),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildOverviewCard(
                                  icon: Icons.check_circle_outline,
                                  title: 'Quizzes',
                                  value: '0',
                                  subtitle: 'Coming Soon',
                                  bgColor: const Color(0xffDAFFE2),
                                  iconColor: const Color(0xFF27AE60),
                                ),
                                _buildOverviewCard(
                                  icon: Icons.menu_book_outlined,
                                  title: 'Courses',
                                  value: '$coursesCount',
                                  subtitle: '$coursesCount active',
                                  bgColor: const Color(0xffDAF3FF),
                                  iconColor: const Color(0xFF2980B9),
                                ),
                                _buildOverviewCard(
                                  icon: Icons.videocam_outlined,
                                  title: 'Meeting',
                                  value: '${dashboard.meetingsCount}',
                                  subtitle: '${dashboard.meetingsCount} active',
                                  bgColor: const Color(0xffD5DDE6),
                                  iconColor: const Color(0xFF163D69),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // My Courses Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'My Courses',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF163D69),
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: const Text(
                              'Show All',
                              style: TextStyle(
                                color: Color(0xFFE56C00),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      dashboard.courses.isEmpty
                          ? Container(
                              height: 100,
                              alignment: Alignment.center,
                              child: const Text(
                                'No enrolled courses yet.',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            )
                          : SizedBox(
                              height: 110,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: dashboard.courses.length,
                                itemBuilder: (context, index) {
                                  return _buildCourseCard(
                                    dashboard.courses[index],
                                  );
                                },
                              ),
                            ),
                      const SizedBox(height: 24),

                      // Upcoming Meetings Section
                      const Text(
                        'Join Meetings',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF163D69),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Enter the Meeting ID provided by your instructor.',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.black.withOpacity(0.5),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: meetingIdController,
                        decoration: const InputDecoration(
                          hintText: "Enter Meeting ID",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.videocam_outlined),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isJoining
                              ? null
                              : () => _joinMeeting(
                                  meetingIdController.text,
                                  dashboard.profile.email,
                                ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF163D69),
                            disabledBackgroundColor: const Color(
                              0xFF163D69,
                            ).withOpacity(0.6),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: _isJoining
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  "Join Meeting",
                                  style: TextStyle(color: Colors.white),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildOverviewCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color bgColor,
    required Color iconColor,
  }) {
    return Container(
      width: 93,
      height: 110,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: iconColor, size: 14),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w600,
                    color: iconColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w400,
              color: Colors.black.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseCard(CourseModel course) {
    return Container(
      width: 170,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.school, color: Color(0xFF163D69), size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  course.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D253F),
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(height: 8, thickness: 0.5),
              Text(
                'ID: ${course.id}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                  color: Colors.black.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
