import 'package:grad_project/features/meetings/data/models/meeting_model.dart';

abstract class MeetingRepository {


  Future<int> getStudentsCount();
  Future<int> getMeetingsCount();
  Future<Map<String, dynamic>> getProfile();
  List<MeetingModel> getMeetings();

  // Future stubs to make it easy to implement later
  Future<void> deleteMeeting(String meetingId);

  Future<void> uploadPdf(String meetingId, String filePath);
  Future<void> startMeeting(String meetingId);
}
