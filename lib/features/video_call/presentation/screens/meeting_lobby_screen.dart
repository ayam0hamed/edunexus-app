import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:grad_project/core/routing/app_routes.dart';
import 'package:grad_project/features/auth/domain/repositories/auth_repository.dart';
import 'package:grad_project/features/auth/data/services/jwt_service.dart';
import 'package:grad_project/features/meetings/data/models/meeting_model.dart';
import 'package:grad_project/features/video_call/data/services/video_call_api_service.dart';
import 'package:grad_project/features/video_call/presentation/bloc/video_call/video_call_cubit.dart';
import 'package:grad_project/features/video_call/presentation/bloc/video_call/video_call_state.dart';

class MeetingLobbyScreen extends StatefulWidget {
  const MeetingLobbyScreen({super.key});

  @override
  State<MeetingLobbyScreen> createState() => _MeetingLobbyScreenState();
}

class _MeetingLobbyScreenState extends State<MeetingLobbyScreen> {
  final _apiService = GetIt.I<VideoCallApiService>();
  final _authRepository = GetIt.I<AuthRepository>();
  final _jwtService = GetIt.I<JwtService>();

  List<MeetingModel> _activeMeetings = [];
  bool _isLoading = true;
  String _errorMessage = '';
  
  String _userName = 'User';
  String _userEmail = '';
  String _userId = '';
  bool _isInstructor = false;

  @override
  void initState() {
    super.initState();
    _loadUserInfoAndMeetings();
  }

  Future<void> _loadUserInfoAndMeetings() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final token = await _authRepository.getToken();
      if (token != null && token.isNotEmpty) {
        final decoded = _jwtService.tryDecode(token);
        _userId = decoded['UserId']?.toString() ?? '';
        _userName = decoded['fullName']?.toString() ?? decoded['userName']?.toString() ?? 'User';
        _userEmail = decoded['email']?.toString() ?? decoded['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress']?.toString() ?? '';
        final role = _jwtService.getRole(token);
        _isInstructor = role == 'Instructor';
      }

      await _fetchMeetings();
    } catch (e) {
      setState(() {
        _errorMessage = 'Initialization failed: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchMeetings() async {
    try {
      final meetings = await _apiService.getActiveMeetings();
      setState(() {
        _activeMeetings = meetings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load active meetings: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _createMeeting() async {
    final titleController = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Meeting'),
        content: TextField(
          controller: titleController,
          decoration: const InputDecoration(
            hintText: 'Enter meeting name/title',
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF163D69)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.black54)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, titleController.text),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF163D69)),
            child: const Text('Create', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (result != null && result.trim().isNotEmpty) {
      if (!mounted) return;
      context.read<VideoCallCubit>().createMeeting(result.trim(), _userId, _userName, _userEmail);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<VideoCallCubit, VideoCallState>(
      listener: (context, state) {
        if (state is VideoCallJoined) {
          Navigator.pushNamed(
            context,
            AppRoutes.meetingRoom,
            arguments: {
              'meetingId': state.meetingId,
            },
          );
        } else if (state is VideoCallError) {
          final isPermissionError = state.message.toLowerCase().contains('permission') ||
              state.message.toLowerCase().contains('blocked') ||
              state.message.toLowerCase().contains('settings');

          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  Icon(
                    isPermissionError ? Icons.no_photography_outlined : Icons.error_outline,
                    color: Colors.redAccent,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isPermissionError ? 'Permission Required' : 'Error',
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              content: Text(state.message),
              actions: [
                if (isPermissionError)
                  TextButton.icon(
                    icon: const Icon(Icons.settings_outlined),
                    label: const Text('Open Settings'),
                    onPressed: () {
                      Navigator.pop(context);
                      openAppSettings();
                    },
                  ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Dismiss'),
                ),
              ],
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Meeting Lobby',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Color(0xFF163D69)),
              onPressed: _fetchMeetings,
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF163D69)))
            : _errorMessage.isNotEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
                          const SizedBox(height: 12),
                          Text(_errorMessage, textAlign: TextAlign.center),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadUserInfoAndMeetings,
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF163D69)),
                            child: const Text('Retry', style: TextStyle(color: Colors.white)),
                          )
                        ],
                      ),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _fetchMeetings,
                    color: const Color(0xFF163D69),
                    child: _activeMeetings.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                              Center(
                                child: Column(
                                  children: [
                                    Icon(Icons.video_camera_front_outlined, size: 64, color: Colors.grey.shade300),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No active meetings right now.',
                                      style: TextStyle(fontSize: 16, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _isInstructor 
                                          ? 'Click the button below to start one.' 
                                          : 'Check back later or refresh.',
                                      style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _activeMeetings.length,
                            itemBuilder: (context, index) {
                              final meeting = _activeMeetings[index];
                              return Card(
                                elevation: 2,
                                margin: const EdgeInsets.only(bottom: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  leading: CircleAvatar(
                                    backgroundColor: const Color(0xFFDAF3FF),
                                    child: Icon(Icons.video_call, color: const Color(0xFF163D69)),
                                  ),
                                  title: Text(
                                    meeting.name,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                  subtitle: Text(
                                    'Host ID: ${meeting.id.substring(0, 8)}...',
                                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                                  ),
                                  trailing: ElevatedButton(
                                    onPressed: () {
                                      context.read<VideoCallCubit>().joinMeeting(
                                            meeting.id,
                                            _userEmail,
                                            isInstructor: _isInstructor,
                                          );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF163D69),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    child: const Text('Join', style: TextStyle(color: Colors.white)),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
        floatingActionButton: _isInstructor
            ? FloatingActionButton.extended(
                onPressed: _createMeeting,
                label: const Text('New Meeting', style: TextStyle(color: Colors.white)),
                icon: const Icon(Icons.add, color: Colors.white),
                backgroundColor: const Color(0xFF163D69),
              )
            : null,
      ),
    );
  }
}
