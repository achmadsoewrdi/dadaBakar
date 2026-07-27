import '../../domain/repositories/i_lessons_repository.dart';
import '../../../content/domain/models/learning_module_model.dart';

class LessonsRepository implements ILessonsRepository {
  @override
  Future<List<LearningModuleModel>> getLearningModules() async {
    final now = DateTime.now();
    return [
      LearningModuleModel(
        id: 'mod_01',
        title: 'Dasar Pemrograman Robotik & IoT',
        description: 'Pelajari dasar-dasar mengontrol pin GPIO, WiFi, dan sensor pada single board computer.',
        stepsJson: {'steps': 5, 'level': 'Pemula'},
        isPremiumOnly: false,
        createdAt: now.subtract(const Duration(days: 10)),
        imageAsset: 'assets/images/modules/robot.png',
        imageBgColor: '0xFFFFF3E0',
      ),
      LearningModuleModel(
        id: 'mod_02',
        title: 'Kamera AI & Robotik Raspberry Pi',
        description: 'Membangun sistem pengenal wajah dan kontrol motor otomatis dengan Raspberry Pi.',
        stepsJson: {'steps': 8, 'level': 'Lanjutan'},
        isPremiumOnly: true,
        createdAt: now.subtract(const Duration(days: 7)),
        imageAsset: 'assets/images/modules/car.png',
        imageBgColor: '0xFFE0F7FA',
      ),
      LearningModuleModel(
        id: 'mod_03',
        title: 'Protokol Komunikasi WebSocket & BLE',
        description: 'Koneksikan hardware secara langsung ke Flutter App menggunakan WebSocket & Bluetooth.',
        stepsJson: {'steps': 6, 'level': 'Menengah'},
        isPremiumOnly: false,
        createdAt: now.subtract(const Duration(days: 4)),
        imageAsset: 'assets/images/modules/board.png',
        imageBgColor: '0xFFE8F5E9',
      ),
    ];
  }
}
