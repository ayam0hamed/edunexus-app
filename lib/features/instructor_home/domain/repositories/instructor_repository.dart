import 'package:grad_project/features/instructor_home/data/models/instructor_profile_model.dart';

abstract class InstructorRepository {
  Future<InstructorProfileModel> getInstructorProfile({bool forceRefresh = false});
  Future<InstructorProfileModel?> getCachedProfile();
  Future<void> clearCache();
}
