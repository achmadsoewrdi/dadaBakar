import '../../../content/domain/models/learning_module_model.dart';

abstract class ILessonsRepository {
  Future<List<LearningModuleModel>> getLearningModules();
}
