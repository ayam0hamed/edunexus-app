import 'package:grad_project/features/meetings/data/models/meeting_model.dart';

abstract class MeetingRepository {
  Future<MeetingModel> createMeeting({
    required String meetingName,
    required String courseTitle,
    required String date,
    required String time,
    required String duration,
    required String maxAttendees,
    required String userId,
    required String userName,
  });

  Future<int> getStudentsCount();
  Future<int> getMeetingsCount();
  Future<Map<String, dynamic>> getProfile();
  List<MeetingModel> getMeetings();

  // Future stubs to make it easy to implement later
  Future<void> deleteMeeting(String meetingId);
  Future<void> editMeeting(MeetingModel meeting);
  Future<void> uploadPdf(String meetingId, String filePath);
  Future<void> startMeeting(String meetingId);
}
