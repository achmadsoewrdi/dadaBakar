import '../../../projects/domain/models/project_model.dart';
import '../../../devices/domain/models/device_profile_model.dart';
import '../../../content/domain/models/learning_module_model.dart';

abstract class IDashboardRepository {
  Future<List<ProjectModel>> getRecentProjects();
  Future<List<DeviceProfileModel>> getDeviceProfiles();
  Future<List<LearningModuleModel>> getLearningModules();
}
