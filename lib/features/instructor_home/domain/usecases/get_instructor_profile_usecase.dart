import 'package:grad_project/features/instructor_home/data/models/instructor_profile_model.dart';
import 'package:grad_project/features/instructor_home/domain/repositories/instructor_repository.dart';

class GetInstructorProfileUseCase {
  final InstructorRepository repository;

  GetInstructorProfileUseCase(this.repository);

  Future<InstructorProfileModel> call({bool forceRefresh = false}) async {
    return repository.getInstructorProfile(forceRefresh: forceRefresh);
  }
}
